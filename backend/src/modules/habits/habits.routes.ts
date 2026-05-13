import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { habitsService } from './habits.service.js';
import { validateBody } from '../../shared/middleware/validate.js';

const CreateHabitBodySchema = z.object({
  name: z.string().min(1).max(100),
  emoji: z.string().optional(),
  type: z.enum(['QUIT', 'REDUCE', 'BUILD']),
  frequency: z.enum(['DAILY', 'WEEKLY', 'CUSTOM']).optional(),
  customDays: z.array(z.number().int().min(0).max(6)).optional(),
  targetAmount: z.number().positive().optional(),
  unit: z.string().optional(),
  costPerUnit: z.number().nonnegative().optional(),
  reminderTime: z.string().regex(/^\d{2}:\d{2}$/).optional(),
  color: z.string().regex(/^#[0-9A-F]{6}$/i).optional(),
});

const UpdateHabitBodySchema = CreateHabitBodySchema.partial().extend({
  isArchived: z.boolean().optional(),
});

export async function habitRoutes(app: FastifyInstance) {
  const auth = { onRequest: [app.authenticate] };

  // GET /habits
  app.get('/', auth, async (req, reply) => {
    const query = req.query as any;
    const habits = await habitsService.findAll(req.user.sub, query.archived === 'true');
    return reply.send({ habits });
  });

  // POST /habits
  app.post('/', auth, async (req, reply) => {
    const dto = validateBody(CreateHabitBodySchema, req.body);
    const habit = await habitsService.create(req.user.sub, dto);
    return reply.status(201).send({ habit });
  });

  // GET /habits/:id
  app.get('/:id', auth, async (req, reply) => {
    const { id } = req.params as { id: string };
    const habit = await habitsService.findOne(req.user.sub, id);
    return reply.send({ habit });
  });

  // PATCH /habits/:id
  app.patch('/:id', auth, async (req, reply) => {
    const { id } = req.params as { id: string };
    const dto = validateBody(UpdateHabitBodySchema, req.body);
    const habit = await habitsService.update(req.user.sub, id, dto);
    return reply.send({ habit });
  });

  // DELETE /habits/:id/archive
  app.post('/:id/archive', auth, async (req, reply) => {
    const { id } = req.params as { id: string };
    await habitsService.archive(req.user.sub, id);
    return reply.send({ message: 'Habit archived' });
  });

  // DELETE /habits/:id
  app.delete('/:id', auth, async (req, reply) => {
    const { id } = req.params as { id: string };
    const result = await habitsService.delete(req.user.sub, id);
    return reply.send(result);
  });
}
