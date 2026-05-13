require('dotenv').config({ override: true });
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const user = await prisma.user.update({
    where: { email: 'testuser99@example.com' },
    data: { emailVerified: true },
    select: { id: true, email: true, emailVerified: true },
  });
  console.log('Updated:', JSON.stringify(user));
}

main().then(() => prisma.$disconnect()).catch(e => { console.error(e.message); prisma.$disconnect(); });
