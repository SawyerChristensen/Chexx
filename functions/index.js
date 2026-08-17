const { onDocumentUpdated, onDocumentCreated } = require("firebase-functions/v2/firestore");
const { setGlobalOptions } = require("firebase-functions/v2");
const logger = require("firebase-functions/logger");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
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

// Mirrors MultiplayerManager.generateGameCode()'s 6-uppercase-letter format, retrying on the rare
// collision with an already-existing game.
async function generateUniqueGameCode() {
  const letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  const maxAttempts = 5;
  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    const code = Array.from({ length: 6 }, () => letters[Math.floor(Math.random() * letters.length)]).join("");
    const existing = await db.collection("games").doc(code).get();
    if (!existing.exists) return code;
  }
  throw new Error("Failed to generate a unique game code after multiple attempts.");
}

// Whenever a player joins the queue, check whether there are now (at least) two players waiting
// to be paired, and if so, match the two who have been waiting the longest into a new game.
// Runs on every queue join rather than just the triggering document, so a burst of joins still
// converges on everyone being paired two at a time.
exports.matchPlayers = onDocumentCreated("matchmakingQueue/{uid}", async (event) => {
  const queueSnapshot = await db.collection("matchmakingQueue").orderBy("timestamp", "asc").get();
  const waiting = queueSnapshot.docs.filter((doc) => !doc.data().matchedGameId);
  if (waiting.length < 2) return;

  const [first, second] = waiting;
  const gameId = await generateUniqueGameCode();
  const gameRef = db.collection("games").doc(gameId);

  try {
    await db.runTransaction(async (transaction) => {
      const [firstSnap, secondSnap] = await Promise.all([
        transaction.get(first.ref),
        transaction.get(second.ref),
      ]);
      // Re-check inside the transaction in case another invocation already matched either player
      // between the query above and now.
      if (!firstSnap.exists || !secondSnap.exists) return;
      if (firstSnap.data().matchedGameId || secondSnap.data().matchedGameId) return;

      const player1 = firstSnap.data();
      const player2 = secondSnap.data();

      // Mirrors MultiplayerManager.createGame/joinGame's schema: the creator plays black, the
      // joiner plays white, and the game starts "in-progress" since both players are present.
      transaction.set(gameRef, {
        player1Id: player1.uid,
        player1Color: "black",
        player1Elo: player1.elo ?? 1000,
        player2Id: player2.uid,
        player2Color: "white",
        player2Elo: player2.elo ?? 1000,
        hexPgn: [],
        status: "in-progress",
        isRandomMatch: true,
        lastUpdated: FieldValue.serverTimestamp(),
      });

      transaction.update(first.ref, { matchedGameId: gameId });
      transaction.update(second.ref, { matchedGameId: gameId });
    });
  } catch (error) {
    logger.error(`Failed to match players ${first.id} and ${second.id}:`, error);
  }
});
