import Fastify from 'fastify';
import { env } from './config/env.js';
import { connectDb, disconnectDb } from './config/prisma.js';
import { closeRedis } from './config/redis.js';
import { registerPlugins } from './plugins/index.js';
import { registerRoutes } from './modules/index.js';
import { startWorkers, stopWorkers } from './jobs/index.js';

const app = Fastify({
  logger: {
    level: env.LOG_LEVEL,
    transport: env.NODE_ENV === 'development'
      ? { target: 'pino-pretty', options: { colorize: true } }
      : undefined,
  },
  trustProxy: true,
  disableRequestLogging: false,
});

async function bootstrap() {
  try {
    // Register plugins (cors, helmet, jwt, rate-limit, swagger, etc.)
    await registerPlugins(app);

    // Register all route modules
    await registerRoutes(app);

    // Health check
    app.get('/health', async () => ({
      status: 'ok',
      env: env.NODE_ENV,
      timestamp: new Date().toISOString(),
    }));

    // Start server first so healthcheck can pass immediately
    await app.listen({ port: env.PORT, host: env.HOST });
    app.log.info(`🚀 Quitly API running at http://${env.HOST}:${env.PORT}`);
    app.log.info(`📚 API docs at http://${env.HOST}:${env.PORT}/docs`);

    // Connect database after server is listening
    await connectDb();
    app.log.info('✅ Database connected');

    // Start BullMQ workers (optional — Redis might be unavailable in dev)
    try {
      await startWorkers();
      app.log.info('✅ Background workers started');
    } catch (err) {
      app.log.warn({ err }, '⚠️ BullMQ workers not started (Redis may be unavailable)');
    }
  } catch (err) {
    app.log.error(err);
    process.exit(1);
  }
}

// Graceful shutdown
const shutdown = async (signal: string) => {
  app.log.info(`Received ${signal}, shutting down gracefully...`);
  await stopWorkers();
  await app.close();
  await disconnectDb();
  await closeRedis();
  process.exit(0);
};

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));

bootstrap();
