/**
 * Cloud Functions for tenant-and-landlord-app-fad4c
 *
 * Responsibilities:
 * 1. sendPushToUser() — the only place that calls FCM. Fired whenever a
 *    /notifications/{id} doc is created (by any of the triggers below).
 * 2. Example triggers that create notification docs for the four types
 *    already in the mockups: new message, ticket status change, payment
 *    confirmed, and system alert. These assume a `tickets` and `payments`
 *    collection shaped like the comments below — adjust field names to
 *    match your actual schema, the shape is a reasonable starting guess.
 *
 * Deploy: npm install && firebase deploy --only functions --project tenant-and-landlord-app-fad4c
 */

const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');
const { onDocumentCreated, onDocumentUpdated } = require('firebase-functions/v2/firestore');
const { logger } = require('firebase-functions');

initializeApp();
const db = getFirestore();

/**
 * Writes a new /notifications/{id} doc. This is the ONLY way notification
 * docs should be created — clients are blocked from creating them directly
 * by firestore.rules, so every notification the user sees originates here.
 */
async function createNotification(userId, { type, title, body, ticketId, metadata }) {
  if (!userId) {
    logger.warn('createNotification called without a userId, skipping', { type, title });
    return;
  }
  await db.collection('notifications').add({
    userId,
    type,
    title,
    body,
    ticketId: ticketId ?? null,
    metadata: metadata ?? {},
    read: false,
    createdAt: FieldValue.serverTimestamp(),
  });
}

/**
 * Looks up the user's registered device tokens and sends a push to all of
 * them, pruning any tokens FCM reports as dead/unregistered.
 */
async function sendPushToUser(userId, { title, body, data = {} }) {
  const userSnap = await db.collection('users').doc(userId).get();
  const tokens = userSnap.data()?.fcmTokens ?? [];
  if (tokens.length === 0) return;

  const response = await getMessaging().sendEachForMulticast({
    tokens,
    notification: { title, body },
    data,
  });

  const deadTokens = [];
  response.responses.forEach((res, i) => {
    if (!res.success) {
      const code = res.error?.code;
      if (
        code === 'messaging/invalid-registration-token' ||
        code === 'messaging/registration-token-not-registered'
      ) {
        deadTokens.push(tokens[i]);
      }
    }
  });

  if (deadTokens.length > 0) {
    await db.collection('users').doc(userId).update({
      fcmTokens: FieldValue.arrayRemove(...deadTokens),
    });
  }
}

// ---------------------------------------------------------------------
// 1. Fires on EVERY notification doc, regardless of which trigger below
//    created it. This is what actually delivers the push.
// ---------------------------------------------------------------------
exports.onNotificationCreated = onDocumentCreated(
  'notifications/{notificationId}',
  async (event) => {
    const data = event.data.data();
    await sendPushToUser(data.userId, {
      title: data.title,
      body: data.body,
      data: {
        notificationId: event.params.notificationId,
        type: data.type ?? '',
        ticketId: data.ticketId ?? '',
      },
    });
  }
);

// ---------------------------------------------------------------------
// 2. New technician message on a ticket.
//    Assumes: tickets/{ticketId} has a `userId` field (the tenant/owner),
//    and tickets/{ticketId}/messages/{messageId} has `senderId`,
//    `senderName`, `text`.
// ---------------------------------------------------------------------
exports.onNewTicketMessage = onDocumentCreated(
  'tickets/{ticketId}/messages/{messageId}',
  async (event) => {
    const message = event.data.data();
    const ticketSnap = await db.collection('tickets').doc(event.params.ticketId).get();
    const ticket = ticketSnap.data();
    if (!ticket) return;

    // Don't notify someone about their own message.
    if (message.senderId === ticket.userId) return;

    await createNotification(ticket.userId, {
      type: 'message',
      title: 'New Message',
      body: `Your technician, ${message.senderName || 'a technician'}, has sent a message regarding Ticket #${event.params.ticketId}.`,
      ticketId: event.params.ticketId,
    });
  }
);

// ---------------------------------------------------------------------
// 3. Ticket status changes (e.g. -> IN PROGRESS, RESOLVED).
//    Assumes: tickets/{ticketId} has `userId` and `status`.
// ---------------------------------------------------------------------
exports.onTicketStatusChanged = onDocumentUpdated(
  'tickets/{ticketId}',
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();
    if (before.status === after.status) return;

    const status = (after.status || '').toUpperCase();
    await createNotification(after.userId, {
      type: 'status_update',
      title: 'Status Update',
      body: `Ticket #${event.params.ticketId} has been marked as ${status}.`,
      ticketId: event.params.ticketId,
      metadata: { status },
    });
  }
);

// ---------------------------------------------------------------------
// 4. Payment confirmed.
//    Assumes: payments/{paymentId} has `userId`, `description`, `receiptId`.
// ---------------------------------------------------------------------
exports.onPaymentConfirmed = onDocumentCreated(
  'payments/{paymentId}',
  async (event) => {
    const payment = event.data.data();
    const receiptId = payment.receiptId || event.params.paymentId;
    await createNotification(payment.userId, {
      type: 'payment_confirmed',
      title: 'Payment Confirmed',
      body: `Payment for ${payment.description || 'your recent charge'} has been received. Receipt #${receiptId}.`,
      metadata: { receiptId },
    });
  }
);

// ---------------------------------------------------------------------
// System alerts (e.g. overdue maintenance) don't have one obvious trigger
// document in a generic schema. Wherever your app marks something
// "overdue" (a scheduled function, another trigger, etc.), just call
// createNotification(userId, { type: 'system_alert', title: 'System Alert',
// body: '...' }) from that same file — it's a plain function above, not
// exported directly, since only onDocumentCreated/onDocumentUpdated/etc.
// exports are valid deployable Cloud Functions.
// ---------------------------------------------------------------------
