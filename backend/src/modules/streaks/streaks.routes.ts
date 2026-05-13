import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { streaksService } from './streaks.service.js';
import { validateBody } from '../../shared/middleware/validate.js';

const UseFreezeSchema = z.object({
  habitId: z.string().uuid(),
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
});

export async function streakRoutes(app: FastifyInstance) {
  const auth = { onRequest: [app.authenticate] };

  // GET /streaks/freeze-tokens
  app.get('/freeze-tokens', auth, async (req, reply) => {
    const tokens = await streaksService.getFreezeTokens(req.user.sub);
    return reply.send({ tokens, count: tokens.length });
  });

  // POST /streaks/freeze
  app.post('/freeze', auth, async (req, reply) => {
    const dto = validateBody(UseFreezeSchema, req.body);
    const result = await streaksService.useFreeze(req.user.sub, dto.habitId, new Date(dto.date));
    return reply.send(result);
  });

  // GET /streaks/:habitId
  app.get('/:habitId', auth, async (req, reply) => {
    const { habitId } = req.params as { habitId: string };
    const streak = await streaksService.getStreakForHabit(req.user.sub, habitId);
    return reply.send({ streak });
  });
}
