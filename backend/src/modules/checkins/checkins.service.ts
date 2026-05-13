import { prisma } from '../../config/prisma.js';
import { streaksService } from '../streaks/streaks.service.js';
import { xpService } from '../stats/xp.service.js';
import { badgeService } from '../stats/badge.service.js';

export interface CreateCheckinDto {
  habitId: string;
  date?: string; // YYYY-MM-DD, defaults to today in user's timezone
  success?: boolean;
  amount?: number;
  mood?: number;
  note?: string;
}

// Returns today's UTC midnight Date for a given IANA timezone.
// e.g. timezone "Asia/Bahrain" (UTC+3) at 2025-01-15 01:00 UTC
//      → returns 2025-01-15T00:00:00.000Z (local date is still Jan 15)
function getTodayInTimezone(timezone: string): Date {
  const now = new Date();
  const formatter = new Intl.DateTimeFormat('en-CA', {
    timeZone: timezone,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  });
  const localDateStr = formatter.format(now); // "YYYY-MM-DD"
  const [year, month, day] = localDateStr.split('-').map(Number);
  return new Date(Date.UTC(year, month - 1, day));
}

export class CheckinsService {
  async create(userId: string, dto: CreateCheckinDto) {
    // Validate habit belongs to user, and fetch user timezone in parallel
    const [habit, user] = await Promise.all([
      prisma.habit.findFirst({ where: { id: dto.habitId, userId } }),
      prisma.user.findUnique({ where: { id: userId }, select: { timezone: true } }),
    ]);

    if (!habit) {
      throw Object.assign(new Error('Habit not found'), { statusCode: 404 });
    }

    const timezone = user?.timezone ?? 'UTC';

    // Use provided date (treated as a UTC calendar day) or today in user's timezone
    const date = dto.date
      ? new Date(dto.date + 'T00:00:00.000Z')
      : getTodayInTimezone(timezone);

    const success = dto.success ?? true;

    // Calculate XP based on current streak
    let xpEarned = 10;
    if (success) {
      const streak = await prisma.streak.findUnique({ where: { habitId: dto.habitId } });
      if (streak && streak.currentStreak >= 7) xpEarned = 15;
      if (streak && streak.currentStreak >= 30) xpEarned = 20;
      if (streak && streak.currentStreak >= 100) xpEarned = 30;
    }

    // Upsert check-in (idempotent)
    const checkin = await prisma.checkin.upsert({
      where: { habitId_date: { habitId: dto.habitId, date } },
      create: {
        userId,
        habitId: dto.habitId,
        date,
        success,
        amount: dto.amount,
        mood: dto.mood,
        note: dto.note,
        xpEarned: success ? xpEarned : 0,
      },
      update: {
        success,
        amount: dto.amount,
        mood: dto.mood,
        note: dto.note,
        xpEarned: success ? xpEarned : 0,
      },
    });

    // Update streak
    const { currentStreak, milestones } = await streaksService.updateStreak(dto.habitId, date, success);

    // Award XP
    if (success) {
      await xpService.award(userId, xpEarned);
    }

    // Update savings if applicable
    if (success && habit.costPerUnit) {
      await this.updateSavings(habit, dto.amount);
    }

    // Check for new badges
    const newBadges = await badgeService.checkAndAward(userId, { checkin, currentStreak, milestones });

    return { checkin, xpEarned: success ? xpEarned : 0, currentStreak, milestones, newBadges };
  }

  async findByHabit(userId: string, habitId: string, from?: string, to?: string) {
    const habit = await prisma.habit.findFirst({
      where: { id: habitId, userId },
      select: { id: true },
    });
    if (!habit) throw Object.assign(new Error('Habit not found'), { statusCode: 404 });

    const where: Record<string, unknown> = { habitId };
    if (from || to) {
      where.date = {};
      if (from) (where.date as Record<string, unknown>).gte = new Date(from + 'T00:00:00.000Z');
      if (to) (where.date as Record<string, unknown>).lte = new Date(to + 'T00:00:00.000Z');
    }

    return prisma.checkin.findMany({ where, orderBy: { date: 'desc' } });
  }

  async getHeatmapData(userId: string) {
    const oneYearAgo = new Date();
    oneYearAgo.setFullYear(oneYearAgo.getFullYear() - 1);

    const checkins = await prisma.checkin.findMany({
      where: { userId, date: { gte: oneYearAgo }, success: true },
      select: { date: true, habitId: true },
    });

    const dateMap: Record<string, number> = {};
    for (const c of checkins) {
      const key = c.date.toISOString().split('T')[0];
      dateMap[key] = (dateMap[key] ?? 0) + 1;
    }
    return dateMap;
  }

  private async updateSavings(habit: { id: string; type: string; costPerUnit: number | null; targetAmount?: number | null }, amount?: number) {
    const savingsGoal = await prisma.savingsGoal.findUnique({ where: { habitId: habit.id } });
    if (!savingsGoal) return;

    let saved = 0;
    if (habit.type === 'QUIT') {
      saved = habit.costPerUnit ?? 0;
    } else if (habit.type === 'REDUCE' && amount !== undefined && habit.targetAmount) {
      const avoided = Math.max(0, habit.targetAmount - amount);
      saved = avoided * (habit.costPerUnit ?? 0);
    }

    if (saved > 0) {
      const newSavings = Math.min(savingsGoal.currentSavings + saved, savingsGoal.goalAmount);
      const achieved = newSavings >= savingsGoal.goalAmount && !savingsGoal.achieved;
      await prisma.savingsGoal.update({
        where: { habitId: habit.id },
        data: { currentSavings: newSavings, ...(achieved && { achieved: true, achievedAt: new Date() }) },
      });
    }
  }
}

export const checkinsService = new CheckinsService();
