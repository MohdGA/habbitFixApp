import Groq from 'groq-sdk';
import { env } from '../../config/env.js';
import { getRedis, RedisKeys } from '../../config/redis.js';
import { buildSystemPrompt, invalidateContextCache, fetchUserContext } from './ai.context.js';
import { sanitizeMessage, CRISIS_RESPONSE } from './ai.sanitizer.js';
import { classifyMessage, Intent } from './ai.classifier.js';
import { getCachedResponse, setCachedResponse } from './ai.cache.js';
import type { FastifyReply } from 'fastify';

const client = new Groq({ apiKey: env.GROQ_API_KEY });

const MAX_HISTORY_TURNS = 20;
const HISTORY_TTL = 7 * 24 * 60 * 60;
const CHAT_MODEL = env.GROQ_MODEL;

interface Message {
  role: 'user' | 'assistant';
  content: string;
}

export class AiService {
  async chatJson(userId: string, message: string): Promise<{ message: string }> {
    const { clean, injectionDetected } = sanitizeMessage(message);
    if (injectionDetected) {
      console.warn('ai.injection_attempt', { userId });
    }

    const { intent, hasCrisis } = classifyMessage(clean);

    if (hasCrisis) {
      console.warn('ai.crisis_signal_detected', { userId });
      return { message: CRISIS_RESPONSE };
    }

    const cached = await getCachedResponse(userId, intent);
    if (cached) return { message: cached };

    const history = await this.loadHistory(userId);
    const userMessage: Message = { role: 'user', content: clean };
    history.push(userMessage);

    const systemPrompt = await buildSystemPrompt(userId);

    try {
      const response = await client.chat.completions.create({
        model: CHAT_MODEL,
        max_tokens: env.GROQ_MAX_TOKENS,
        temperature: 0.7,
        messages: [
          { role: 'system', content: systemPrompt },
          ...history.slice(-MAX_HISTORY_TURNS).map(m => ({
            role: m.role as 'user' | 'assistant',
            content: m.content,
          })),
        ],
      });

      const fullResponse = response.choices[0]?.message?.content ?? '';

      history.push({ role: 'assistant', content: fullResponse });
      await this.saveHistory(userId, history);
      await setCachedResponse(userId, intent, fullResponse);

      const outputTokens = response.usage?.completion_tokens ?? 0;
      if (outputTokens > 0) await this.trackTokenUsage(userId, outputTokens);

      return { message: fullResponse };
    } catch (err: unknown) {
      let message = 'AI service temporarily unavailable. Please try again.';
      if (err instanceof Groq.APIError) {
        if (err.status === 429) {
          message = 'AI is busy right now. Please wait a moment and try again.';
        } else if (err.status === 401) {
          message = 'Invalid Groq API key. Please check your configuration.';
        } else {
          message = `AI error (${err.status}): ${err.message}`;
        }
      }
      throw Object.assign(new Error(message), { statusCode: 502 });
    }
  }

  async chat(userId: string, message: string, reply: FastifyReply): Promise<void> {
    const { clean, injectionDetected } = sanitizeMessage(message);
    if (injectionDetected) {
      console.warn('ai.injection_attempt', { userId });
    }

    const { intent, hasCrisis } = classifyMessage(clean);

    if (hasCrisis) {
      console.warn('ai.crisis_signal_detected', { userId });
      await this.streamText(CRISIS_RESPONSE, reply);
      return;
    }

    const cached = await getCachedResponse(userId, intent);
    if (cached) {
      await this.streamText(cached, reply);
      return;
    }

    const history = await this.loadHistory(userId);
    const userMessage: Message = { role: 'user', content: clean };
    history.push(userMessage);

    const systemPrompt = await buildSystemPrompt(userId);

    reply.raw.setHeader('Content-Type', 'text/event-stream');
    reply.raw.setHeader('Cache-Control', 'no-cache');
    reply.raw.setHeader('Connection', 'keep-alive');
    reply.raw.setHeader('X-Accel-Buffering', 'no');

    let fullResponse = '';
    let inputTokens = 0;
    let outputTokens = 0;

    try {
      const response = await client.chat.completions.create({
        model: CHAT_MODEL,
        max_tokens: env.GROQ_MAX_TOKENS,
        temperature: 0.7,
        messages: [
          { role: 'system', content: systemPrompt },
          ...history.slice(-MAX_HISTORY_TURNS).map(m => ({
            role: m.role as 'user' | 'assistant',
            content: m.content,
          })),
        ],
      });

      fullResponse = response.choices[0]?.message?.content ?? '';
      outputTokens = response.usage?.completion_tokens ?? 0;

      const words = fullResponse.split(' ');
      for (const word of words) {
        reply.raw.write(`data: ${JSON.stringify({ type: 'chunk', text: word + ' ' })}\n\n`);
      }

      reply.raw.write(
        `data: ${JSON.stringify({ type: 'done', inputTokens, outputTokens })}\n\n`,
      );
      reply.raw.end();

      history.push({ role: 'assistant', content: fullResponse });
      await this.saveHistory(userId, history);
      await setCachedResponse(userId, intent, fullResponse);

      if (outputTokens > 0) {
        await this.trackTokenUsage(userId, outputTokens);
      }
    } catch (err: unknown) {
      let message = 'AI service temporarily unavailable. Please try again.';
      if (err instanceof Groq.APIError) {
        if (err.status === 429) {
          message = 'AI is busy right now. Please wait a moment and try again.';
        } else if (err.status === 401) {
          message = 'Invalid Groq API key. Please check your configuration.';
        } else {
          message = `AI error (${err.status}): ${err.message}`;
        }
      }
      try {
        reply.raw.write(`data: ${JSON.stringify({ type: 'error', message })}\n\n`);
        reply.raw.end();
      } catch {
        // Reply already ended
      }
    }
  }

  async getSuggestions(userId: string): Promise<string[]> {
    const redis = getRedis();
    const cacheKey = RedisKeys.aiSuggestions(userId);

    const cached = await redis.get(cacheKey);
    if (cached) return JSON.parse(cached);

    // Build suggestions from live user data — NO Anthropic API call (spec requirement)
    const ctx = await fetchUserContext(userId);
    const suggestions: string[] = [];

    const MILESTONES = [7, 14, 21, 30, 60, 90, 180, 365];

    // Priority 1: habits not yet checked in today
    const notDone = ctx.habits.filter(h => !h.checkedInToday);
    if (notDone.length > 0) {
      suggestions.push(`Remind me about my ${notDone[0].name} habit`);
    }

    // Priority 2: streak one day before a milestone
    if (suggestions.length < 4) {
      for (const h of ctx.habits) {
        const nextMilestone = MILESTONES.find(m => m === h.currentStreak + 1);
        if (nextMilestone) {
          suggestions.push(`I'm ${h.currentStreak} days in — what happens at ${nextMilestone}?`);
          break;
        }
      }
    }

    // Priority 3: streak is 0 but had history (broke recently)
    if (suggestions.length < 4) {
      const broke = ctx.habits.find(h => h.currentStreak === 0 && h.longestStreak > 0);
      if (broke) {
        suggestions.push(`I just broke my ${broke.name} streak. Help me restart.`);
      }
    }

    // Priority 4: low freeze tokens
    if (suggestions.length < 4 && ctx.streakFreezeTokens < 2) {
      suggestions.push('How do I earn more streak freeze tokens?');
    }

    // Priority 5: savings progress exists
    if (suggestions.length < 4 && ctx.totalSaved > 0) {
      suggestions.push(
        `I've saved ${ctx.totalSaved.toFixed(3)} ${ctx.currency}. What should I spend it on?`,
      );
    }

    // Fill remaining slots with useful defaults
    const defaults = [
      'How am I doing overall?',
      'Give me a craving emergency plan',
      'Analyze my weakest habit',
      'Plan my evening routine',
    ];
    for (const d of defaults) {
      if (suggestions.length >= 4) break;
      suggestions.push(d);
    }

    await redis.setex(cacheKey, 1800, JSON.stringify(suggestions));
    return suggestions;
  }

  async getWeeklySummary(userId: string): Promise<string> {
    const systemPrompt = await buildSystemPrompt(userId);

    const response = await client.chat.completions.create({
      model: CHAT_MODEL,
      max_tokens: 400,
      messages: [
        { role: 'system', content: systemPrompt },
        {
          role: 'user',
          content:
            'Generate a motivating weekly summary report for the user based on their data. Include: 1) What went well, 2) A highlight achievement, 3) One focus area for next week. Keep it warm, specific to their data, and under 150 words.',
        },
      ],
    });

    return response.choices[0]?.message?.content ?? '';
  }

  async clearHistory(userId: string): Promise<void> {
    const redis = getRedis();
    await redis.del(RedisKeys.aiHistory(userId));
  }

  async getHistory(userId: string): Promise<{ messages: Message[]; count: number }> {
    const messages = await this.loadHistory(userId);
    return { messages, count: messages.length };
  }

  async invalidateContext(userId: string): Promise<void> {
    invalidateContextCache(userId);
  }

  // ─── Private ──────────────────────────────────────────

  private async loadHistory(userId: string): Promise<Message[]> {
    const redis = getRedis();
    const data = await redis.get(RedisKeys.aiHistory(userId));
    if (!data) return [];
    try {
      return JSON.parse(data);
    } catch {
      return [];
    }
  }

  private async saveHistory(userId: string, history: Message[]): Promise<void> {
    const redis = getRedis();
    const trimmed = history.slice(-MAX_HISTORY_TURNS);
    await redis.setex(
      RedisKeys.aiHistory(userId),
      HISTORY_TTL,
      JSON.stringify(trimmed),
    );
  }

  private async trackTokenUsage(userId: string, tokens: number): Promise<void> {
    const redis = getRedis();
    const now = new Date();
    const key = `ai:tokens:${userId}:${now.getUTCFullYear()}${String(now.getUTCMonth() + 1).padStart(2, '0')}`;
    await redis.incrby(key, tokens);
    await redis.expire(key, 32 * 24 * 60 * 60);
  }

  private async streamText(text: string, reply: FastifyReply): Promise<void> {
    reply.raw.setHeader('Content-Type', 'text/event-stream');
    reply.raw.setHeader('Cache-Control', 'no-cache');
    reply.raw.setHeader('Connection', 'keep-alive');

    const words = text.split(' ');
    for (const word of words) {
      reply.raw.write(`data: ${JSON.stringify({ type: 'chunk', text: word + ' ' })}\n\n`);
      await new Promise(r => setTimeout(r, 30));
    }

    reply.raw.write(`data: ${JSON.stringify({ type: 'done', inputTokens: 0, outputTokens: 0 })}\n\n`);
    reply.raw.end();
  }
}

export const aiService = new AiService();
