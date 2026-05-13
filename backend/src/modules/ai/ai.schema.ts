import { z } from 'zod';

export const ChatSchema = z.object({
  message: z
    .string()
    .min(1, 'Message is required')
    .max(2000, 'Message too long'),
});

export type ChatDto = z.infer<typeof ChatSchema>;
