#!/usr/bin/env node
/**
 * Generate RSA key pair for JWT RS256 signing
 * Run: node scripts/gen-keys.js
 */

const { generateKeyPairSync } = require('crypto');
const fs = require('fs');
const path = require('path');

const keysDir = path.join(__dirname, '..', 'keys');

if (!fs.existsSync(keysDir)) {
  fs.mkdirSync(keysDir, { recursive: true });
}

const { privateKey, publicKey } = generateKeyPairSync('rsa', {
  modulusLength: 2048,
  publicKeyEncoding: { type: 'spki', format: 'pem' },
  privateKeyEncoding: { type: 'pkcs8', format: 'pem' },
});

fs.writeFileSync(path.join(keysDir, 'private.pem'), privateKey, { mode: 0o600 });
fs.writeFileSync(path.join(keysDir, 'public.pem'), publicKey);

// Add to .gitignore
const gitignorePath = path.join(__dirname, '..', '.gitignore');
const gitignoreContent = fs.existsSync(gitignorePath)
  ? fs.readFileSync(gitignorePath, 'utf-8')
  : '';

if (!gitignoreContent.includes('keys/')) {
  fs.appendFileSync(gitignorePath, '\nkeys/\n.env\n');
}

console.log('✅ RSA key pair generated:');
console.log('  keys/private.pem (keep secret!)');
console.log('  keys/public.pem');
console.log('\n⚠️  keys/ added to .gitignore — NEVER commit private keys');
