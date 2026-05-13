import Redis from 'ioredis';
import { env } from './env.js';

let redisInstance: Redis | null = null;

export function getRedis(): Redis {
  if (!redisInstance) {
    redisInstance = new Redis(env.REDIS_URL, {
      maxRetriesPerRequest: null,
      enableReadyCheck: false,
      retryStrategy(times) {
        if (times > 10) return null;
        return Math.min(times * 500, 10000);
      },
    });

    redisInstance.on('connect', () => {
      console.log('Redis connected');
    });

    redisInstance.on('error', (err) => {
      console.error('Redis error:', err.message);
    });
  }
  return redisInstance;
}

export async function closeRedis(): Promise<void> {
  if (redisInstance) {
    await redisInstance.quit().catch(() => {});
    redisInstance = null;
  }
}

// ─── Key helpers ─────────────────────────────────────────────────────────────

export const RedisKeys = {
  refreshFamily: (family: string) => `refresh:family:${family}`,
  emailVerify: (token: string) => `email:verify:${token}`,
  passwordReset: (token: string) => `password:reset:${token}`,
  rateLimit: (ip: string, route: string) => `rate:${route}:${ip}`,
  aiHistory: (userId: string) => `ai:history:${userId}`,
  aiContext: (userId: string) => `ai:ctx:${userId}`,
  aiSuggestions: (userId: string) => `ai:suggestions:${userId}`,
  freezeCheck: (userId: string, date: string) => `freeze:${userId}:${date}`,
  streakLock: (habitId: string) => `lock:streak:${habitId}`,
};
