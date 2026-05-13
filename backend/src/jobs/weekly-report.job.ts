import { Worker, type ConnectionOptions } from 'bullmq';
import { prisma } from '../config/prisma.js';
import { env } from '../config/env.js';
import Groq from 'groq-sdk';
import { sendWeeklyReportEmail } from '../shared/utils/email.js';

const client = new Groq({ apiKey: env.GROQ_API_KEY });

export function weeklyReportWorker(connection: ConnectionOptions): Worker {
  return new Worker(
    'weekly-report',
    async (job) => {
      job.log('Sending weekly reports...');

      const users = await prisma.user.findMany({
        where: {
          isActive: true,
          emailVerified: true,
          notificationPrefs: { weeklyReport: true },
        },
        include: {
          notificationPrefs: true,
          stats: true,
          habits: {
            where: { isArchived: false },
            include: { streaks: true },
          },
        },
      });

      let sent = 0;

      for (const user of users) {
        try {
          const weekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);

          const checkins = await prisma.checkin.findMany({
            where: { userId: user.id, date: { gte: weekAgo }, success: true },
          });

          const longestStreak = user.habits.reduce(
            (acc, h) => Math.max(acc, h.streaks?.[0]?.longestStreak ?? 0), 0,
          );

          // Generate AI summary
          const response = await client.chat.completions.create({
            model: env.GROQ_MODEL,
            max_tokens: 300,
            messages: [{
              role: 'user',
              content: `Write a brief, encouraging weekly report for ${user.displayName} who:
- Checked in ${checkins.length} times this week
- Has ${user.habits.length} active habits
- Best streak: ${longestStreak} days
- Level: ${user.stats?.level ?? 1}

Keep it warm, specific, motivating. 3-4 sentences max.`,
            }],
          });

          const summary = response.choices[0]?.message?.content
            ?? `Great job this week, ${user.displayName}!`;

          await sendWeeklyReportEmail(user.email, user.displayName, {
            checkinCount: checkins.length,
            longestStreak,
            level: user.stats?.level ?? 1,
            summary,
          });

          sent++;
        } catch (err) {
          console.error(`Failed to send weekly report to ${user.email}:`, err);
        }
      }

      job.log(`Weekly reports sent: ${sent}/${users.length}`);
      return { total: users.length, sent };
    },
    {
      connection,
      prefix: env.BULLMQ_PREFIX,
      concurrency: 2,
    },
  );
}
