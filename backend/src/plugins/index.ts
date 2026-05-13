import type { FastifyInstance } from 'fastify';
import cors from '@fastify/cors';
import helmet from '@fastify/helmet';
import cookie from '@fastify/cookie';
import multipart from '@fastify/multipart';
import swagger from '@fastify/swagger';
import swaggerUi from '@fastify/swagger-ui';
import rateLimit from '@fastify/rate-limit';
import { getRedis } from '../config/redis.js';
import { env } from '../config/env.js';
import { registerJwt } from './jwt.plugin.js';

export async function registerPlugins(app: FastifyInstance): Promise<void> {
  // Security headers
  await app.register(helmet, {
    contentSecurityPolicy: false,
    crossOriginEmbedderPolicy: false,
  });

  // CORS
  await app.register(cors, {
    origin: env.NODE_ENV === 'development'
      ? [/^http:\/\/localhost(:\d+)?$/]
      : [env.CLIENT_URL, 'http://localhost:3000'],
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  });

  // Cookies
  await app.register(cookie, {
    secret: env.REFRESH_TOKEN_SECRET,
  });

  // Multipart (file uploads)
  await app.register(multipart, {
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  });

  // Rate limiting with Redis store
  await app.register(rateLimit, {
    global: true,
    max: env.RATE_LIMIT_MAX,
    timeWindow: env.RATE_LIMIT_WINDOW_MS,
    redis: getRedis(),
    keyGenerator: (req) => req.ip,
    errorResponseBuilder: () => ({
      statusCode: 429,
      error: 'Too Many Requests',
      message: 'You are being rate limited. Please slow down.',
    }),
  });

  // JWT (RS256)
  await registerJwt(app);

  // Swagger docs
  await app.register(swagger, {
    openapi: {
      info: {
        title: 'Quitly API',
        description: 'Habit-quitting and streak-tracking API',
        version: '1.0.0',
      },
      components: {
        securitySchemes: {
          bearerAuth: {
            type: 'http',
            scheme: 'bearer',
            bearerFormat: 'JWT',
          },
        },
      },
      security: [{ bearerAuth: [] }],
    },
  });

  await app.register(swaggerUi, {
    routePrefix: '/docs',
    uiConfig: { deepLinking: true },
  });

  // Global error handler
  app.setErrorHandler((error, req, reply) => {
    app.log.error({ err: error, url: req.url, method: req.method });

    if (error.statusCode) {
      return reply.status(error.statusCode).send({
        statusCode: error.statusCode,
        error: error.name,
        message: error.message,
      });
    }

    if (error.validation) {
      return reply.status(400).send({
        statusCode: 400,
        error: 'Validation Error',
        message: 'Invalid request data',
        details: error.validation,
      });
    }

    return reply.status(500).send({
      statusCode: 500,
      error: 'Internal Server Error',
      message: 'An unexpected error occurred',
    });
  });

  // Not found handler
  app.setNotFoundHandler((req, reply) => {
    reply.status(404).send({
      statusCode: 404,
      error: 'Not Found',
      message: `Route ${req.method} ${req.url} not found`,
    });
  });
}
