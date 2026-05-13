import type { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import fjwt from '@fastify/jwt';
import { jwtKeys, env } from '../config/env.js';

export interface JwtPayload {
  sub: string; // userId
  email: string;
  username: string;
  iat?: number;
  exp?: number;
}

declare module '@fastify/jwt' {
  interface FastifyJWT {
    payload: JwtPayload;
    user: JwtPayload;
  }
}

declare module 'fastify' {
  interface FastifyInstance {
    authenticate: (req: FastifyRequest, reply: FastifyReply) => Promise<void>;
    optionalAuth: (req: FastifyRequest, reply: FastifyReply) => Promise<void>;
  }
}

export async function registerJwt(app: FastifyInstance): Promise<void> {
  await app.register(fjwt, {
    secret: {
      private: jwtKeys.private,
      public: jwtKeys.public,
    },
    sign: {
      algorithm: 'RS256',
      expiresIn: env.JWT_ACCESS_EXPIRES_IN,
    },
    verify: {
      algorithms: ['RS256'],
    },
  });

  // Decorate with authenticate hook
  app.decorate('authenticate', async (req: FastifyRequest, reply: FastifyReply) => {
    try {
      await req.jwtVerify();
    } catch (err) {
      reply.status(401).send({
        statusCode: 401,
        error: 'Unauthorized',
        message: 'Invalid or expired token',
      });
    }
  });

  // Optional auth (doesn't fail if no token)
  app.decorate('optionalAuth', async (req: FastifyRequest, _reply: FastifyReply) => {
    try {
      await req.jwtVerify();
    } catch {
      // continue without user
    }
  });
}
