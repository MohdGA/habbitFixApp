import { prisma } from '../../config/prisma.js';

// Level thresholds: level 1 = 0-99 XP, level 2 = 100-249, etc.
function calculateLevel(totalXp: number): number {
  if (totalXp < 100) return 1;
  if (totalXp < 300) return 2;
  if (totalXp < 600) return 3;
  if (totalXp < 1000) return 4;
  if (totalXp < 1500) return 5;
  if (totalXp < 2500) return 6;
  if (totalXp < 4000) return 7;
  if (totalXp < 6000) return 8;
  if (totalXp < 9000) return 9;
  return Math.floor(10 + (totalXp - 9000) / 2000);
}

export function xpForNextLevel(level: number): number {
  const thresholds = [0, 100, 300, 600, 1000, 1500, 2500, 4000, 6000, 9000];
  if (level <= thresholds.length) return thresholds[level] ?? (9000 + (level - 9) * 2000);
  return 9000 + (level - 9) * 2000;
}

export class XpService {
  async award(userId: string, xp: number): Promise<{ totalXp: number; level: number; leveledUp: boolean }> {
    const stats = await prisma.userStats.upsert({
      where: { userId },
      create: { userId, totalXp: xp, level: calculateLevel(xp), totalCheckins: 1 },
      update: {
        totalXp: { increment: xp },
        totalCheckins: { increment: 1 },
      },
    });

    const newXp = stats.totalXp;
    const newLevel = calculateLevel(newXp);
    const leveledUp = newLevel > stats.level;

    if (leveledUp) {
      await prisma.userStats.update({
        where: { userId },
        data: { level: newLevel },
      });
    }

    return { totalXp: newXp, level: newLevel, leveledUp };
  }

  async getStats(userId: string) {
    const stats = await prisma.userStats.findUnique({ where: { userId } });
    if (!stats) return null;

    const nextLevelXp = xpForNextLevel(stats.level);
    const prevLevelXp = xpForNextLevel(stats.level - 1);
    const progress = Math.min(1, (stats.totalXp - prevLevelXp) / (nextLevelXp - prevLevelXp));

    return {
      ...stats,
      nextLevelXp,
      xpProgress: progress,
    };
  }
}

export const xpService = new XpService();
