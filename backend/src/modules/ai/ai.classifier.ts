export enum Intent {
  STREAK_QUERY = 'STREAK_QUERY',
  CRAVING_EMERGENCY = 'CRAVING_EMERGENCY',
  RELAPSE_SUPPORT = 'RELAPSE_SUPPORT',
  HABIT_ADVICE = 'HABIT_ADVICE',
  SAVINGS_QUERY = 'SAVINGS_QUERY',
  PROGRESS_ANALYSIS = 'PROGRESS_ANALYSIS',
  ROUTINE_PLANNING = 'ROUTINE_PLANNING',
  GENERAL = 'GENERAL',
}

export interface ClassifyResult {
  intent: Intent;
  hasCrisis: boolean;
}

const CRISIS_KEYWORDS = [
  /\b(want to die|kill myself|end it|suicide|self harm|hurt myself|no reason to live|give up on life)\b/gi,
];

const INTENT_PATTERNS: Array<{ regex: RegExp; intent: Intent }> = [
  { regex: /(streak|how many days|day.? in a row|on a roll)/gi, intent: Intent.STREAK_QUERY },
  { regex: /(crav(e|ing)|urge|tempted|withdrawal)/gi, intent: Intent.CRAVING_EMERGENCY },
  { regex: /(relaps(e|ed|ing)|slip(ped|s|ing)?|fell off|broke? my streak|messed? up|failed?|setback)/gi, intent: Intent.RELAPSE_SUPPORT },
  { regex: /(tip(s)?|advice|suggest|how (can|do|should) I|should I|strateg(y|ies)|technique)/gi, intent: Intent.HABIT_ADVICE },
  { regex: /(sav(e|ed|ings)|money|cost|spend|reward)/gi, intent: Intent.SAVINGS_QUERY },
  { regex: /(progress|analyz(e|ing)|how am I doing|overview|report|summary|week|month)/gi, intent: Intent.PROGRESS_ANALYSIS },
  { regex: /(routine|plan|schedule|morning|evening|daily|set up)/gi, intent: Intent.ROUTINE_PLANNING },
];

export function classifyMessage(message: string): ClassifyResult {
  const hasCrisis = CRISIS_KEYWORDS.some(p => {
    p.lastIndex = 0;
    return p.test(message);
  });

  for (const { regex, intent } of INTENT_PATTERNS) {
    regex.lastIndex = 0;
    if (regex.test(message)) {
      return { intent, hasCrisis };
    }
  }

  return { intent: Intent.GENERAL, hasCrisis };
}
