# 🔥 Quitly — Full-Stack Production App

A complete habit-quitting and streak-tracking app with AI coaching.

**Stack:**
- **Backend**: Node.js 20 · TypeScript 5 · Fastify v4 · PostgreSQL 16 · Prisma · Redis 7 · BullMQ · JWT RS256 · Claude AI (claude-sonnet-4)
- **Frontend**: Flutter 3.22 · Dart 3.4 · Riverpod · GoRouter · Dio · SSE streaming

---

## 📁 Project Structure

```
QuitlyApp/
├── backend/          ← Node.js API server
│   ├── src/
│   │   ├── config/   ← env, redis, prisma
│   │   ├── modules/  ← auth, habits, checkins, streaks, savings, stats, ai, community, quotes, health
│   │   ├── jobs/     ← BullMQ workers (streak-check, freeze-earn, weekly-report, daily-reminder)
│   │   ├── plugins/  ← Fastify plugins (jwt, cors, helmet, rate-limit)
│   │   └── shared/   ← utils (email, fcm), middleware
│   ├── prisma/       ← schema + seed
│   ├── keys/         ← RSA keys (generated, gitignored)
│   └── tests/        ← Vitest unit + integration tests
└── frontend/         ← Flutter mobile app
    └── lib/
        ├── core/     ← theme, router, network, storage, errors
        ├── features/ ← auth, home, habits, checkins, progress, ai, profile
        └── shared/   ← widgets, providers
```

---

## 🚀 Backend Setup

### Prerequisites
- Node.js 20+
- Docker & Docker Compose (for PostgreSQL + Redis)
- An Anthropic API key

### 1. Install dependencies
```bash
cd backend
npm install
```

### 2. Configure environment
```bash
cp .env.example .env
# Edit .env — set ANTHROPIC_API_KEY and other values
```

### 3. Generate RSA keys (JWT RS256)
```bash
npm run keys:gen
```

### 4. Start database + Redis
```bash
npm run docker:up
```

### 5. Run migrations + seed
```bash
npm run db:generate   # generate Prisma client
npm run db:migrate    # create tables
npm run db:seed       # seed badges, quotes, health milestones
```

### 6. Start development server
```bash
npm run dev
```

API running at: http://localhost:4000
Swagger docs: http://localhost:4000/docs

---

## 📱 Flutter Setup

### Prerequisites
- Flutter 3.22+ SDK
- Android Studio / Xcode
- Running backend

### 1. Get dependencies
```bash
cd frontend
flutter pub get
```

### 2. Generate code (freezed, riverpod, retrofit)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Set API URL
The API URL defaults to `http://10.0.2.2:4000/api/v1` (Android emulator localhost).

For physical device, set it at build time:
```bash
flutter run --dart-define=API_URL=http://YOUR_IP:4000/api/v1
```

### 4. Run the app
```bash
flutter run
```

---

## 🐳 Full Docker deployment

```bash
cd backend
# Copy and configure .env
cp .env.example .env
# Edit .env with your values

# Generate RSA keys
npm run keys:gen

# Start everything
docker compose up -d

# Run migrations in container
docker exec quitly_api npx prisma migrate deploy
docker exec quitly_api npm run db:seed
```

---

## 🔑 API Endpoints

### Auth
| Method | Route | Description |
|--------|-------|-------------|
| POST | /api/v1/auth/register | Register new user |
| POST | /api/v1/auth/login | Login |
| POST | /api/v1/auth/refresh | Refresh JWT |
| POST | /api/v1/auth/logout | Logout |
| POST | /api/v1/auth/logout-all | Logout all devices |
| GET | /api/v1/auth/verify-email | Verify email |
| POST | /api/v1/auth/forgot-password | Request password reset |
| POST | /api/v1/auth/reset-password | Reset password |
| POST | /api/v1/auth/change-password | Change password |

### Habits
| Method | Route | Description |
|--------|-------|-------------|
| GET | /api/v1/habits | List habits |
| POST | /api/v1/habits | Create habit |
| PATCH | /api/v1/habits/:id | Update habit |
| DELETE | /api/v1/habits/:id | Delete habit |
| POST | /api/v1/habits/:id/archive | Archive habit |

### Checkins
| Method | Route | Description |
|--------|-------|-------------|
| POST | /api/v1/checkins | Record check-in |
| GET | /api/v1/checkins | List check-ins |
| GET | /api/v1/checkins/heatmap | Year heatmap data |

### Streaks
| Method | Route | Description |
|--------|-------|-------------|
| GET | /api/v1/streaks/:habitId | Get streak |
| GET | /api/v1/streaks/freeze-tokens | List freeze tokens |
| POST | /api/v1/streaks/freeze | Use freeze token |

### AI Coach
| Method | Route | Description |
|--------|-------|-------------|
| POST | /api/v1/ai/chat | SSE streaming chat |
| GET | /api/v1/ai/suggestions | Personalized prompts |
| GET | /api/v1/ai/weekly-summary | Weekly AI summary |
| DELETE | /api/v1/ai/history | Clear chat history |

---

## 🧪 Testing

```bash
cd backend
npm test              # run all tests
npm run test:watch    # watch mode
npm run test:coverage # coverage report
```

---

## 🔒 Security Features

- JWT RS256 asymmetric key signing
- Refresh token rotation + reuse detection (family-based)
- Argon2id password hashing (65536 memory cost)
- Redis sliding window rate limiting per endpoint
- Helmet.js security headers
- CORS with explicit origin allowlist
- Prompt injection sanitization for AI
- Crisis signal detection in AI chat
- Email enumeration prevention on forgot-password

---

## 📋 Background Jobs (BullMQ)

| Job | Schedule | Description |
|-----|----------|-------------|
| streak-check | Daily midnight | Break streaks for missed check-ins |
| freeze-earn | Daily 6am | Award freeze tokens for 7-day check-in |
| weekly-report | Monday 9am | Send AI-generated weekly email reports |
| daily-reminder | Daily 8pm | Push notifications for pending habits |

---

## 🌱 Health Milestones

Pre-seeded for **smoking**, **alcohol**, and **general** habit types.
Smoking milestones: 20min, 12h, 2d, 2w, 1m, 3m, 6m, 1y, 5y
Each includes the biological change and category.

---

## 🤖 AI Coach (Aria)

- Powered by `claude-sonnet-4-20250514`
- Dynamic system prompt built from live user data (streaks, XP, habits)
- Context cached in Redis (5-minute TTL)
- Conversation history in Redis (20 turns, 7-day TTL)
- SSE streaming to Flutter client
- Crisis signal detection → safe response with helplines
- Prompt injection sanitization
- Personalized suggestions generated per user
