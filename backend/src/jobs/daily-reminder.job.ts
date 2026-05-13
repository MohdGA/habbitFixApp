import { Worker, type ConnectionOptions } from 'bullmq';
import { prisma } from '../config/prisma.js';
import { env } from '../config/env.js';
import { sendPushNotification } from '../shared/utils/fcm.js';

export function dailyReminderWorker(connection: ConnectionOptions): Worker {
  return new Worker(
    'daily-reminder',
    async (job) => {
      job.log('Sending daily reminders...');

      const today = new Date();
      today.setHours(0, 0, 0, 0);

      const users = await prisma.user.findMany({
        where: {
          isActive: true,
          fcmToken: { not: null },
          notificationPrefs: { streakAlerts: true },
        },
        include: {
          habits: {
            where: { isArchived: false, reminderTime: { not: null } },
            include: {
              streaks: true,
              checkins: {
                where: { date: today },
                take: 1,
              },
            },
          },
        },
      });

      let sent = 0;

      for (const user of users) {
        if (!user.fcmToken) continue;

        // Find habits not yet checked in today
        const pending = user.habits.filter(h => h.checkins.length === 0);
        if (pending.length === 0) continue;

        const streakAtRisk = user.habits.find(
          h => (h.streaks?.[0]?.currentStreak ?? 0) >= 3 && h.checkins.length === 0,
        );

        const title = streakAtRisk
          ? `🔥 ${streakAtRisk.streaks?.[0]?.currentStreak ?? 0}d streak at risk!`
          : `⏰ ${pending.length} habit${pending.length > 1 ? 's' : ''} pending`;

        const body = streakAtRisk
          ? `Don't let your ${streakAtRisk.name} streak break. Check in now!`
          : `Complete today's habits to keep your progress going.`;

        try {
          await sendPushNotification(user.fcmToken, { title, body });
          sent++;
        } catch (err) {
          console.error(`Push failed for user ${user.id}:`, err);
        }
      }

      job.log(`Daily reminders sent: ${sent}/${users.length}`);
      return { total: users.length, sent };
    },
    {
      connection,
      prefix: env.BULLMQ_PREFIX,
      concurrency: 2,
    },
  );
}
