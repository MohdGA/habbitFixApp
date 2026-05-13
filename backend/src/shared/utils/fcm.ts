import admin from 'firebase-admin';
import { env } from '../../config/env.js';

let initialized = false;

function initFirebase() {
  if (initialized) return;
  if (!env.FIREBASE_PROJECT_ID || !env.FIREBASE_CLIENT_EMAIL || !env.FIREBASE_PRIVATE_KEY) {
    console.warn('Firebase not configured — push notifications disabled');
    return;
  }

  admin.initializeApp({
    credential: admin.credential.cert({
      projectId: env.FIREBASE_PROJECT_ID,
      clientEmail: env.FIREBASE_CLIENT_EMAIL,
      privateKey: env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
    }),
  });
  initialized = true;
}

export async function sendPushNotification(
  fcmToken: string,
  notification: { title: string; body: string; data?: Record<string, string> },
): Promise<void> {
  initFirebase();
  if (!initialized) return;

  await admin.messaging().send({
    token: fcmToken,
    notification: {
      title: notification.title,
      body: notification.body,
    },
    data: notification.data,
    android: { priority: 'high' },
    apns: { payload: { aps: { sound: 'default', badge: 1 } } },
  });
}

export async function sendPushToMultiple(
  fcmTokens: string[],
  notification: { title: string; body: string; data?: Record<string, string> },
): Promise<void> {
  initFirebase();
  if (!initialized || fcmTokens.length === 0) return;

  const chunks = [];
  for (let i = 0; i < fcmTokens.length; i += 500) {
    chunks.push(fcmTokens.slice(i, i + 500));
  }

  for (const chunk of chunks) {
    await admin.messaging().sendEachForMulticast({
      tokens: chunk,
      notification: { title: notification.title, body: notification.body },
      data: notification.data,
    });
  }
}
