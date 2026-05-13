import type { FastifyInstance } from 'fastify';
import { authRoutes } from './auth/auth.routes.js';
import { userRoutes } from './users/users.routes.js';
import { habitRoutes } from './habits/habits.routes.js';
import { checkinRoutes } from './checkins/checkins.routes.js';
import { streakRoutes } from './streaks/streaks.routes.js';
import { savingsRoutes } from './savings/savings.routes.js';
import { statsRoutes } from './stats/stats.routes.js';
import { notificationRoutes } from './notifications/notifications.routes.js';
import { aiRoutes } from './ai/ai.routes.js';
import { communityRoutes } from './community/community.routes.js';
import { quoteRoutes } from './quotes/quotes.routes.js';
import { healthRoutes } from './health/health.routes.js';

export async function registerRoutes(app: FastifyInstance): Promise<void> {
  const prefix = '/api/v1';

  await app.register(authRoutes, { prefix: `${prefix}/auth` });
  await app.register(userRoutes, { prefix: `${prefix}/users` });
  await app.register(habitRoutes, { prefix: `${prefix}/habits` });
  await app.register(checkinRoutes, { prefix: `${prefix}/checkins` });
  await app.register(streakRoutes, { prefix: `${prefix}/streaks` });
  await app.register(savingsRoutes, { prefix: `${prefix}/savings` });
  await app.register(statsRoutes, { prefix: `${prefix}/stats` });
  await app.register(notificationRoutes, { prefix: `${prefix}/notifications` });
  await app.register(aiRoutes, { prefix: `${prefix}/ai` });
  await app.register(communityRoutes, { prefix: `${prefix}/community` });
  await app.register(quoteRoutes, { prefix: `${prefix}/quotes` });
  await app.register(healthRoutes, { prefix: `${prefix}/health-milestones` });
}
