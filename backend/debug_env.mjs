const k = process.env.ANTHROPIC_API_KEY;
const db = process.env.DATABASE_URL;
const redis = process.env.REDIS_URL;
console.log(JSON.stringify({
  dbLen: db ? db.length : -1,
  dbStart: db ? db.substring(0, 15) : 'MISSING',
  redisLen: redis ? redis.length : -1,
  aiLen: k ? k.length : -1,
  aiStart: k ? k.substring(0, 15) : 'MISSING',
}));
