import type { FastifyInstance } from 'fastify';
import { prisma } from '../../config/prisma.js';

export async function healthRoutes(app: FastifyInstance) {
  const auth = { onRequest: [app.authenticate] };

  // GET /health-milestones?type=smoking&daysSince=21
  app.get('/', auth, async (req, reply) => {
    const { type = 'smoking', daysSince } = req.query as {
      type?: string;
      daysSince?: string;
    };

    const milestones = await prisma.healthMilestone.findMany({
      where: { habitType: type },
      orderBy: { dayMark: 'asc' },
    });

    const days = daysSince ? parseFloat(daysSince) : 0;

    const enriched = milestones.map(m => ({
      ...m,
      reached: days >= m.dayMark,
      daysUntil: days >= m.dayMark ? 0 : Math.ceil(m.dayMark - days),
      isCurrent: days >= m.dayMark && !milestones.some(
        other => other.dayMark > m.dayMark && days >= other.dayMark,
      ),
    }));

    return reply.send({ milestones: enriched });
  });
}
