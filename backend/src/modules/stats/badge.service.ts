import { prisma } from '../../config/prisma.js';
import type { BadgeType } from '@prisma/client';

interface BadgeTrigger {
  checkin?: any;
  currentStreak: number;
  milestones: number[];
}

const BADGE_DEFINITIONS: Array<{ type: BadgeType; check: (t: BadgeTrigger) => boolean }> = [
  { type: 'FIRST_CHECKIN', check: (t) => !!t.checkin },
  { type: 'STREAK_7', check: (t) => t.currentStreak >= 7 },
  { type: 'STREAK_30', check: (t) => t.currentStreak >= 30 },
  { type: 'STREAK_100', check: (t) => t.currentStreak >= 100 },
  { type: 'STREAK_365', check: (t) => t.currentStreak >= 365 },
];

export class BadgeService {
  async checkAndAward(userId: string, trigger: BadgeTrigger): Promise<BadgeType[]> {
    const alreadyEarned = await prisma.userBadge.findMany({
      where: { userId },
      select: { badge: { select: { type: true } } },
    });
    const earnedTypes = new Set(alreadyEarned.map(ub => ub.badge.type));

    const newBadges: BadgeType[] = [];

    for (const { type, check } of BADGE_DEFINITIONS) {
      if (!earnedTypes.has(type) && check(trigger)) {
        const badge = await prisma.badge.findUnique({ where: { type } });
        if (badge) {
          await prisma.userBadge.create({
            data: { userId, badgeId: badge.id },
          });
          newBadges.push(type);
        }
      }
    }

    return newBadges;
  }

  async getUserBadges(userId: string) {
    return prisma.userBadge.findMany({
      where: { userId },
      include: { badge: true },
      orderBy: { earnedAt: 'desc' },
    });
  }
}

export const badgeService = new BadgeService();
