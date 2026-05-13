import { describe, it, expect } from 'vitest';
import { classifyMessage, Intent } from '../../src/modules/ai/ai.classifier.js';

describe('AI Classifier', () => {
  describe('crisis detection', () => {
    it('should detect suicide keyword', () => {
      const { hasCrisis } = classifyMessage('I want to kill myself');
      expect(hasCrisis).toBe(true);
    });

    it('should detect self-harm keyword', () => {
      const { hasCrisis } = classifyMessage('I want to self harm');
      expect(hasCrisis).toBe(true);
    });

    it('should detect give up pattern', () => {
      const { hasCrisis } = classifyMessage('I give up on life');
      expect(hasCrisis).toBe(true);
    });

    it('should not flag normal messages', () => {
      const { hasCrisis } = classifyMessage('How can I improve my streak?');
      expect(hasCrisis).toBe(false);
    });
  });

  describe('intent classification', () => {
    it('should classify STREAK_QUERY', () => {
      const { intent } = classifyMessage('What is my current streak?');
      expect(intent).toBe(Intent.STREAK_QUERY);
    });

    it('should classify CRAVING_EMERGENCY', () => {
      const { intent } = classifyMessage('I am having a strong craving right now');
      expect(intent).toBe(Intent.CRAVING_EMERGENCY);
    });

    it('should classify RELAPSE_SUPPORT', () => {
      const { intent } = classifyMessage('I relapsed today and feel terrible');
      expect(intent).toBe(Intent.RELAPSE_SUPPORT);
    });

    it('should classify HABIT_ADVICE', () => {
      const { intent } = classifyMessage('Can you give me tips to stay consistent?');
      expect(intent).toBe(Intent.HABIT_ADVICE);
    });

    it('should classify SAVINGS_QUERY', () => {
      const { intent } = classifyMessage('How much money have I saved?');
      expect(intent).toBe(Intent.SAVINGS_QUERY);
    });

    it('should classify PROGRESS_ANALYSIS', () => {
      const { intent } = classifyMessage('Analyze my progress this month');
      expect(intent).toBe(Intent.PROGRESS_ANALYSIS);
    });

    it('should classify ROUTINE_PLANNING', () => {
      const { intent } = classifyMessage('Help me plan my morning routine');
      expect(intent).toBe(Intent.ROUTINE_PLANNING);
    });

    it('should default to GENERAL', () => {
      const { intent } = classifyMessage('Hello, how are you?');
      expect(intent).toBe(Intent.GENERAL);
    });
  });

  describe('combined detection', () => {
    it('should detect crisis even when intent matches', () => {
      const { intent, hasCrisis } = classifyMessage('I want to die, what is my streak?');
      expect(hasCrisis).toBe(true);
      expect(intent).toBe(Intent.STREAK_QUERY);
    });
  });
});
