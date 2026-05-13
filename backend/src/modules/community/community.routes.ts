import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { prisma } from '../../config/prisma.js';
import { validateBody } from '../../shared/middleware/validate.js';

const CreatePostSchema = z.object({
  type: z.enum(['MILESTONE', 'TIP', 'STRUGGLE', 'WIN']),
  title: z.string().min(1).max(200),
  content: z.string().min(1).max(2000),
  habitName: z.string().optional(),
  streak: z.number().int().nonnegative().optional(),
  isPublic: z.boolean().optional().default(true),
});

const CreateCommentSchema = z.object({
  content: z.string().min(1).max(500),
});

export async function communityRoutes(app: FastifyInstance) {
  const auth = { onRequest: [app.authenticate] };

  // GET /community
  app.get('/', auth, async (req, reply) => {
    const { type, page = '1', limit = '20' } = req.query as any;

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const posts = await prisma.communityPost.findMany({
      where: {
        isPublic: true,
        ...(type ? { type } : {}),
      },
      include: {
        user: { select: { username: true, displayName: true, avatarUrl: true } },
        _count: { select: { likes: true, comments: true } },
        likes: { where: { userId: req.user.sub }, select: { id: true } },
      },
      orderBy: { createdAt: 'desc' },
      skip,
      take: parseInt(limit),
    });

    const result = posts.map(({ likes, ...p }) => ({
      ...p,
      userLiked: likes.length > 0,
    }));

    return reply.send({ posts: result });
  });

  // POST /community
  app.post('/', auth, async (req, reply) => {
    const dto = validateBody(CreatePostSchema, req.body);

    const post = await prisma.communityPost.create({
      data: { userId: req.user.sub, ...dto },
      include: {
        user: { select: { username: true, displayName: true, avatarUrl: true } },
        _count: { select: { likes: true, comments: true } },
      },
    });

    return reply.status(201).send({ post });
  });

  // POST /community/:id/like
  app.post('/:id/like', auth, async (req, reply) => {
    const { id } = req.params as { id: string };

    const existing = await prisma.communityLike.findUnique({
      where: { userId_postId: { userId: req.user.sub, postId: id } },
    });

    if (existing) {
      await prisma.communityLike.delete({
        where: { userId_postId: { userId: req.user.sub, postId: id } },
      });
      return reply.send({ liked: false });
    }

    await prisma.communityLike.create({
      data: { userId: req.user.sub, postId: id },
    });
    return reply.send({ liked: true });
  });

  // GET /community/:id/comments
  app.get('/:id/comments', auth, async (req, reply) => {
    const { id } = req.params as { id: string };

    const comments = await prisma.communityComment.findMany({
      where: { postId: id },
      include: {
        user: { select: { username: true, displayName: true, avatarUrl: true } },
      },
      orderBy: { createdAt: 'asc' },
    });

    return reply.send({ comments });
  });

  // POST /community/:id/comments
  app.post('/:id/comments', auth, async (req, reply) => {
    const { id } = req.params as { id: string };
    const dto = validateBody(CreateCommentSchema, req.body);

    const comment = await prisma.communityComment.create({
      data: { userId: req.user.sub, postId: id, content: dto.content },
      include: {
        user: { select: { username: true, displayName: true, avatarUrl: true } },
      },
    });

    return reply.status(201).send({ comment });
  });

  // DELETE /community/:id
  app.delete('/:id', auth, async (req, reply) => {
    await prisma.communityPost.deleteMany({
      where: { id: req.params as any, userId: req.user.sub },
    });
    return reply.send({ message: 'Post deleted' });
  });
}
