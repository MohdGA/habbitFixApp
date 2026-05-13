import type { FastifyInstance } from 'fastify';
import { authService } from './auth.service.js';
import {
  RegisterSchema,
  LoginSchema,
  RefreshSchema,
  ForgotPasswordSchema,
  ResetPasswordSchema,
  ChangePasswordSchema,
  type RegisterDto,
} from './auth.schema.js';
import { validateBody } from '../../shared/middleware/validate.js';
import { z } from 'zod';

const VerifyEmailOtpSchema = z.object({
  otp: z.string().length(6).regex(/^\d{6}$/),
});

export async function authRoutes(app: FastifyInstance) {
  // POST /auth/register
  app.post('/register', {
    config: { rateLimit: { max: 10, timeWindow: '15m' } },
  }, async (req, reply) => {
    const dto = validateBody(RegisterSchema, req.body);
    const ip = req.ip ?? '0.0.0.0';
    const ua = req.headers['user-agent'];
    const result = await authService.register(dto as RegisterDto, app, ip, ua);
    return reply.status(201).send(result);
  });

  // POST /auth/login
  app.post('/login', {
    config: { rateLimit: { max: 10, timeWindow: '15m' } },
  }, async (req, reply) => {
    const dto = validateBody(LoginSchema, req.body);
    const ip = req.ip ?? '0.0.0.0';
    const ua = req.headers['user-agent'];
    const result = await authService.login(dto, app, ip, ua);
    return reply.send(result);
  });

  // POST /auth/refresh
  app.post('/refresh', async (req, reply) => {
    const dto = validateBody(RefreshSchema, req.body);
    const result = await authService.refresh(dto, app);
    return reply.send(result);
  });

  // POST /auth/logout
  app.post('/logout', { onRequest: [app.authenticate] }, async (req, reply) => {
    const body = req.body as any;
    if (body?.refreshToken) {
      await authService.logout(body.refreshToken);
    }
    return reply.status(204).send();
  });

  // POST /auth/logout-all
  app.post('/logout-all', { onRequest: [app.authenticate] }, async (req, reply) => {
    await authService.logoutAll(req.user.sub);
    return reply.status(204).send();
  });

  // POST /auth/verify-email  (requires valid JWT — issued at registration)
  app.post('/verify-email', { onRequest: [app.authenticate] }, async (req, reply) => {
    const dto = validateBody(VerifyEmailOtpSchema, req.body);
    const ip = req.ip ?? '0.0.0.0';
    const ua = req.headers['user-agent'];
    const result = await authService.verifyEmail(req.user.sub, dto.otp, ip, ua);
    return reply.send(result);
  });

  // POST /auth/resend-verification  (rate-limited: 3/hour)
  app.post('/resend-verification', {
    onRequest: [app.authenticate],
    config: { rateLimit: { max: 3, timeWindow: '1h' } },
  }, async (req, reply) => {
    // Fetch user email + displayName for the email
    const { prisma } = await import('../../config/prisma.js');
    const user = await prisma.user.findUnique({
      where: { id: req.user.sub },
      select: { email: true, displayName: true, emailVerified: true },
    });
    if (!user) return reply.status(404).send({ message: 'User not found' });
    if (user.emailVerified) return reply.send({ message: 'Email already verified' });
    const result = await authService.resendVerification(req.user.sub, user.email, user.displayName);
    return reply.send(result);
  });

  // POST /auth/forgot-password
  app.post('/forgot-password', {
    config: { rateLimit: { max: 3, timeWindow: '15m' } },
  }, async (req, reply) => {
    const dto = validateBody(ForgotPasswordSchema, req.body);
    const ip = req.ip ?? '0.0.0.0';
    const ua = req.headers['user-agent'];
    const result = await authService.forgotPassword(dto, ip, ua);
    return reply.send(result);
  });

  // POST /auth/reset-password
  app.post('/reset-password', async (req, reply) => {
    const dto = validateBody(ResetPasswordSchema, req.body);
    const ip = req.ip ?? '0.0.0.0';
    const ua = req.headers['user-agent'];
    const result = await authService.resetPassword(dto, ip, ua);
    return reply.send(result);
  });

  // POST /auth/change-password
  app.post('/change-password', { onRequest: [app.authenticate] }, async (req, reply) => {
    const dto = validateBody(ChangePasswordSchema, req.body);
    const result = await authService.changePassword(req.user.sub, dto);
    return reply.send(result);
  });

  // GET /auth/me
  app.get('/me', { onRequest: [app.authenticate] }, async (req, reply) => {
    return reply.send({ user: req.user });
  });
}
