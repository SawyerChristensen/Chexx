# Hex Chess — To Do
---

## Update 1.5 — Mac Port  💻
- [x] There is a bug loading my google icon photo. I signed out and in to my google account again but my photo doesnt still doesnt show up.
- [x] Add an official Mac post of Hex Chess that has a square window. Modify our scroll views or whatever to use what is reccomended UI for Mac
  - [x] Set a fixed/square default window size on Mac (e.g. via WindowGroup's defaultSize / windowResizability) sized for the hex board
- [x] The book icon seems stretched horizontally. the icons dont need to fill the frame. the frame should just act as an outer limit to the space the icon can occupy and work for hittesting. The icon should retain its normal aspect ratio/look
- [~] Add Notifications!
  - [x] Add local notification permission infrastructure (NotificationManager, request authorization) and wire the "Player Turn Notification" toggle in Settings to request/reflect it
  - [x] Enable Push Notifications capability, register for remote notifications, and store APNs/FCM device tokens per user in Firestore
  - [~] Send a push notification to the opponent when a move is made in an online game (Cloud Function trigger on Firestore game document update)
    - [x] Register for an FCM token (FirebaseMessaging) alongside the existing raw APNs device token and store it per-user in Firestore, so a Cloud Function can target devices via the Firebase Admin SDK
    - [x] Scaffold a Firebase Cloud Functions project (functions/ dir) with a Firestore onUpdate trigger that detects a new move and sends a push notification to the opponent's stored FCM token
    - [ ] Deploy the Cloud Function and verify push notifications work end-to-end (requires Firebase CLI login/credentials — human step)
  - [x] Add "live activities" notifications for games? Have a little preview of the board on the right of the notification, and then text that says "[opponent username] [moved to/captured] [tile/piece at tile]" similar to what we do with imessage
    - [x] Add ActivityKit groundwork: NSSupportsLiveActivities in Info.plist, shared GameLiveActivityAttributes/ContentState model, and a LiveActivityManager to start/update/end activities (main app target only)
    - [x] Add a Widget Extension target (e.g. ChexxWidgets) with ActivityKit support for the Live Activity UI (lock screen + Dynamic Island), showing a small board preview
    - [x] Wire LiveActivityManager into the move-handling/push-notification flow so the opponent's move updates the Live Activity with a board preview and "[opponent] [moved to/captured] [tile/piece]" text
- [x] Review the turkish translation and make sure we use the new terminology "Altıgen Satranç"
- [x] Review the korean translation and make sure we use the new terminology "육각형 체스"
- [x] Add the fact we dont have any encryption in the app to the apps plist so that we dont have to check the button every time in App Store Connect
- [~] Review app for view inefficiencies so that the app runs as smoothly as possible
  - [x] Fix MainMenuView.swift: remove the `.id(refreshID)`/UUID trick that forced SwiftUI to destroy and rebuild the entire main-menu subtree on every appear, and replace the `AnyView`-erasing `ColorInvertIfDarkModeModifier` with a `@ViewBuilder` implementation
  - [ ] Audit ProfileView.swift and SettingsWindow.swift for redundant Firestore/network calls or recomputation triggered from the view body
  - [ ] Audit GameScene.swift/HexagonNode for repeated per-call work in generateHexTiles/placePieces (e.g. re-parsing UIColor(hex:) constants) that could be hoisted out of hot paths
  - [ ] Audit remaining SwiftUI screens (GameOverWindow, GameLinkSheet, TutorialSheet, PromotionWindow) for AnyView usage, GeometryReader misuse, or other unnecessary view-identity churn
  - [ ] Audit HexChessLite (iMessage extension) views for the same view-inefficiency patterns
- [ ] Enable 120 hz in app settings/dynamic framerates. the app should be 10hz when just looking at the board, 120hz when a piece is moving if possible
- [ ] Remove the "Thinking" CPU animation glow and make it much smaller
- [ ] Go to metadata.json and replace the update notice there with a translated "[localized name for Hex Chess] now natively supports macOS!" for every local before running upload\_metadata with just the update notice argument
- [ ] When I validate or upload my app, there are a couple warnings although they are not critical. I'll list them here: "Upload Symbols Failed
The archive did not include a dSYM for the FirebaseAnalytics.framework with the UUIDs [26293A07-BCC7-38AE-9EEC-3ED8FAC81379]. Ensure that the archive's dSYM folder includes a DWARF file for FirebaseAnalytics.framework with the expected UUIDs.

Upload Symbols Failed
The archive did not include a dSYM for the FirebaseFirestoreInternal.framework with the UUIDs [8ED328E4-50A6-3597-806D-B1B83CC9E391]. Ensure that the archive's dSYM folder includes a DWARF file for FirebaseFirestoreInternal.framework with the expected UUIDs.

Upload Symbols Failed
The archive did not include a dSYM for the GoogleAppMeasurement.framework with the UUIDs [C76BAB2B-80E5-3C3E-BB4F-5B56155FD24A]. Ensure that the archive's dSYM folder includes a DWARF file for GoogleAppMeasurement.framework with the expected UUIDs.

Upload Symbols Failed
The archive did not include a dSYM for the absl.framework with the UUIDs [50755F1C-66E6-3B25-B216-C07F2BDD4244]. Ensure that the archive's dSYM folder includes a DWARF file for absl.framework with the expected UUIDs.

Upload Symbols Failed
The archive did not include a dSYM for the grpc.framework with the UUIDs [B6F6C9E2-1EEC-38D1-B756-603410A0708A]. Ensure that the archive's dSYM folder includes a DWARF file for grpc.framework with the expected UUIDs.

Upload Symbols Failed
The archive did not include a dSYM for the grpcpp.framework with the UUIDs [62CB9CC2-5216-3561-8663-DB920B3DEEA3]. Ensure that the archive's dSYM folder includes a DWARF file for grpcpp.framework with the expected UUIDs.

Upload Symbols Failed
The archive did not include a dSYM for the openssl_grpc.framework with the UUIDs [0A8C77A3-2823-3285-843A-62B5BB169964]. Ensure that the archive's dSYM folder includes a DWARF file for openssl_grpc.framework with the expected UUIDs." If you can include those dSYM files somehow so that these warnings don't appear anymore that would be great


- [ ] App Store Connect/photoshop work:
  - [ ] Better App Store pictures for iPad (1/3 of all users!!) Is this what mac uses
  - [ ] Listing canvas gaps should be shorter?
  - [ ] Modify Russian listing photo text?
  - [ ] Modify the Chinese listing photo text?

---

## Update 1.6 — Multiplayer v2  􀉬
NOTE: DO NOT START ON THIS UNTIL ALL OF 1.5 IS DONE
- [x] "Waiting for opponent..." should be animated like in iMessage
- [x] See if how we determine winner color is redundant
- [ ] Make the main title slowly pulse from 0.98 to 1.02 in size
- [x] Changing Google icon breaks Google icon retrieval in app
- [x] Stalemate is not a draw. Instead the player delivering stalemate receives 0.75 points and the stalemated player receives 0.25 (implement for multiplayer ruling)
- [x] In multiplayer, add the player's flag next to their username if they have a country selected in profile view
- [ ] Home Screen quick actions?
- [ ] If you create an online game, enter, do nothing, and leave, the game does not automatically get deleted. Currently not an issue since each account is "allowed" one empty created game — any previously created game is removed from the server on every new create-game call. Better to delete the game when the game view is dismissed and it is empty
- [ ] Login does not check if your email is actually real
- [ ] In multiplayer, show opponent's Game Center icon if they don't have a Google icon
- [ ] If user is anonymous, do not update Elo. Is this still needed?
- [ ] User country loads from Firestore every time profile is opened; local storage should update from Firestore once the app is opened, then pull from local every profile view
- [ ] Elo is checked every profile view — can maybe use a local toggle to see if it's been changed in a recent game before asking the server, eliminating redundant server calls (not necessary for now)
- [ ] Store user picture on device and only load when it changes? Having it load is a little jarring (low priority)

---

## Update 1.7 — CPU  🤖
NOTE: DO NOT START ON THIS UNTIL ALL OF 1.5 IS DONE
- [ ] Make CPU better at endgames by increasing depth searches if opponent has limited pieces
- [ ] Make the "waiting for opponent" screen in iMessage more similar to DeckedOut, where the "Waiting for opponent..." space is reserved, made invisible, and then the animated text is added over it
- [ ] Turn into AI? (TensorFlow, PyTorch) (AlphaZero loop on GPU?)
- [x] gameCPU will not see knight's moves upon promotion, only queen
- [ ] Leaderboard button underneath profile view — simply rank all users by Elo (icon represented by trophy)
  - [ ] Display first name, country emoji, Elo?
- [ ] End game screen displaying username instead of color?
- [ ] Add random matchmaking if you're signed in?
  - [ ] If added, need name checking for online play (just hide the icons, unless joining a friend's game)
- [ ] Make games more secure? (works perfectly fine for now)
- [ ] Enable an option to play as black against the CPU (would need to change promotion logic)
- [ ] Optimizations to game CPU

### CPU Performance Notes
| Depth | Time | Notes |
| --- | --- | --- |
| 1 | 0.01 seconds | |
| 2 | ~0.2 seconds | |
| 3 | ~2.0 seconds | Depth 3 is target default |
| 4 | ~20 seconds | Unacceptable |

- Look for current eval functions that loop through the game state — they are all likely O(n²) and slow
- Use hashing / transposition tables / other techniques to speed this up, especially at higher depths when we potentially eval the same state multiple times

### Possible Future Optimizations
| Optimization | Expected Speedup | Status |
| --- | --- | --- |
| Alpha-Beta Pruning | Up to 10x reduction in search space | Done? Make sure it works optimally |
| Multi-Threading (Parallel Search) | Up to 2–8x, depending on hardware | Make sure it doesn't load the GS every thread — might be why it's so slow right now |
| Hashing (Zobrist Hashing) | 10–50% | |
| Transposition Tables (TT) | 20–100%, depending on position complexity | |
| Parallelized Evaluation Functions | 2–4x, depending on how parallelizable | |
| SIMD & GPU Offloading | 2–10x, depending on hardware and implementation | |
| Move Ordering & Iterative Deepening | 10–30% | Did move ordering |
| Late Move Reductions | 10–30% | |
| Null Move Pruning | 10–20% | |

- Prioritize looking at branches over the current branch max that involve a piece if the user taps on a piece (likely to be moving that piece)
- Do CPU calculations in the background with increasing depths — use the idea above
*(Might be able to get to depth 4 with all of these improvements.)*

---

## Update 1.8 — Achievements
NOTE: DO NOT START ON THIS UNTIL ALL OF 1.4 IS DONE
- [ ] Automate all Game Center translation changes, similar to how DeckedOut does it
- [ ] Update the mail achievement icon and first win icon
- [ ] Game Center achievements for Dutch
- [ ] App Store pictures for Dutch

### Achievements
| Achievement | Description | Status |
| --- | --- | --- |
| Hexceptional Win! | Win your first game | Implemented |
| Hex Machina | Checkmate the CPU | Implemented |
| Hexceeded Hexpectations | Win a joined game | Implemented |
| Friendly Hexchange | Have a player join a game you created | Implemented |
| Hexcalibur | Underpromote a pawn to a knight | Implemented |
| Hexecutioner | Checkmate after capturing all enemy pieces | Implemented |
| Hexperimenter | Win with 10 different openings | |
| Hexathon | Win 26 games | |
| Hexpedition | Move your king to the opposing king's starting position | Implemented |
| Hexplorer | Visit every tile in a single game | |
| Hextra Power | Promote a pawn for the first time | Implemented |
| Hexceptional Morale | Promote 3 pawns in a single game | |
| The Great Hexcape | Checkmate after being put in check 3 times | |
| Hexclusion Zone | Deliver a smothered mate | |
| Hextreme Measures | Checkmate using your own king | Implemented |
| Tactical Hexcellence | Checkmate without losing any pieces | |

### Secret Achievements
| Achievement | Description | Status |
| --- | --- | --- |
| Hexpect the Unexpected | Open by moving your king | |
| Hexhausted | Have a game last over 100 turns | |
| Seasoned Hexpert | Complete all other achievements | |
| Un-Hexciting Finish | Deliver a stalemate | |

---

## ⚙️ Other Changes
NOTE: DO NOT START ON THIS UNTIL ALL OF 1.4 IS DONE

### Bugs
- [ ] Game Center icon only loads the second time looking at the profile? (check if still true)

### iMessage
- [ ] Figure out memory problem with resizing the window??
- [ ] Make `applyUpdate` more elegant — wait until the view is completely on screen before showing what the last user did. Right now it applies the move AS the view is scrolling up and being presented, jumping the gun a little. Currently we call `applyUpdate` by setting `latestHexPGN` whenever the view is activated or selected
- [ ] Make the message captions different based on user and also animated (like GamePigeon)
- [ ] Standardize the start game button across languages (we currently have a bandaid fix). Make the text adjustable for accessibility/device — right now it's hardcoded by screen size
- [ ] "Waiting for opponent" in Spanish is really weird and breaks to multiple lines

### General
- [ ] Android version?
- [ ] Facebook sign in?
- [ ] Look into Apple Games app multiplayer invites?
- [ ] Change profile icon to Game Center access point? (Apple only!!)
- [ ] Refine UI for iPad (country picker, font, achievement stars). 
- [ ] 50-move no-capture rule for draw
- [ ] Threefold repetition rule for draw
  - [ ] Zobrist hashing for more efficient computation of threefold-rule detection — not needed at launch, could be an important update
- [ ] Get rid of "not verified for macOS" badge in macOS App Store (it's still available as is)
- [ ] Game history button in profile view? (store past user games — who vs who — and then display hex FEN format)
  - [ ] Single player stored on device, multiplayer stored in cloud
- [ ] Haptic feedback on check?
- [ ] Alternate board color schemes in settings? (beige, grayscale, black/white/red, other?)
  - Beige — Light tile: `#ffce9e`, "Grey" tile: `#e8ab6f`, Dark tile: `#d18b47`
  - [ ] Put color schemes in profile view?
- [ ] Check if any flags have been added in new Unicode versions
- [ ] Add mirror matches option for local play? (only for iPad?)
- [ ] Favorite opening in profile view?
- [ ] Enable variants — different pawn rules for Mathewson's & McCooey's (as well as different starting positions)
  - [ ] McQuay's
- [ ] Enable a "show rows/columns A–L, 1–11" option in settings
- [ ] Maybe delete storyboards? (Safer not to mess with them unless I know exactly what I'm doing — they seem to be "ignored" already, but deleting them also seems to cause problems)

---

## Resources

- [Ways to update chess AI / increase computational efficiency](https://web.archive.org/web/20071026090003/http://www.brucemo.com/compchess/programming/index.htm)
- [General Chess Programming Info](https://www.chessprogramming.org/Main_Page)
- [Glinski's Hexchess (Hexagonal chess)](https://en.wikipedia.org/wiki/Hexagonal_chess)



