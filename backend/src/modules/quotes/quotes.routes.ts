import type { FastifyInstance } from 'fastify';
import { prisma } from '../../config/prisma.js';

export async function quoteRoutes(app: FastifyInstance) {
  // GET /quotes/daily  — public
  app.get('/daily', async (_req, reply) => {
    const count = await prisma.quote.count();
    if (count === 0) return reply.send({ quote: { text: 'Every day is a new beginning.', author: 'Unknown' } });

    const skip = Math.floor(Math.random() * count);
    const [quote] = await prisma.quote.findMany({ take: 1, skip });
    return reply.send({ quote });
  });

  // GET /quotes  — all (auth)
  app.get('/', { onRequest: [app.authenticate] }, async (req, reply) => {
    const { tag } = req.query as { tag?: string };

    const quotes = await prisma.quote.findMany({
      where: tag ? { tags: { has: tag } } : {},
      orderBy: { createdAt: 'desc' },
      take: 50,
    });

    return reply.send({ quotes });
  });
}
