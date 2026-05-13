import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { prisma } from '../../config/prisma.js';
import { validateBody } from '../../shared/middleware/validate.js';

const CreateGoalSchema = z.object({
  habitId: z.string().uuid(),
  goalName: z.string().min(1).max(100),
  goalAmount: z.number().positive(),
  emoji: z.string().optional(),
  deadline: z.string().datetime().optional(),
});

const UpdateGoalSchema = CreateGoalSchema.partial().omit({ habitId: true });

export async function savingsRoutes(app: FastifyInstance) {
  const auth = { onRequest: [app.authenticate] };

  // GET /savings
  app.get('/', auth, async (req, reply) => {
    const goals = await prisma.savingsGoal.findMany({
      where: { habit: { userId: req.user.sub } },
      include: {
        habit: {
          select: { name: true, emoji: true, type: true, costPerUnit: true, unit: true },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    const totalSaved = goals.reduce((acc, g) => acc + g.currentSavings, 0);
    return reply.send({ goals, totalSaved });
  });

  // POST /savings
  app.post('/', auth, async (req, reply) => {
    const dto = validateBody(CreateGoalSchema, req.body);

    // Validate habit ownership
    const habit = await prisma.habit.findFirst({
      where: { id: dto.habitId, userId: req.user.sub },
    });
    if (!habit) return reply.status(404).send({ message: 'Habit not found' });

    const goal = await prisma.savingsGoal.create({
      data: {
        habitId: dto.habitId,
        goalName: dto.goalName,
        goalAmount: dto.goalAmount,
        emoji: dto.emoji ?? '🎯',
        deadline: dto.deadline ? new Date(dto.deadline) : undefined,
      },
    });

    return reply.status(201).send({ goal });
  });

  // PATCH /savings/:id
  app.patch('/:id', auth, async (req, reply) => {
    const { id } = req.params as { id: string };
    const dto = validateBody(UpdateGoalSchema, req.body);

    // Verify ownership
    const existing = await prisma.savingsGoal.findFirst({
      where: { id, habit: { userId: req.user.sub } },
    });
    if (!existing) return reply.status(404).send({ message: 'Savings goal not found' });

    const goal = await prisma.savingsGoal.update({
      where: { id },
      data: {
        ...(dto.goalName && { goalName: dto.goalName }),
        ...(dto.goalAmount && { goalAmount: dto.goalAmount }),
        ...(dto.emoji && { emoji: dto.emoji }),
        ...(dto.deadline && { deadline: new Date(dto.deadline) }),
      },
    });

    return reply.send({ goal });
  });

  // DELETE /savings/:id
  app.delete('/:id', auth, async (req, reply) => {
    const { id } = req.params as { id: string };
    await prisma.savingsGoal.deleteMany({
      where: { id, habit: { userId: req.user.sub } },
    });
    return reply.send({ message: 'Savings goal deleted' });
  });
}
