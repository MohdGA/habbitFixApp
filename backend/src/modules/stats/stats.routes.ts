import type { FastifyInstance } from 'fastify';
import { xpService } from './xp.service.js';
import { badgeService } from './badge.service.js';
import { prisma } from '../../config/prisma.js';

export async function statsRoutes(app: FastifyInstance) {
  const auth = { onRequest: [app.authenticate] };

  // GET /stats
  app.get('/', auth, async (req, reply) => {
    const stats = await xpService.getStats(req.user.sub);
    return reply.send({ stats });
  });

  // GET /stats/badges
  app.get('/badges', auth, async (req, reply) => {
    const badges = await badgeService.getUserBadges(req.user.sub);
    return reply.send({ badges });
  });

  // GET /stats/overview
  app.get('/overview', auth, async (req, reply) => {
    const userId = req.user.sub;

    const [stats, habits, recentCheckins] = await Promise.all([
      prisma.userStats.findUnique({ where: { userId } }),
      prisma.habit.findMany({
        where: { userId, isArchived: false },
        include: { streaks: true, savingsGoal: true },
      }),
      prisma.checkin.findMany({
        where: {
          userId,
          date: { gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) },
          success: true,
        },
        select: { date: true },
      }),
    ]);

    const totalSaved = habits.reduce((acc, h) => acc + (h.savingsGoal?.currentSavings ?? 0), 0);
    const longestStreak = habits.reduce((acc, h) => Math.max(acc, h.streaks?.[0]?.longestStreak ?? 0), 0);
    const currentBestStreak = habits.reduce((acc, h) => Math.max(acc, h.streaks?.[0]?.currentStreak ?? 0), 0);

    return reply.send({
      overview: {
        stats,
        totalSaved,
        longestStreak,
        currentBestStreak,
        activeHabits: habits.length,
        checkinDaysThisWeek: new Set(recentCheckins.map(c => c.date.toISOString().split('T')[0])).size,
      },
    });
  });
}
