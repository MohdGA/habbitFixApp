import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database...');

  // Seed badges
  const badges = [
    { type: 'FIRST_CHECKIN' as const, name: 'First Step', description: 'Completed your first check-in', emoji: '👣', xpReward: 25 },
    { type: 'STREAK_7' as const, name: 'Week Warrior', description: 'Maintained a 7-day streak', emoji: '🔥', xpReward: 50 },
    { type: 'STREAK_30' as const, name: 'Monthly Master', description: 'Maintained a 30-day streak', emoji: '💪', xpReward: 150 },
    { type: 'STREAK_100' as const, name: 'Century Club', description: 'Maintained a 100-day streak', emoji: '💯', xpReward: 500 },
    { type: 'STREAK_365' as const, name: 'Year of Power', description: 'Maintained a 365-day streak', emoji: '🏆', xpReward: 2000 },
    { type: 'SAVINGS_100' as const, name: 'First $100', description: 'Saved $100 from quitting', emoji: '💰', xpReward: 100 },
    { type: 'SAVINGS_1000' as const, name: 'Grand Saver', description: 'Saved $1,000 from quitting', emoji: '🤑', xpReward: 500 },
    { type: 'FREEZE_MASTER' as const, name: 'Ice Shield', description: 'Used 5 freeze tokens', emoji: '❄️', xpReward: 75 },
    { type: 'EARLY_BIRD' as const, name: 'Early Bird', description: 'Checked in before 8am 7 times', emoji: '🌅', xpReward: 50 },
    { type: 'NIGHT_OWL' as const, name: 'Night Owl', description: 'Checked in after 10pm 7 times', emoji: '🦉', xpReward: 50 },
    { type: 'SOCIAL_SUPPORTER' as const, name: 'Community Hero', description: 'Left 10 supportive comments', emoji: '🤝', xpReward: 75 },
  ];

  for (const badge of badges) {
    await prisma.badge.upsert({
      where: { type: badge.type },
      create: badge,
      update: badge,
    });
  }

  // Seed health milestones (smoking)
  const smokingMilestones = [
    { habitType: 'smoking', dayMark: 0.0139, title: '20 Minutes Free', description: 'Heart rate and blood pressure drop to normal levels', emoji: '❤️', category: 'cardiovascular', sortOrder: 1 },
    { habitType: 'smoking', dayMark: 0.5, title: '12 Hours Free', description: 'Carbon monoxide level in blood drops to normal', emoji: '🫁', category: 'respiratory', sortOrder: 2 },
    { habitType: 'smoking', dayMark: 2, title: '2 Days Free', description: 'Your sense of smell and taste begin to improve', emoji: '👃', category: 'sensory', sortOrder: 3 },
    { habitType: 'smoking', dayMark: 14, title: '2 Weeks Free', description: 'Blood circulation improves, lung function increases up to 30%', emoji: '🩸', category: 'cardiovascular', sortOrder: 4 },
    { habitType: 'smoking', dayMark: 30, title: '1 Month Free', description: 'Coughing and shortness of breath decrease significantly', emoji: '😮‍💨', category: 'respiratory', sortOrder: 5 },
    { habitType: 'smoking', dayMark: 90, title: '3 Months Free', description: 'Lung function continues to improve. Fertility improves', emoji: '🌱', category: 'respiratory', sortOrder: 6 },
    { habitType: 'smoking', dayMark: 180, title: '6 Months Free', description: 'Less coughing, less sinus congestion. More energy', emoji: '⚡', category: 'respiratory', sortOrder: 7 },
    { habitType: 'smoking', dayMark: 365, title: '1 Year Free', description: 'Risk of heart disease is half that of a smoker', emoji: '🏆', category: 'cardiovascular', sortOrder: 8 },
    { habitType: 'smoking', dayMark: 1825, title: '5 Years Free', description: 'Stroke risk is reduced to that of a non-smoker', emoji: '🧠', category: 'neurological', sortOrder: 9 },
  ];

  const alcoholMilestones = [
    { habitType: 'alcohol', dayMark: 1, title: '24 Hours Free', description: 'Blood sugar and pressure begin to normalize', emoji: '🩸', category: 'metabolic', sortOrder: 1 },
    { habitType: 'alcohol', dayMark: 7, title: '1 Week Free', description: 'Sleep quality improves. Liver starts recovering', emoji: '😴', category: 'sleep', sortOrder: 2 },
    { habitType: 'alcohol', dayMark: 14, title: '2 Weeks Free', description: 'Hydration normalizes, skin looks healthier', emoji: '✨', category: 'skin', sortOrder: 3 },
    { habitType: 'alcohol', dayMark: 30, title: '1 Month Free', description: 'Liver fat reduces by 15%. Mental clarity improves', emoji: '🧠', category: 'mental', sortOrder: 4 },
    { habitType: 'alcohol', dayMark: 90, title: '3 Months Free', description: 'Significant liver repair. Energy levels stable', emoji: '💪', category: 'liver', sortOrder: 5 },
    { habitType: 'alcohol', dayMark: 365, title: '1 Year Free', description: 'Cancer risk significantly reduced. Full sleep cycles restored', emoji: '🏆', category: 'cancer-risk', sortOrder: 6 },
  ];

  const generalMilestones = [
    { habitType: 'general', dayMark: 1, title: 'Day 1 Complete', description: 'The hardest day is done. Your journey begins.', emoji: '🌟', category: 'mental', sortOrder: 1 },
    { habitType: 'general', dayMark: 3, title: '72 Hours Strong', description: 'The initial surge of cravings typically peaks and starts declining', emoji: '⚡', category: 'mental', sortOrder: 2 },
    { habitType: 'general', dayMark: 7, title: 'One Full Week', description: 'Neural pathways begin rewiring. New patterns forming', emoji: '🧠', category: 'neurological', sortOrder: 3 },
    { habitType: 'general', dayMark: 21, title: '21 Days', description: 'Research suggests habit loops begin solidifying around day 21', emoji: '🔄', category: 'behavioral', sortOrder: 4 },
    { habitType: 'general', dayMark: 66, title: '66 Days', description: 'Average time to fully automate a new behavior. You did it!', emoji: '🤖', category: 'behavioral', sortOrder: 5 },
    { habitType: 'general', dayMark: 365, title: 'One Year', description: 'A full year of transformation. You are a different person.', emoji: '🏆', category: 'life', sortOrder: 6 },
  ];

  const allMilestones = [...smokingMilestones, ...alcoholMilestones, ...generalMilestones];
  for (const milestone of allMilestones) {
    await prisma.healthMilestone.create({ data: milestone }).catch(() => {}); // ignore duplicates
  }

  // Seed quotes
  const quotes = [
    { text: 'Every moment is a fresh beginning.', author: 'T.S. Eliot', tags: ['motivation', 'beginnings'] },
    { text: 'You don\'t have to be great to start, but you have to start to be great.', author: 'Zig Ziglar', tags: ['motivation', 'action'] },
    { text: 'Cravings are like waves — they peak and then they pass. Surf them.', author: 'Quitly', tags: ['cravings', 'mindfulness'] },
    { text: 'The chains of habit are too light to be felt until they are too heavy to be broken.', author: 'Warren Buffett', tags: ['habits', 'wisdom'] },
    { text: 'One day at a time. One hour at a time. One minute at a time.', author: 'Recovery Wisdom', tags: ['recovery', 'mindfulness'] },
    { text: 'You are stronger than your cravings.', author: 'Quitly', tags: ['strength', 'cravings'] },
    { text: 'The secret of getting ahead is getting started.', author: 'Mark Twain', tags: ['motivation', 'action'] },
    { text: 'Small daily improvements over time lead to stunning results.', author: 'Robin Sharma', tags: ['consistency', 'growth'] },
    { text: 'Fall seven times, stand up eight.', author: 'Japanese Proverb', tags: ['resilience', 'recovery'] },
    { text: 'Your future self is watching you right now through memories.', author: 'Aubrey de Grey', tags: ['mindfulness', 'future'] },
    { text: 'Discipline is choosing between what you want now and what you want most.', author: 'Abraham Lincoln', tags: ['discipline', 'habits'] },
    { text: 'Every day is a chance to change your life.', author: 'Quitly', tags: ['motivation', 'daily'] },
  ];

  for (const quote of quotes) {
    await prisma.quote.create({ data: quote }).catch(() => {});
  }

  console.log('✅ Database seeded successfully');
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
