const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { setGlobalOptions } = require("firebase-functions/v2");
const logger = require("firebase-functions/logger");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();
setGlobalOptions({ maxInstances: 10 });

const db = getFirestore();
const messaging = getMessaging();

// hexPgn[0] is a variant identifier; every move after that is encoded as a
// [from, to] byte pair. This mirrors GameState.swift's turn derivation so the
// function agrees with the client on whose turn it now is.
function colorToMove(hexPgn) {
  const moveCount = Math.floor((hexPgn.length - 1) / 2);
  return moveCount % 2 === 0 ? "white" : "black";
}

exports.sendMoveNotification = onDocumentUpdated("games/{gameId}", async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();
  if (!before || !after) return;

  const beforePgn = before.hexPgn || [];
  const afterPgn = after.hexPgn || [];

  // Only notify once a game is actually underway and a new move was appended.
  if (after.status !== "in-progress") return;
  if (afterPgn.length <= beforePgn.length) return;

  const player1Id = after.player1Id;
  const player2Id = after.player2Id;
  const player1Color = after.player1Color;
  const player2Color = after.player2Color;
  if (!player1Id || !player2Id || !player1Color || !player2Color) return;

  // Whoever is now "to move" is the opponent of the player who just moved.
  const toMoveColor = colorToMove(afterPgn);
  const opponentId = player1Color === toMoveColor ? player1Id : player2Id;
  const moverId = opponentId === player1Id ? player2Id : player1Id;

  const [opponentSnap, moverSnap] = await Promise.all([
    db.collection("users").doc(opponentId).get(),
    db.collection("users").doc(moverId).get(),
  ]);

  const fcmToken = opponentSnap.data()?.fcmToken;
  if (!fcmToken) {
    logger.info(`No FCM token stored for user ${opponentId}; skipping notification.`);
    return;
  }

  const moverName = moverSnap.data()?.displayName || "Your opponent";

  try {
    await messaging.send({
      token: fcmToken,
      notification: {
        title: "Hex Chess",
        body: `${moverName} made a move. It's your turn!`,
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
          },
        },
      },
      data: {
        gameId: event.params.gameId,
      },
    });
  } catch (error) {
    logger.error(`Failed to send move notification to ${opponentId}:`, error);
  }
});
