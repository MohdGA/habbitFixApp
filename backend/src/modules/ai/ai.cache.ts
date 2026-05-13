import crypto from 'crypto';
import { getRedis } from '../../config/redis.js';
import { Intent } from './ai.classifier.js';

const CACHEABLE_INTENTS: Intent[] = [
  Intent.PROGRESS_ANALYSIS,
  Intent.SAVINGS_QUERY,
  Intent.STREAK_QUERY,
];

function isCacheable(intent: Intent): boolean {
  return CACHEABLE_INTENTS.includes(intent);
}

function cacheKey(userId: string, intent: Intent): string {
  const window = Math.floor(Date.now() / 300000);
  const hash = crypto
    .createHash('sha256')
    .update(`${userId}:${intent}:${window}`)
    .digest('hex');
  return `ai:cache:${hash}`;
}

export async function getCachedResponse(
  userId: string,
  intent: Intent,
): Promise<string | null> {
  if (!isCacheable(intent)) return null;
  const redis = getRedis();
  return redis.get(cacheKey(userId, intent));
}

export async function setCachedResponse(
  userId: string,
  intent: Intent,
  response: string,
): Promise<void> {
  if (!isCacheable(intent)) return;
  const redis = getRedis();
  await redis.setex(cacheKey(userId, intent), 300, response);
}
