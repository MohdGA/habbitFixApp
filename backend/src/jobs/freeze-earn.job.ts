import { Worker, type ConnectionOptions } from 'bullmq';
import { prisma } from '../config/prisma.js';
import { env } from '../config/env.js';

// Users earn 1 freeze token every 7 consecutive days of ANY habit checkin
export function freezeEarnWorker(connection: ConnectionOptions): Worker {
  return new Worker(
    'freeze-earn',
    async (job) => {
      job.log('Checking freeze token eligibility...');

      const users = await prisma.user.findMany({
        where: { isActive: true },
        select: { id: true },
      });

      let awarded = 0;

      for (const user of users) {
        const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);

        const uniqueCheckinDays = await prisma.checkin.findMany({
          where: {
            userId: user.id,
            date: { gte: sevenDaysAgo },
            success: true,
          },
          select: { date: true },
          distinct: ['date'],
        });

        if (uniqueCheckinDays.length >= 7) {
          // Award a freeze token (expires in 30 days)
          const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);
          await prisma.freezeToken.create({
            data: { userId: user.id, expiresAt },
          });
          awarded++;

          // Notify user
          await prisma.notification.create({
            data: {
              userId: user.id,
              title: '❄️ Freeze Token Earned!',
              body: "You've checked in 7 days in a row — you earned a freeze token! Use it to protect your streak on a tough day.",
            },
          });
        }
      }

      job.log(`Awarded ${awarded} freeze tokens`);
      return { usersChecked: users.length, tokensAwarded: awarded };
    },
    {
      connection,
      prefix: env.BULLMQ_PREFIX,
      concurrency: 1,
    },
  );
}
