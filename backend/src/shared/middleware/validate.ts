import { z, ZodSchema } from 'zod';

export function validateBody<T>(schema: ZodSchema<T>, data: unknown): T {
  const result = schema.safeParse(data);
  if (!result.success) {
    const errors = result.error.errors.map((e) => ({
      field: e.path.join('.'),
      message: e.message,
    }));
    throw Object.assign(new Error('Validation failed'), {
      statusCode: 400,
      validation: errors,
    });
  }
  return result.data;
}
