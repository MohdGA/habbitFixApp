import { describe, it, expect, vi, beforeEach } from 'vitest';
import { streaksService } from '../../src/modules/streaks/streaks.service.js';

// Mock Prisma
vi.mock('../../src/config/prisma.js', () => ({
  prisma: {
    streak: {
      findUnique: vi.fn(),
      create: vi.fn(),
      update: vi.fn(),
    },
    freezeToken: { findFirst: vi.fn() },
    checkin: { upsert: vi.fn() },
    userStats: { update: vi.fn() },
  },
}));

import { prisma } from '../../src/config/prisma.js';

describe('StreaksService', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('updateStreak', () => {
    it('should create a new streak with 1 on first successful checkin', async () => {
      (prisma.streak.findUnique as any).mockResolvedValue(null);
      (prisma.streak.create as any).mockResolvedValue({ currentStreak: 1, longestStreak: 1 });

      const result = await streaksService.updateStreak('habit-1', new Date(), true);

      expect(result.currentStreak).toBe(1);
      expect(result.milestones).toContain(1);
    });

    it('should increment streak for consecutive days', async () => {
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      yesterday.setHours(0, 0, 0, 0);

      (prisma.streak.findUnique as any).mockResolvedValue({
        currentStreak: 6,
        longestStreak: 10,
        lastCheckinAt: yesterday,
      });
      (prisma.streak.update as any).mockResolvedValue({ currentStreak: 7, longestStreak: 10 });

      const result = await streaksService.updateStreak('habit-1', new Date(), true);

      expect(result.currentStreak).toBe(7);
      expect(result.milestones).toContain(7); // 7-day milestone
    });

    it('should reset streak to 0 on failed checkin', async () => {
      (prisma.streak.findUnique as any).mockResolvedValue({
        currentStreak: 15,
        longestStreak: 20,
        lastCheckinAt: new Date(),
      });
      (prisma.streak.update as any).mockResolvedValue({ currentStreak: 0, longestStreak: 20 });

      const result = await streaksService.updateStreak('habit-1', new Date(), false);

      expect(result.currentStreak).toBe(0);
      expect(result.milestones).toHaveLength(0);
    });

    it('should reset streak on gap in checkins', async () => {
      const threeDaysAgo = new Date();
      threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);

      (prisma.streak.findUnique as any).mockResolvedValue({
        currentStreak: 21,
        longestStreak: 30,
        lastCheckinAt: threeDaysAgo,
      });
      (prisma.streak.update as any).mockResolvedValue({ currentStreak: 1, longestStreak: 30 });

      const result = await streaksService.updateStreak('habit-1', new Date(), true);

      expect(result.currentStreak).toBe(1);
    });

    it('should track milestones correctly at 30 days', async () => {
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);

      (prisma.streak.findUnique as any).mockResolvedValue({
        currentStreak: 29,
        longestStreak: 29,
        lastCheckinAt: yesterday,
      });
      (prisma.streak.update as any).mockResolvedValue({ currentStreak: 30, longestStreak: 30 });

      const result = await streaksService.updateStreak('habit-1', new Date(), true);

      expect(result.milestones).toContain(30);
    });
  });
});
