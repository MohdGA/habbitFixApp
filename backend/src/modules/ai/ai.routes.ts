import type { FastifyInstance } from 'fastify';
import { aiService } from './ai.service.js';
import { validateBody } from '../../shared/middleware/validate.js';
import { ChatSchema } from './ai.schema.js';

export async function aiRoutes(app: FastifyInstance) {
  const auth = { onRequest: [app.authenticate] };

  app.post('/chat', {
    ...auth,
    config: { rateLimit: { max: 20, timeWindow: '1m' } },
  }, async (req, reply) => {
    const dto = validateBody(ChatSchema, req.body);
    const result = await aiService.chatJson(req.user.sub, dto.message);
    return reply.send(result);
  });

  app.get('/suggestions', auth, async (req, reply) => {
    const suggestions = await aiService.getSuggestions(req.user.sub);
    return reply.send({ suggestions });
  });

  app.get('/weekly-summary', {
    ...auth,
    config: { rateLimit: { max: 5, timeWindow: '1h' } },
  }, async (req, reply) => {
    const summary = await aiService.getWeeklySummary(req.user.sub);
    return reply.send({ summary });
  });

  app.delete('/history', auth, async (req, reply) => {
    await aiService.clearHistory(req.user.sub);
    return reply.code(204).send();
  });

  app.get('/conversation', auth, async (req, reply) => {
    const data = await aiService.getHistory(req.user.sub);
    return reply.send({ data });
  });
}
