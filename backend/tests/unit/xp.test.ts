import { describe, it, expect, vi, beforeEach } from 'vitest';
import { xpService, xpForNextLevel } from '../../src/modules/stats/xp.service.js';

vi.mock('../../src/config/prisma.js', () => ({
  prisma: {
    userStats: {
      upsert: vi.fn(),
      update: vi.fn(),
    },
  },
}));

import { prisma } from '../../src/config/prisma.js';

describe('XP Service', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('xpForNextLevel', () => {
    it('should return correct XP thresholds', () => {
      expect(xpForNextLevel(1)).toBe(100);
      expect(xpForNextLevel(2)).toBe(300);
      expect(xpForNextLevel(5)).toBe(1500);
    });
  });

  describe('award', () => {
    it('should award XP and return updated stats', async () => {
      (prisma.userStats.upsert as any).mockResolvedValue({
        totalXp: 110,
        level: 1,
        totalCheckins: 11,
      });

      const result = await xpService.award('user-1', 10);

      expect(result.totalXp).toBe(110);
      expect(result.leveledUp).toBe(true); // crossed 100 threshold
    });

    it('should not report level up if same level', async () => {
      (prisma.userStats.upsert as any).mockResolvedValue({
        totalXp: 50,
        level: 1,
        totalCheckins: 5,
      });

      const result = await xpService.award('user-1', 10);

      expect(result.leveledUp).toBe(false);
    });
  });
});
