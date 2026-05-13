import { prisma } from '../../config/prisma.js';
import type { HabitType, HabitFrequency } from '@prisma/client';

export interface CreateHabitDto {
  name: string;
  emoji?: string;
  type: HabitType;
  frequency?: HabitFrequency;
  customDays?: number[];
  targetAmount?: number;
  unit?: string;
  costPerUnit?: number;
  reminderTime?: string;
  color?: string;
}

export interface UpdateHabitDto extends Partial<CreateHabitDto> {
  isArchived?: boolean;
}

export class HabitsService {
  async create(userId: string, dto: CreateHabitDto) {
    const habit = await prisma.habit.create({
      data: {
        userId,
        name: dto.name,
        emoji: dto.emoji ?? '🎯',
        type: dto.type,
        frequency: dto.frequency ?? 'DAILY',
        customDays: dto.customDays ?? [],
        targetAmount: dto.targetAmount,
        unit: dto.unit,
        costPerUnit: dto.costPerUnit,
        reminderTime: dto.reminderTime,
        color: dto.color ?? '#FF9F0A',
        streaks: { create: { currentStreak: 0, longestStreak: 0 } },
      },
      include: {
        streaks: true,
        savingsGoal: true,
      },
    });

    return habit;
  }

  async findAll(userId: string, includeArchived = false) {
    const habits = await prisma.habit.findMany({
      where: {
        userId,
        ...(includeArchived ? {} : { isArchived: false }),
      },
      include: {
        streaks: true,
        savingsGoal: true,
        checkins: {
          where: {
            date: {
              gte: new Date(new Date().setHours(0, 0, 0, 0)),
              lte: new Date(new Date().setHours(23, 59, 59, 999)),
            },
          },
          take: 1,
        },
      },
      orderBy: { createdAt: 'asc' },
    });

    return habits.map(h => ({
      ...h,
      checkedToday: h.checkins.length > 0 && h.checkins[0].success,
    }));
  }

  async findOne(userId: string, habitId: string) {
    const habit = await prisma.habit.findFirst({
      where: { id: habitId, userId },
      include: {
        streaks: true,
        savingsGoal: true,
      },
    });

    if (!habit) {
      throw Object.assign(new Error('Habit not found'), { statusCode: 404 });
    }

    return habit;
  }

  async update(userId: string, habitId: string, dto: UpdateHabitDto) {
    await this.findOne(userId, habitId);

    const habit = await prisma.habit.update({
      where: { id: habitId },
      data: {
        ...(dto.name !== undefined && { name: dto.name }),
        ...(dto.emoji !== undefined && { emoji: dto.emoji }),
        ...(dto.type !== undefined && { type: dto.type }),
        ...(dto.frequency !== undefined && { frequency: dto.frequency }),
        ...(dto.customDays !== undefined && { customDays: dto.customDays }),
        ...(dto.targetAmount !== undefined && { targetAmount: dto.targetAmount }),
        ...(dto.unit !== undefined && { unit: dto.unit }),
        ...(dto.costPerUnit !== undefined && { costPerUnit: dto.costPerUnit }),
        ...(dto.reminderTime !== undefined && { reminderTime: dto.reminderTime }),
        ...(dto.color !== undefined && { color: dto.color }),
        ...(dto.isArchived !== undefined && { isArchived: dto.isArchived }),
      },
      include: { streaks: true, savingsGoal: true },
    });

    return habit;
  }

  async archive(userId: string, habitId: string) {
    await this.findOne(userId, habitId);
    return prisma.habit.update({
      where: { id: habitId },
      data: { isArchived: true },
    });
  }

  async delete(userId: string, habitId: string) {
    await this.findOne(userId, habitId);
    await prisma.habit.delete({ where: { id: habitId } });
    return { message: 'Habit deleted' };
  }
}

export const habitsService = new HabitsService();
