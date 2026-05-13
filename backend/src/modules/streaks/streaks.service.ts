import { prisma } from '../../config/prisma.js';

interface StreakResult {
  currentStreak: number;
  longestStreak: number;
  milestones: number[];
}

const MILESTONE_DAYS = [1, 3, 7, 14, 21, 30, 60, 90, 100, 180, 365];

export class StreaksService {
  async updateStreak(habitId: string, checkinDate: Date, success: boolean): Promise<StreakResult> {
    const streak = await prisma.streak.findUnique({ where: { habitId } });

    if (!streak) {
      await prisma.streak.create({
        data: { habitId, currentStreak: success ? 1 : 0, longestStreak: success ? 1 : 0 },
      });
      return { currentStreak: success ? 1 : 0, longestStreak: success ? 1 : 0, milestones: success ? [1] : [] };
    }

    let { currentStreak, longestStreak } = streak;
    const previousMilestones = MILESTONE_DAYS.filter(m => m <= currentStreak);
    const milestones: number[] = [];

    if (!success) {
      // Streak broken
      await prisma.streak.update({
        where: { habitId },
        data: { currentStreak: 0, lastCheckinAt: checkinDate },
      });
      return { currentStreak: 0, longestStreak, milestones: [] };
    }

    const lastCheckin = streak.lastCheckinAt;
    if (!lastCheckin) {
      currentStreak = 1;
    } else {
      const lastDate = new Date(lastCheckin);
      lastDate.setHours(0, 0, 0, 0);
      const currentDate = new Date(checkinDate);
      currentDate.setHours(0, 0, 0, 0);
      const diffMs = currentDate.getTime() - lastDate.getTime();
      const diffDays = Math.round(diffMs / (1000 * 60 * 60 * 24));

      if (diffDays === 1) {
        // Consecutive day
        currentStreak += 1;
      } else if (diffDays === 0) {
        // Same day re-checkin — don't change streak
      } else {
        // Gap — reset
        currentStreak = 1;
      }
    }

    longestStreak = Math.max(longestStreak, currentStreak);

    // Find new milestones crossed
    const newMilestones = MILESTONE_DAYS.filter(
      m => m <= currentStreak && !previousMilestones.includes(m),
    );
    milestones.push(...newMilestones);

    await prisma.streak.update({
      where: { habitId },
      data: { currentStreak, longestStreak, lastCheckinAt: checkinDate },
    });

    return { currentStreak, longestStreak, milestones };
  }

  async useFreeze(userId: string, habitId: string, date: Date): Promise<{ success: boolean }> {
    // Check if user has available freeze tokens
    const token = await prisma.freezeToken.findFirst({
      where: { userId, usedAt: null, expiresAt: { gt: new Date() } },
    });

    if (!token) {
      throw Object.assign(new Error('No freeze tokens available'), { statusCode: 400 });
    }

    // Apply freeze — create a checkin for the missed day
    const checkinDate = new Date(date);
    checkinDate.setHours(0, 0, 0, 0);

    await prisma.$transaction([
      prisma.freezeToken.update({
        where: { id: token.id },
        data: { usedAt: new Date(), habitId },
      }),
      prisma.checkin.upsert({
        where: { habitId_date: { habitId, date: checkinDate } },
        create: { userId, habitId, date: checkinDate, success: true, xpEarned: 0, note: '❄️ Freeze token used' },
        update: { success: true, note: '❄️ Freeze token used' },
      }),
      prisma.streak.updateMany({
        where: { habitId },
        data: { freezeCount: { increment: 1 } },
      }),
      prisma.userStats.update({
        where: { userId },
        data: { totalFreezeUsed: { increment: 1 } },
      }),
    ]);

    return { success: true };
  }

  async getFreezeTokens(userId: string) {
    const tokens = await prisma.freezeToken.findMany({
      where: { userId, usedAt: null, expiresAt: { gt: new Date() } },
      orderBy: { earnedAt: 'asc' },
    });
    return tokens;
  }

  async getStreakForHabit(userId: string, habitId: string) {
    const habit = await prisma.habit.findFirst({
      where: { id: habitId, userId },
    });
    if (!habit) throw Object.assign(new Error('Habit not found'), { statusCode: 404 });

    const streak = await prisma.streak.findUnique({ where: { habitId } });
    return streak;
  }
}

export const streaksService = new StreaksService();
