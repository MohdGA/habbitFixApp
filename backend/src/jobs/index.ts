import { Worker } from 'bullmq';
import { env } from '../config/env.js';
import { streakCheckWorker } from './streak-check.job.js';
import { weeklyReportWorker } from './weekly-report.job.js';
import { freezeEarnWorker } from './freeze-earn.job.js';
import { dailyReminderWorker } from './daily-reminder.job.js';
import { streakScheduler } from './schedulers.js';

const workers: Worker[] = [];

function redisConnection() {
  const url = new URL(env.REDIS_URL);
  return {
    host: url.hostname,
    port: Number(url.port || 6379),
    username: url.username || undefined,
    password: url.password || undefined,
  };
}

export async function startWorkers(): Promise<void> {
  const conn = redisConnection();

  workers.push(
    streakCheckWorker(conn),
    weeklyReportWorker(conn),
    freezeEarnWorker(conn),
    dailyReminderWorker(conn),
  );

  await streakScheduler();

  console.log(`✅ ${workers.length} BullMQ workers started`);
}

export async function stopWorkers(): Promise<void> {
  await Promise.allSettled(workers.map(w => w.close()));
  console.log('BullMQ workers stopped');
}
