const INJECTION_PATTERNS = [
  /ignore (all |previous |above |prior )?instructions?/gi,
  /disregard\s/i,
  /you are now/gi,
  /new system prompt/gi,
  /act as (a|an|the)?\s/gi,
  /forget (everything|all|what|your|the|prior)/gi,
  /pretend (you are|to be|that)/gi,
  /system prompt/gi,
  /reveal (your|the|all|my) (instructions|prompt|system|context)/gi,
  /\bdan\b/gi,
  /jailbreak/gi,
  /<\|.*?\|>/g,
  /\[\[.*?\]\]/g,
];

export interface SanitizeResult {
  clean: string;
  wasModified: boolean;
  injectionDetected: boolean;
}

export function sanitizeMessage(message: string): SanitizeResult {
  let clean = message.trim();

  let injectionDetected = false;

  for (const pattern of INJECTION_PATTERNS) {
    pattern.lastIndex = 0;
    if (pattern.test(clean)) {
      injectionDetected = true;
      pattern.lastIndex = 0;
      clean = clean.replace(pattern, '');
    }
    pattern.lastIndex = 0;
  }

  clean = clean.replace(/<[^>]*>/g, '');

  // Strip base64 image data URIs (prevents "model does not support image input" errors)
  clean = clean.replace(/data:image\/[a-z]+;base64,[A-Za-z0-9+/=]+/gi, '[image removed]');

  clean = clean.replace(/(.)\1{19,}/g, (m) => m.slice(0, 3));

  if (clean.length > 500) {
    clean = clean.slice(0, 500);
    clean = clean.slice(0, clean.lastIndexOf(' ')) || clean.slice(0, 500);
  }

  clean = clean.trim();

  if (!clean) {
    return { clean: '[message removed]', wasModified: true, injectionDetected };
  }

  return { clean, wasModified: injectionDetected, injectionDetected };
}

export const CRISIS_RESPONSE = `I hear you, and what you're feeling matters. Please reach out to a crisis line right now:
International: findahelpline.com | Bahrain: 80008001 | US: 988
I'm here when you're ready to talk about your habits too. 💙`;
