import nodemailer from 'nodemailer';
import Handlebars from 'handlebars';
import { env } from '../../config/env.js';

const transporter = nodemailer.createTransport({
  host: env.SMTP_HOST,
  port: env.SMTP_PORT,
  secure: env.SMTP_SECURE,
  auth: {
    user: env.SMTP_USER,
    pass: env.SMTP_PASS,
  },
});

// ─── Base layout ─────────────────────────────────────────────────────────────

const baseStyles = `
  body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background: #09090B; color: #ffffff; margin: 0; padding: 0; }
  .container { max-width: 560px; margin: 40px auto; padding: 40px; background: #18181B; border-radius: 16px; border: 1px solid #27272A; }
  .logo { font-size: 28px; font-weight: 800; color: #FF9F0A; margin-bottom: 24px; }
  h1 { font-size: 24px; margin: 0 0 16px; color: #ffffff; }
  p { color: #A1A1AA; line-height: 1.6; margin: 0 0 16px; }
  .btn { display: inline-block; padding: 14px 32px; border-radius: 12px; text-decoration: none; font-weight: 700; font-size: 16px; }
  .btn-orange { background: #FF9F0A; color: #000000; }
  .btn-purple { background: #BF5AF2; color: #ffffff; }
  .footer { margin-top: 32px; padding-top: 24px; border-top: 1px solid #27272A; color: #71717A; font-size: 13px; }
  .stat { display: inline-block; text-align: center; padding: 16px 24px; background: #09090B; border-radius: 12px; margin: 8px; }
  .stat-value { font-size: 28px; font-weight: 800; color: #FF9F0A; display: block; }
  .stat-label { font-size: 12px; color: #71717A; text-transform: uppercase; letter-spacing: 0.5px; }
`;

// ─── Templates ────────────────────────────────────────────────────────────────

const verifyEmailTemplate = Handlebars.compile(`<!DOCTYPE html>
<html><head><meta charset="utf-8"><style>${baseStyles}</style></head>
<body><div class="container">
  <div class="logo">🔥 Quitly</div>
  <h1>Verify your email, {{name}}!</h1>
  <p>You're one step away from starting your transformation journey. Click below to verify your email.</p>
  <a href="{{verifyUrl}}" class="btn btn-orange">Verify Email</a>
  <p style="margin-top:16px;font-size:13px;">Or copy: <a href="{{verifyUrl}}" style="color:#FF9F0A;">{{verifyUrl}}</a></p>
  <div class="footer"><p>Link expires in 24 hours. If you didn't sign up for Quitly, ignore this email.</p></div>
</div></body></html>`);

const resetPasswordTemplate = Handlebars.compile(`<!DOCTYPE html>
<html><head><meta charset="utf-8"><style>${baseStyles}</style></head>
<body><div class="container">
  <div class="logo">🔥 Quitly</div>
  <h1>Reset your password</h1>
  <p>Hi {{name}}, we received a password reset request for your Quitly account.</p>
  <a href="{{resetUrl}}" class="btn btn-purple">Reset Password</a>
  <p style="margin-top:16px;background:#2D1515;border:1px solid #7C2D12;border-radius:8px;padding:12px;color:#FCA5A5;font-size:14px;">⚠️ This link expires in 1 hour and can only be used once.</p>
  <div class="footer"><p>If you didn't request this, your account is safe. You can ignore this email.</p></div>
</div></body></html>`);

const weeklyReportTemplate = Handlebars.compile(`<!DOCTYPE html>
<html><head><meta charset="utf-8"><style>${baseStyles}</style></head>
<body><div class="container">
  <div class="logo">🔥 Quitly</div>
  <h1>Your week in review, {{name}}! 🎉</h1>
  <div style="text-align:center;margin:24px 0;">
    <div class="stat"><span class="stat-value">{{checkinCount}}</span><span class="stat-label">Check-ins</span></div>
    <div class="stat"><span class="stat-value">{{longestStreak}}d</span><span class="stat-label">Best Streak</span></div>
    <div class="stat"><span class="stat-value">Lvl {{level}}</span><span class="stat-label">Your Level</span></div>
  </div>
  <p style="background:#1A2D1A;border:1px solid #166534;border-radius:12px;padding:16px;color:#86EFAC;">{{summary}}</p>
  <a href="{{appUrl}}" class="btn btn-orange">Open Quitly</a>
  <div class="footer"><p>You're receiving this because weekly reports are enabled. <a href="{{appUrl}}/settings" style="color:#FF9F0A;">Manage preferences</a></p></div>
</div></body></html>`);

// ─── Send functions ────────────────────────────────────────────────────────────

export async function sendVerificationEmail(email: string, name: string, token: string): Promise<void> {
  const verifyUrl = `${env.CLIENT_URL}/verify-email?token=${token}`;
  await transporter.sendMail({
    from: env.EMAIL_FROM,
    to: email,
    subject: '🔥 Verify your Quitly email',
    html: verifyEmailTemplate({ name, verifyUrl }),
  });
}

export async function sendPasswordResetEmail(email: string, name: string, token: string): Promise<void> {
  const resetUrl = `${env.CLIENT_URL}/reset-password?token=${token}`;
  await transporter.sendMail({
    from: env.EMAIL_FROM,
    to: email,
    subject: '🔐 Reset your Quitly password',
    html: resetPasswordTemplate({ name, resetUrl }),
  });
}

export async function sendWeeklyReportEmail(
  email: string,
  name: string,
  data: { checkinCount: number; longestStreak: number; level: number; summary: string },
): Promise<void> {
  await transporter.sendMail({
    from: env.EMAIL_FROM,
    to: email,
    subject: `🔥 Your Quitly week in review`,
    html: weeklyReportTemplate({ name, appUrl: env.CLIENT_URL, ...data }),
  });
}
