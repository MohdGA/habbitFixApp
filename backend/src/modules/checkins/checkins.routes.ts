import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { checkinsService } from './checkins.service.js';
import { validateBody } from '../../shared/middleware/validate.js';

const CreateCheckinSchema = z.object({
  habitId: z.string().uuid(),
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
  success: z.boolean().optional().default(true),
  amount: z.number().nonnegative().optional(),
  mood: z.number().int().min(1).max(5).optional(),
  note: z.string().max(500).optional(),
});

export async function checkinRoutes(app: FastifyInstance) {
  const auth = { onRequest: [app.authenticate] };

  // POST /checkins
  app.post('/', auth, async (req, reply) => {
    const dto = validateBody(CreateCheckinSchema, req.body);
    const result = await checkinsService.create(req.user.sub, dto);
    return reply.status(201).send(result);
  });

  // GET /checkins/heatmap
  app.get('/heatmap', auth, async (req, reply) => {
    const data = await checkinsService.getHeatmapData(req.user.sub);
    return reply.send({ heatmap: data });
  });

  // GET /checkins?habitId=xxx&from=YYYY-MM-DD&to=YYYY-MM-DD
  app.get('/', auth, async (req, reply) => {
    const { habitId, from, to } = req.query as any;
    if (!habitId) {
      return reply.status(400).send({ message: 'habitId is required' });
    }
    const checkins = await checkinsService.findByHabit(req.user.sub, habitId, from, to);
    return reply.send({ checkins });
  });
}
