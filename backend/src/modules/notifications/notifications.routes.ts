import type { FastifyInstance } from 'fastify';
import { prisma } from '../../config/prisma.js';

export async function notificationRoutes(app: FastifyInstance) {
  const auth = { onRequest: [app.authenticate] };

  // GET /notifications
  app.get('/', auth, async (req, reply) => {
    const { unread } = req.query as { unread?: string };

    const notifications = await prisma.notification.findMany({
      where: {
        userId: req.user.sub,
        ...(unread === 'true' ? { read: false } : {}),
      },
      orderBy: { sentAt: 'desc' },
      take: 50,
    });

    const unreadCount = await prisma.notification.count({
      where: { userId: req.user.sub, read: false },
    });

    return reply.send({ notifications, unreadCount });
  });

  // PATCH /notifications/:id/read
  app.patch('/:id/read', auth, async (req, reply) => {
    const { id } = req.params as { id: string };
    await prisma.notification.updateMany({
      where: { id, userId: req.user.sub },
      data: { read: true, readAt: new Date() },
    });
    return reply.send({ message: 'Notification marked as read' });
  });

  // POST /notifications/read-all
  app.post('/read-all', auth, async (req, reply) => {
    await prisma.notification.updateMany({
      where: { userId: req.user.sub, read: false },
      data: { read: true, readAt: new Date() },
    });
    return reply.send({ message: 'All notifications marked as read' });
  });

  // DELETE /notifications/:id
  app.delete('/:id', auth, async (req, reply) => {
    const { id } = req.params as { id: string };
    await prisma.notification.deleteMany({
      where: { id, userId: req.user.sub },
    });
    return reply.send({ message: 'Notification deleted' });
  });
}
