import { Worker, type ConnectionOptions } from 'bullmq';
import { prisma } from '../config/prisma.js';
import { env } from '../config/env.js';

export function streakCheckWorker(connection: ConnectionOptions): Worker {
  return new Worker(
    'streak-check',
    async (job) => {
      job.log('Running daily streak check...');

      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const yesterday = new Date(today.getTime() - 24 * 60 * 60 * 1000);

      // Find all active habits with streaks
      const activeStreaks = await prisma.streak.findMany({
        where: {
          currentStreak: { gt: 0 },
          lastCheckinAt: { lt: today },
        },
        include: {
          habit: {
            select: { id: true, userId: true, frequency: true, customDays: true },
          },
        },
      });

      let brokent = 0;
      for (const streak of activeStreaks) {
        const { habit } = streak;

        // Skip non-daily habits if today wasn't a scheduled day
        if (habit.frequency === 'CUSTOM' && habit.customDays.length > 0) {
          const dayOfWeek = yesterday.getDay();
          if (!habit.customDays.includes(dayOfWeek)) continue;
        }

        if (habit.frequency === 'WEEKLY') continue; // Weekly habits are more forgiving

        // Check if there was a checkin yesterday
        const checkin = await prisma.checkin.findUnique({
          where: { habitId_date: { habitId: habit.id, date: yesterday } },
        });

        if (!checkin || !checkin.success) {
          // Check for freeze token usage
          const freezeUsed = await prisma.freezeToken.findFirst({
            where: { habitId: habit.id, usedAt: { gte: yesterday, lt: today } },
          });

          if (!freezeUsed) {
            // Break the streak
            await prisma.streak.update({
              where: { habitId: habit.id },
              data: { currentStreak: 0 },
            });
            brokent++;
          }
        }
      }

      job.log(`Streak check complete. Broke ${brokent} streaks.`);
      return { processed: activeStreaks.length, broken: brokent };
    },
    {
      connection,
      prefix: env.BULLMQ_PREFIX,
      concurrency: 1,
    },
  );
}
