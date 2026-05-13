import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { prisma } from '../../config/prisma.js';
import { validateBody } from '../../shared/middleware/validate.js';

const UpdateProfileSchema = z.object({
  displayName: z.string().min(2).max(50).optional(),
  timezone: z.string().optional(),
  avatarUrl: z.string().url().optional().nullable(),
  fcmToken: z.string().optional().nullable(),
});

const UpdateNotifPrefsSchema = z.object({
  channel: z.enum(['PUSH', 'EMAIL', 'BOTH']).optional(),
  dailyReminderTime: z.string().regex(/^\d{2}:\d{2}$/).optional(),
  streakAlerts: z.boolean().optional(),
  weeklyReport: z.boolean().optional(),
  milestoneAlerts: z.boolean().optional(),
  communityAlerts: z.boolean().optional(),
});

export async function userRoutes(app: FastifyInstance) {
  const auth = { onRequest: [app.authenticate] };

  // GET /users/me
  app.get('/me', auth, async (req, reply) => {
    const user = await prisma.user.findUnique({
      where: { id: req.user.sub },
      select: {
        id: true,
        email: true,
        username: true,
        displayName: true,
        avatarUrl: true,
        timezone: true,
        emailVerified: true,
        createdAt: true,
        stats: true,
        notificationPrefs: true,
      },
    });

    if (!user) return reply.status(404).send({ message: 'User not found' });
    return reply.send({ user });
  });

  // PATCH /users/me
  app.patch('/me', auth, async (req, reply) => {
    const dto = validateBody(UpdateProfileSchema, req.body);

    const user = await prisma.user.update({
      where: { id: req.user.sub },
      data: dto,
      select: {
        id: true,
        email: true,
        username: true,
        displayName: true,
        avatarUrl: true,
        timezone: true,
      },
    });

    return reply.send({ user });
  });

  // PATCH /users/me/notifications
  app.patch('/me/notifications', auth, async (req, reply) => {
    const dto = validateBody(UpdateNotifPrefsSchema, req.body);

    const prefs = await prisma.notificationPreference.upsert({
      where: { userId: req.user.sub },
      create: { userId: req.user.sub, ...dto },
      update: dto,
    });

    return reply.send({ prefs });
  });

  // DELETE /users/me
  app.delete('/me', auth, async (req, reply) => {
    await prisma.user.update({
      where: { id: req.user.sub },
      data: { isActive: false },
    });
    return reply.send({ message: 'Account deactivated successfully' });
  });

  // GET /users/:username (public profile)
  app.get('/:username', async (req, reply) => {
    const { username } = req.params as { username: string };

    const user = await prisma.user.findUnique({
      where: { username },
      select: {
        id: true,
        username: true,
        displayName: true,
        avatarUrl: true,
        createdAt: true,
        stats: {
          select: {
            level: true,
            totalXp: true,
            longestStreak: true,
            totalMoneySaved: true,
          },
        },
      },
    });

    if (!user || !user) return reply.status(404).send({ message: 'User not found' });
    return reply.send({ user });
  });
}
