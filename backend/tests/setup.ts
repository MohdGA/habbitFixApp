import 'dotenv/config';
import { prisma } from '../src/config/prisma.js';

beforeAll(async () => {
  try {
    await prisma.$connect();
  } catch {
    // DB might not be available in CI or local dev
    console.warn('Database unavailable — tests requiring DB will fail.');
  }
});

afterAll(async () => {
  try {
    await prisma.$disconnect();
  } catch {
    // Ignore disconnect errors
  }
});

afterEach(async () => {
  // Tests should clean up their own data
});
