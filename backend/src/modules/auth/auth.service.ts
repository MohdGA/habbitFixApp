import argon2 from 'argon2';
import crypto from 'crypto';
import { v4 as uuidv4 } from 'uuid';
import { Prisma } from '@prisma/client';
import { prisma } from '../../config/prisma.js';
import { getRedis, RedisKeys } from '../../config/redis.js';
import { env } from '../../config/env.js';
import { sendVerificationEmail, sendPasswordResetEmail } from '../../shared/utils/email.js';
import type {
  RegisterDto,
  LoginDto,
  RefreshDto,
  ForgotPasswordDto,
  ResetPasswordDto,
  ChangePasswordDto,
} from './auth.schema.js';

// ─── Constants ────────────────────────────────────────────────────────────────

// Pre-computed dummy hash used in constant-time compare when user not found
// (prevents timing-based email enumeration)
const DUMMY_HASH =
  '$argon2id$v=19$m=65536,t=3,p=1$dummysaltdummysalt1234$dummyhashoutputdummyhashoutputdummyhash';

const MAX_LOGIN_FAILURES = 5;
const LOCKOUT_TTL_SECONDS = 900; // 15 min
const OTP_TTL_SECONDS = 600;     // 10 min
const OTP_MAX_ATTEMPTS = 5;
const RESET_TTL_SECONDS = 1800;  // 30 min

// ─── Token helpers ────────────────────────────────────────────────────────────

function hashToken(token: string): string {
  return crypto.createHash('sha256').update(token).digest('hex');
}

function generateOpaqueToken(bytes = 40): string {
  return crypto.randomBytes(bytes).toString('hex');
}

function generateOtp(): string {
  return String(crypto.randomInt(100000, 999999));
}

function parseDuration(str: string): number {
  const units: Record<string, number> = {
    s: 1000,
    m: 60 * 1000,
    h: 60 * 60 * 1000,
    d: 24 * 60 * 60 * 1000,
  };
  const match = str.match(/^(\d+)([smhd])$/);
  if (!match) return 30 * 24 * 60 * 60 * 1000;
  return parseInt(match[1]) * units[match[2]];
}

async function writeAuditLog(
  action: string,
  ip: string,
  userId?: string,
  userAgent?: string,
  metadata?: Record<string, unknown>,
): Promise<void> {
  try {
    await prisma.auditLog.create({
      data: { action, ip, userId, userAgent, metadata: (metadata ?? {}) as Prisma.InputJsonValue },
    });
  } catch {
    // Audit log failure must never crash the request
  }
}

// ─── Auth Service ─────────────────────────────────────────────────────────────

export class AuthService {
  async register(
    dto: RegisterDto,
    fastify: any,
    ip = '0.0.0.0',
    userAgent?: string,
  ) {
    dto.email = dto.email.toLowerCase().trim();

    const existing = await prisma.user.findFirst({
      where: { OR: [{ email: dto.email }, { username: dto.username }] },
      select: { email: true, username: true },
    });

    if (existing) {
      if (existing.email === dto.email) {
        throw Object.assign(new Error('Email already in use'), { statusCode: 409 });
      }
      throw Object.assign(new Error('Username already taken'), { statusCode: 409 });
    }

    const passwordHash = await argon2.hash(dto.password, {
      type: argon2.argon2id,
      memoryCost: 65536,
      timeCost: 3,
      parallelism: 1,
    });

    const user = await prisma.user.create({
      data: {
        email: dto.email,
        username: dto.username,
        displayName: dto.displayName,
        passwordHash,
        timezone: dto.timezone ?? 'UTC',
        emailVerified: true,
        stats: { create: {} },
        notificationPrefs: { create: {} },
      },
      select: {
        id: true,
        email: true,
        username: true,
        displayName: true,
        emailVerified: true,
        createdAt: true,
      },
    });

    const tokens = await this.issueTokenPair(user, fastify);

    await writeAuditLog('user.register', ip, user.id, userAgent, { email: dto.email.replace(/^(.).+@/, '$1***@') });

    return { user, ...tokens, message: 'Registration successful. Please verify your email.' };
  }

  async login(
    dto: LoginDto,
    fastify: any,
    ip = '0.0.0.0',
    userAgent?: string,
  ) {
    dto.email = dto.email.toLowerCase().trim();
    const redis = getRedis();

    const user = await prisma.user.findUnique({
      where: { email: dto.email },
      select: {
        id: true,
        email: true,
        username: true,
        displayName: true,
        passwordHash: true,
        emailVerified: true,
        isActive: true,
        fcmToken: true,
      },
    });

    // Check account lockout BEFORE password verify (only when user exists)
    if (user) {
      const lockKey = `lockout:${user.id}`;
      const locked = await redis.get(lockKey);
      if (locked) {
        const ttl = await redis.ttl(lockKey);
        await writeAuditLog('user.login_lockout', ip, user.id, userAgent);
        throw Object.assign(
          new Error('Account temporarily locked due to too many failed attempts. Try again later.'),
          { statusCode: 423, retryAfter: ttl },
        );
      }
    }

    // ALWAYS run argon2.verify even when user is not found — prevents timing attack
    const hashToCheck = user?.passwordHash ?? DUMMY_HASH;
    const validPassword = await argon2.verify(hashToCheck, dto.password);

    if (!user || !user.isActive || !validPassword) {
      if (user) {
        const failKey = `login:fails:${user.id}`;
        const fails = await redis.incr(failKey);
        await redis.expire(failKey, LOCKOUT_TTL_SECONDS);

        if (fails >= MAX_LOGIN_FAILURES) {
          await redis.setex(`lockout:${user.id}`, LOCKOUT_TTL_SECONDS, '1');
          await redis.del(failKey);
        }

        await writeAuditLog('user.login_failed', ip, user.id, userAgent, { attempt: fails });
      }
      throw Object.assign(new Error('Invalid credentials'), { statusCode: 401 });
    }

    if (!user.emailVerified) {
      throw Object.assign(
        new Error('Please verify your email before logging in.'),
        { statusCode: 403, code: 'EMAIL_NOT_VERIFIED' },
      );
    }

    // Success — clear fail counter, issue tokens
    await redis.del(`login:fails:${user.id}`);

    const tokens = await this.issueTokenPair(user, fastify);

    await prisma.userStats.upsert({
      where: { userId: user.id },
      create: { userId: user.id, lastActiveAt: new Date() },
      update: { lastActiveAt: new Date() },
    });

    await writeAuditLog('user.login', ip, user.id, userAgent);

    return {
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        displayName: user.displayName,
        emailVerified: user.emailVerified,
      },
      ...tokens,
    };
  }

  async refresh(dto: RefreshDto, fastify: any) {
    const tokenHash = hashToken(dto.refreshToken);

    const stored = await prisma.refreshToken.findUnique({
      where: { tokenHash },
      include: { user: { select: { id: true, email: true, username: true, isActive: true } } },
    });

    if (!stored) {
      throw Object.assign(new Error('Invalid refresh token'), { statusCode: 401 });
    }

    if (stored.revokedAt) {
      // Reuse detected — revoke entire family
      await prisma.refreshToken.updateMany({
        where: { family: stored.family },
        data: { revokedAt: new Date() },
      });
      throw Object.assign(
        new Error('Session compromised. Please log in again.'),
        { statusCode: 401, code: 'SESSION_COMPROMISED' },
      );
    }

    if (stored.expiresAt < new Date()) {
      throw Object.assign(new Error('Refresh token expired'), { statusCode: 401 });
    }

    if (!stored.user.isActive) {
      throw Object.assign(new Error('Account disabled'), { statusCode: 401 });
    }

    await prisma.refreshToken.update({
      where: { id: stored.id },
      data: { revokedAt: new Date() },
    });

    return this.issueTokenPair(stored.user, fastify, stored.family);
  }

  async logout(refreshToken: string) {
    const tokenHash = hashToken(refreshToken);
    await prisma.refreshToken.updateMany({
      where: { tokenHash },
      data: { revokedAt: new Date() },
    });
  }

  async logoutAll(userId: string) {
    await prisma.refreshToken.updateMany({
      where: { userId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }

  async verifyEmail(userId: string, otp: string, ip = '0.0.0.0', userAgent?: string) {
    const redis = getRedis();
    const attemptsKey = `otp:attempts:${userId}`;
    const otpKey = `otp:${userId}:verify`;

    // Brute-force protection
    const attempts = parseInt((await redis.get(attemptsKey)) ?? '0');
    if (attempts >= OTP_MAX_ATTEMPTS) {
      throw Object.assign(
        new Error('Too many attempts. Request a new verification code.'),
        { statusCode: 429, code: 'OTP_MAX_ATTEMPTS' },
      );
    }

    const storedHash = await redis.get(otpKey);
    if (!storedHash) {
      throw Object.assign(
        new Error('Verification code expired or not found. Request a new one.'),
        { statusCode: 400 },
      );
    }

    const otpHash = hashToken(otp);
    if (otpHash !== storedHash) {
      const newAttempts = await redis.incr(attemptsKey);
      await redis.expire(attemptsKey, OTP_TTL_SECONDS);
      if (newAttempts >= OTP_MAX_ATTEMPTS) {
        await redis.del(otpKey);
      }
      throw Object.assign(new Error('Invalid verification code'), { statusCode: 400 });
    }

    // OTP valid — clean up
    await redis.del(otpKey);
    await redis.del(attemptsKey);

    await prisma.user.update({
      where: { id: userId },
      data: { emailVerified: true },
    });

    await writeAuditLog('user.email_verified', ip, userId, userAgent);
    return { message: 'Email verified successfully' };
  }

  async resendVerification(userId: string, email: string, displayName: string) {
    const redis = getRedis();
    const otp = generateOtp();
    const otpHash = hashToken(otp);
    await redis.setex(`otp:${userId}:verify`, OTP_TTL_SECONDS, otpHash);
    await redis.del(`otp:attempts:${userId}`);
    sendVerificationEmail(email, displayName, otp).catch(console.error);
    return { message: 'Verification code resent' };
  }

  async forgotPassword(
    dto: ForgotPasswordDto,
    ip = '0.0.0.0',
    userAgent?: string,
  ) {
    const user = await prisma.user.findUnique({
      where: { email: dto.email },
      select: { id: true, displayName: true },
    });

    if (!user) {
      throw Object.assign(new Error('No account found with that email address.'), { statusCode: 404 });
    }

    const token = generateOpaqueToken(32);
    const tokenHash = hashToken(token);
    const redis = getRedis();
    await redis.setex(`reset:${user.id}`, RESET_TTL_SECONDS, tokenHash);

    await writeAuditLog('user.password_reset_requested', ip, user.id, userAgent);

    return { message: 'Reset token generated.', userId: user.id, token };
  }

  async resetPassword(
    dto: ResetPasswordDto,
    ip = '0.0.0.0',
    userAgent?: string,
  ) {
    const redis = getRedis();
    const attemptsKey = `otp:attempts:${dto.userId}`;

    const attempts = parseInt((await redis.get(attemptsKey)) ?? '0');
    if (attempts >= OTP_MAX_ATTEMPTS) {
      throw Object.assign(
        new Error('Too many attempts. Request a new reset link.'),
        { statusCode: 429 },
      );
    }

    const storedHash = await redis.get(`reset:${dto.userId}`);
    if (!storedHash) {
      throw Object.assign(new Error('Reset link expired or invalid'), { statusCode: 400 });
    }

    const tokenHash = hashToken(dto.token);
    if (tokenHash !== storedHash) {
      await redis.incr(attemptsKey);
      await redis.expire(attemptsKey, RESET_TTL_SECONDS);
      throw Object.assign(new Error('Invalid reset token'), { statusCode: 400 });
    }

    const passwordHash = await argon2.hash(dto.password, {
      type: argon2.argon2id,
      memoryCost: 65536,
      timeCost: 3,
      parallelism: 1,
    });

    await prisma.$transaction([
      prisma.user.update({
        where: { id: dto.userId },
        data: { passwordHash },
      }),
      prisma.refreshToken.updateMany({
        where: { userId: dto.userId, revokedAt: null },
        data: { revokedAt: new Date() },
      }),
    ]);

    await redis.del(`reset:${dto.userId}`);
    await redis.del(attemptsKey);

    await writeAuditLog('user.password_reset', ip, dto.userId, userAgent);
    return { message: 'Password reset successfully. Please log in.' };
  }

  async changePassword(userId: string, dto: ChangePasswordDto) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { passwordHash: true },
    });

    if (!user) throw Object.assign(new Error('User not found'), { statusCode: 404 });

    const valid = await argon2.verify(user.passwordHash, dto.currentPassword);
    if (!valid) throw Object.assign(new Error('Current password is incorrect'), { statusCode: 400 });

    const passwordHash = await argon2.hash(dto.newPassword, {
      type: argon2.argon2id,
      memoryCost: 65536,
      timeCost: 3,
      parallelism: 1,
    });

    await prisma.user.update({ where: { id: userId }, data: { passwordHash } });
    return { message: 'Password changed successfully' };
  }

  // ─── Private ──────────────────────────────────────────────────────────────

  private async issueTokenPair(
    user: { id: string; email: string; username: string },
    fastify: any,
    existingFamily?: string,
  ) {
    // Spec: payload must contain only { sub, jti, iat, exp } — no PII
    const jti = uuidv4();
    const accessToken = fastify.jwt.sign({ sub: user.id, jti });

    const refreshToken = generateOpaqueToken(64);
    const tokenHash = hashToken(refreshToken);
    const family = existingFamily ?? uuidv4();
    const expiresAt = new Date(Date.now() + parseDuration(env.JWT_REFRESH_EXPIRES_IN));

    await prisma.refreshToken.create({
      data: { userId: user.id, tokenHash, family, expiresAt },
    });

    return { accessToken, refreshToken, expiresIn: env.JWT_ACCESS_EXPIRES_IN };
  }
}

export const authService = new AuthService();
