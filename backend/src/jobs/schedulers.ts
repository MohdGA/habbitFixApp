import { Queue } from 'bullmq';
import { env } from '../config/env.js';

function redisConnection() {
  const url = new URL(env.REDIS_URL);
  return {
    host: url.hostname,
    port: Number(url.port || 6379),
    username: url.username || undefined,
    password: url.password || undefined,
  };
}

export async function streakScheduler(): Promise<void> {
  const conn = redisConnection();

  const streakQueue = new Queue('streak-check', { connection: conn, prefix: env.BULLMQ_PREFIX });
  const weeklyQueue = new Queue('weekly-report', { connection: conn, prefix: env.BULLMQ_PREFIX });
  const freezeQueue = new Queue('freeze-earn', { connection: conn, prefix: env.BULLMQ_PREFIX });
  const reminderQueue = new Queue('daily-reminder', { connection: conn, prefix: env.BULLMQ_PREFIX });

  // Spec: streakHealthCheck at 23:55 daily (catches missed check-ins before midnight rollover)
  await streakQueue.upsertJobScheduler('daily-streak-check', { pattern: '55 23 * * *' }, {
    name: 'check-all-streaks',
    data: {},
  });

  // Spec: weeklyDigest Sunday 9 AM
  await weeklyQueue.upsertJobScheduler('weekly-report', { pattern: '0 9 * * 0' }, {
    name: 'send-weekly-reports',
    data: {},
  });

  // Spec: freezeExpiryReminder 8 AM daily
  await freezeQueue.upsertJobScheduler('daily-freeze-check', { pattern: '0 8 * * *' }, {
    name: 'award-freeze-tokens',
    data: {},
  });

  // Daily habit reminders 8 PM
  await reminderQueue.upsertJobScheduler('daily-reminders', { pattern: '0 20 * * *' }, {
    name: 'send-daily-reminders',
    data: {},
  });
}
