# Hex Chess — To Do
---

## Update 1.5 — Mac Port  💻
- [x] There is a bug loading my google icon photo. I signed out and in to my google account again but my photo doesnt still doesnt show up.
- [x] Review the CPU file/struct/class structure and see if there are any inefficiencies there. Do another general review of the CPU architecture and see if there are any performance gains to be made. If you find any, list them here and do them one by one.
  - [x] minimax() called gameState.isGameOver() (a full legal-move-existence scan) and then generateAllFullMoves() (a full legal-move-list build) back to back at every internal search node, duplicating the same per-piece legality filtering. Generate the move list once per node and derive "no legal moves" from its emptiness instead.
  - [x] filterMovesThatExposeKing (PieceRules.swift) checks each pseudo-legal move's legality by doing a full makeMove + isKingInCheckUsingKingSight ray-scan + unmakeMove, for every candidate move of every piece, every node — this is the dominant cost in the tree and compounds with depth. Replace with real pin/check-ray detection that doesn't require simulating each move. (Added `isPinned`: a cheap remove-piece/re-scan-king-sight check that identifies pinned pieces via ray diffing. Non-king, non-pawn pieces that aren't pinned and whose king isn't already in check now skip the make/unmake simulation entirely and return their pseudo-legal moves as-is. Pawns are still simulated per-move because en passant can drop two pawns off the same rank at once, which single-piece pin detection can't catch.)
  - [x] Move generation/search is String-based end-to-end (e.g. "A1-B2"), forcing repeated parse/allocate round-trips (hexColumns.firstIndex(of:) etc.) in GameCPU, PieceRules, GameState.makeMove, and evaluateMove's move-ordering sort. Thread (col,row) Int tuples through the hot path instead of algebraic-notation strings.
    - [x] Replace the ~17 `hexColumns.firstIndex(of: String(letter))` linear scans (which also allocated a throwaway String per call) across GameCPU, GameScene, PieceRules, and GameState with an O(1) `hexColumnIndex(for:)` letter-to-index helper.
    - [x] Add (col,row) tuple overloads of GameState.pieceAt/makeMove/unmakeMove that skip the notation-string round trip when the caller (GameCPU's search loop) already has indices, keeping the existing String-based versions as thin wrappers for other callers (GameScene, multiplayer sync).
    - [x] Convert PieceRules' validMovesFor* generators (pawn/rook/bishop/king/knight) to build (col,row) tuples internally and convert to notation strings only once at the public API boundary.
    - [x] Convert GameCPU's SearchMove/generateAllFullMoves/evaluateMove/orderMoves to operate on (col,row) tuples end-to-end, formatting to a notation string only for the final chosen move.
      - [x] Convert PieceRules' pawnPureCaptures and isKingInCheckUsingKingSight to tuple-based cores (mirroring the validMovesFor* pattern), keeping the String-based versions as thin wrappers that parse/format only at the boundary.
      - [x] Convert PieceRules' isPinned and filterMovesThatExposeKing to tuple-based cores using the new tuple isKingInCheckUsingKingSight, keeping String-based wrappers as thin boundary converters.
      - [x] Add a tuple-based validMovesForPiece dispatcher that calls the tuple piece-type generators and the tuple filterMovesThatExposeKing directly, keeping the String-based validMovesForPiece as a thin wrapper.
      - [x] Convert GameCPU's SearchMove struct to store (col,row) indices instead of notation strings, and update generateAllFullMoves/evaluateMove/orderMoves/minimax to use the tuple validMovesForPiece/pieceAt/makeMove path end-to-end, formatting a notation string only for the final chosen move and the transposition-table best-move key.
  - [x] Queen move generation builds `Array(Set(rookMoves + bishopMoves))` to dedupe, which is unnecessary since rook- and bishop-direction destinations for a queen never overlap — just concatenate the arrays. (Resolved as a side effect of the tuple-based validMovesForPiece dispatcher above, which concatenates instead of deduping and is now the sole implementation the String-based wrapper calls.)
- [x] Create an extensive CPU testing suite to make sure the CPU works as intended. Be able to log exact time differences and % increases in efficiency.
  - [x] Add an XCTest unit test target (ChexxTests) to the Xcode project, wired into the Chexx scheme's Test action, with a minimal placeholder test to confirm the target builds and runs
  - [x] Add CPU correctness tests: known checkmate/stalemate positions and legal-move-count (perft-style) assertions against GameState/PieceRules to verify move generation correctness
  - [x] Add a CPU search benchmarking test/utility that times minimax at depths 1-4, logs exact elapsed time per depth, and computes % speedup versus a recorded baseline
  - [x] Maybe checkout an earlier commit (a commit from 3 months ago), test and save the CPU’s performance data somewhere beyond the scope of the project, revert back to the most modern commit, and compare the old statistic to a recent test/what we have now. (Benchmarked commit `6fb8b47` (2026-04-29, pre-tuple/pre-isPinned/pre-TT) against `auto-dev` HEAD `41d8995` (2026-07-21) via a standalone `swiftc -O` harness in a scratch git worktree, since the old commit predates the ChexxTests target. Results saved outside the repo at `~/Documents/ChexxCPUBenchmarkHistory.md`: depth 4 sped up ~85% (2.6449s → 0.3880s), depths 1-3 sped up 55-69%.)
  - [x] Do one test before and after with depth 5 (same thing as above, add to the same document) (Benchmarked commit `6fb8b47` against `auto-dev` HEAD `59eb790` at depth 5 via the same standalone `swiftc -O` harness approach used for depths 1-4, saved to `~/Documents/ChexxCPUBenchmarkHistory.md`: depth 5 sped up ~82.0% (15.5797s → 2.8072s).)
  - [x] Redo the depth 1-5 old-vs-new CPU benchmark with 3 runs per depth, averaged, for more precise before/after numbers than the current single-run-per-depth results (same standalone `swiftc -O` scratch-worktree methodology as the prior single-run benchmarks, comparing `6fb8b47` vs `auto-dev` HEAD `02546a2`; results appended to `~/Documents/ChexxCPUBenchmarkHistory.md` — speedups of 55-85% across depths 1-5, consistent with the earlier single-run figures)
  - [x] Add CPU behavior tests for edge cases (en passant, castling, promotion choices, pinned-piece move filtering) mentioned in the CPU performance notes (added `ChexxTests/GameRulesEdgeCaseTests.swift` covering en passant capture/non-capture, promotion-type handling including the promoted-knight-moves-like-a-knight regression, and pinned-piece filtering for both an immobilized pinned knight and a pinned rook that can still slide along the pin line; castling doesn't exist in Glinski's hexagonal chess, so it's a no-op here, noted in the test file's header comment)
- [x] Add an official Mac post of Hex Chess that has a square window. Modify our scroll views or whatever to use what is reccomended UI for Mac
  - [x] Set a fixed/square default window size on Mac (e.g. via WindowGroup's defaultSize / windowResizability) sized for the hex board
- [x] The book icon seems stretched horizontally. the icons dont need to fill the frame. the frame should just act as an outer limit to the space the icon can occupy and work for hittesting. The icon should retain its normal aspect ratio/look
- [~] Add Notifications!
  - [x] Add local notification permission infrastructure (NotificationManager, request authorization) and wire the "Player Turn Notification" toggle in Settings to request/reflect it.
  - [x] The ability to send notification should only be enabled after the user enters their first online game. (so they can get updates from the game)
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
- [x] Review app for view inefficiencies so that the app runs as smoothly as possible
  - [x] Fix MainMenuView.swift: remove the `.id(refreshID)`/UUID trick that forced SwiftUI to destroy and rebuild the entire main-menu subtree on every appear, and replace the `AnyView`-erasing `ColorInvertIfDarkModeModifier` with a `@ViewBuilder` implementation
  - [x] Audit ProfileView.swift and SettingsWindow.swift for redundant Firestore/network calls or recomputation triggered from the view body
  - [x] Audit GameScene.swift/HexagonNode for repeated per-call work in generateHexTiles/placePieces (e.g. re-parsing UIColor(hex:) constants) that could be hoisted out of hot paths
  - [x] Audit remaining SwiftUI screens (GameOverWindow, GameLinkSheet, TutorialSheet, PromotionWindow) for AnyView usage, GeometryReader misuse, or other unnecessary view-identity churn
  - [x] Audit HexChessLite (iMessage extension) views for the same view-inefficiency patterns
- [x] Enable 120 hz in app settings/dynamic framerates. the app should be 10hz when just looking at the board, 120hz when a piece is moving if possible
  - [x] Enable ProMotion 120Hz rendering capability (CADisableMinimumFrameDurationOnPhone in Info.plist) and raise SpriteView's preferredFramesPerSecond ceiling to 120 in GameView (main app)
  - [x] Add a shared animation-activity tracker in GameScene that increments/decrements while piece-move slides and repeating highlight/glow/wobble actions are running
  - [x] Wire that tracker into GameView's SpriteView preferredFramesPerSecond so it drops to 10 fps when idle and jumps to 120 fps while any tracked animation is active
  - [x] Apply the same dynamic framerate wiring to the iMessage extension (HexChessLite MGameView/MGameScene)
- [x] Remove the "Thinking" CPU animation glow and make it much smaller
- [~] Go to metadata.json and replace the update notice there with a translated "[localized name for Hex Chess] now natively supports macOS!" for every local before running upload\_metadata with just the update notice argument
  - [x] Update metadata.json's `whats_new` field for every locale to a translated "[localized app name] now natively supports macOS!" release note, using each locale's current CFBundleDisplayName (Chexx/InfoPlist.xcstrings) as the app name
  - [x] Add a `--whats-new-only` flag to scripts/upload\_metadata.py that pushes only the whatsNew field (skipping inherited description/keywords/promotional\_text and Game Center achievements)
  - [ ] Run `upload_metadata.py --whats-new-only` to push the update notice to App Store Connect (requires ASC credentials — human step to execute/confirm)
- [ ] Verfy we will be removing the "Designed for iPad. Not verified for macOS" badge
- [x] Fix the lone warning in MainMenuView
- [ ] Make the main title slowly pulse from 0.98 to 1.02 in size
  - [ ] This is broken! It changes the entire view heirarchy. everything starts pulsing except the main logo. 
  - [ ] Refactor the main view so that instead of geometry readers dividing screen height and width, we give everything normal font numbers. Run base iphone 17 simulations testing the height/width numbers, and compare screenshots before and after
- [ ] Make the "waiting for opponent" screen in iMessage more similar to DeckedOut, where the "Waiting for opponent..." space is reserved, made invisible, and then the animated text is added over it
- [ ] Haptic feedback on check/game win
- [ ] Verify we ask for a review after the 2nd CPU game win

- [ ] App Store Connect/photoshop work:
  - [ ] Better App Store pictures for iPad (1/3 of all users!!) Is this what mac uses?
  - [ ] Listing canvas gaps should be shorter?
  - [ ] Modify Russian listing photo text?
  - [ ] Modify the Chinese listing photo text? Add Chinese Trad

---

## Update 1.6 — CPU  🤖
- [ ] Make 5 the new default search depth
- [ ] Add new hardcoded opening play responses so that we dont even have to run the CPU on the very first move
- [ ] Instead of showing the "Thinking" animation every time, guess how long this calculation will take and only show if it looks like its going to be a long calculation. Is this feasible?
- [ ] Make CPU better at endgames by increasing depth searches if opponent has limited pieces?
- [ ] Research popular optimization techniques that other Chess Engines (such as stockfish use) and implement them here
- [ ] Add AI components to CPU? (TensorFlow, PyTorch) (AlphaZero loop on GPU?) (ideas)
  - [ ] For this to work, many CPU games would have to be simulated at high depths to make good training data
  - [ ] Utilize Apple's newer ML frameworks? Research this! Can we utilize on device neural engines?
- [x] Game CPU will not see knight's moves upon promotion, only queen
- [ ] Do CPU calculations in the background with increasing depths while it is the users turn
  - [ ] Prioritizing looking at branches that involve the currently tapped piece if the user taps on a piece (they are likely to be moving that piece).

### CPU Performance Notes 7/21/26
| Depth | Time (seconds)| How much more time is required from previous|
| --- | --- | --- |
| 1 | 0.0003 | Base|
| 2 | 0.0092 | 30x|
| 3 | 0.0207 | 2.25x|
| 4 | 0.3831| 18.5x|
| 5 |  2.8505| 7.5x|

### Possible Future Optimizations
| Optimization | Expected Speedup | Status |
| --- | --- | --- |
| Alpha-Beta Pruning | Up to 10x reduction in search space | Done? Make sure it works optimally |
| Multi-Threading (Parallel Search) | Up to 2–8x, depending on hardware | ? Make sure it doesn't load the GS every thread — might be why it's so slow right now|
| Hashing (Zobrist Hashing) | 10–50% | ?|
| Transposition Tables (TT) | 20–100%, depending on position complexity | ?|
| Parallelized Evaluation Functions | 2–4x, depending on how parallelizable | ?|
| SIMD & GPU Offloading | 2–10x, depending on hardware and implementation | ?|
| Move Ordering & Iterative Deepening | 10–30% | ? |
| Late Move Reductions | 10–30% |? |
| Null Move Pruning | 10–20% | ?|

--

## Update 1.7 — More Achievements 🏅
- [ ] Automate all Game Center translation updates for all languages in metadata.json, similar to how DeckedOut does it,  or would it be easier with a GameCenterResources file we can pull/push to ASC from within Xcode proper?
- [ ] Update all achievement icons
- [ ] Game Center achievements for Dutch
- [ ] App Store pictures for Dutch
- [ ] New achievement icons

### Achievements
| Achievement | Description | Status | Icon graphic |
| --- | --- | --- | --- |
| Hexceptional Win! | Win your first game | Implemented |1 - Gold|
| Hex Machina | Checkmate the CPU | Implemented | Robot emoji - Blue|
| Hexceeded Hexpectations | Win a joined game | Implemented | Hands shaking emoji - Blue|
| Friendly Hexchange | Have a player join a game you created | Implemented | Mail emoji - Blue|
| Hexcalibur | Underpromote a pawn to a knight| Implemented | Knight icon - Green|
| Hexecutioner | Checkmate after capturing all enemy pieces| Implemented | Swords emoji - Red|
| Hexperimenter | Win with 10 different openings| | |
| Hexathon | Win 26 games| | |
| Hexpedition | Move your king to the opposing king's starting position | Implemented | Map emoji - Blue|
| Hexplorer | Visit every tile in a single game| | |
| Hextra Power | Promote a pawn for the first time| Implemented | Pawn icon - Green|
| Hexceptional Morale | Promote 3 pawns in a single game| | |
| The Great Hexcape | Checkmate after being put in check 3 times| | |
| Hexclusion Zone | Deliver a smothered mate| | |
| Hextreme Measures | Checkmate using your own king| Implemented | King icons - Red|
| Tactical Hexcellence | Checkmate without losing any pieces| | |

### Secret Achievements
| Achievement | Description | Status | Icon graphic |
| --- | --- | --- | --- |
| Hexpect the Unexpected | Open by moving your king| | |
| Hexhausted | Have a game last over 100 turns| | |
| Seasoned Hexpert | Complete all other achievements| | |
| Un-Hexciting Finish | Deliver a stalemate| | |

---

## Update 1.8 — Multiplayer v2  􀉬
- [x] "Waiting for opponent..." should be animated like in iMessage
- [x] See if how we determine winner color is redundant
- [x] Changing Google icon breaks Google icon retrieval in app
- [x] Stalemate is not a draw. Instead the player delivering stalemate receives 0.75 points and the stalemated player receives 0.25 (implement for multiplayer ruling)
- [x] In multiplayer, add the player's flag next to their username if they have a country selected in profile view
- [x] Home Screen quick actions?
- [ ] Leaderboard button underneath profile view — simply rank all users by Elo (icon represented by trophy)
  - [ ] Display first name, country emoji, Elo?
- [ ] Login does not check if your email is actually real
- [ ] In multiplayer, show opponent's Game Center icon if they don't have a Google icon
- [ ] Add random matchmaking if you're signed in? (via GameCenter, or Firebase?
  - [ ] If added, need name checking for online play (just hide the icons, unless joining a friend's game)
- [ ] Make games more secure? (they work fine for now)
- [ ] If user is anonymous, do not update Elo. Is this still needed?
- [ ] User country loads from Firestore every time profile is opened; local storage should update from Firestore once the app is opened, then pull from local every profile view
- [ ] Elo is checked every profile view — can maybe use a local toggle to see if it's been changed in a recent game before asking the server, eliminating redundant server calls (not necessary for now)
- [ ] Store user picture on device and only load when it changes? Having it load is a little jarring (low priority)

---

## ⚙️ Other Changes

### Bugs
- [ ] Game Center icon only loads the second time looking at the profile? (check if still true)
- [ ] If you create an online game, enter, do nothing, and leave, the game does not automatically get deleted. Currently not an issue since each account is "allowed" one empty created game — any previously created game is removed from the server on every new create-game call. Better to delete the game when the game view is dismissed and it is empty after. is this change still needed? What if we allow one empty game per user? verify that other games are deleted if a user creates a new game key

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
- [ ] Enable an option to play as black against the CPU (would need to change promotion logic)
- [ ] Threefold repetition rule for draw
  - [ ] Zobrist hashing for more efficient computation of threefold-rule detection — not needed at launch, could be an important update
- [ ] Get rid of "not verified for macOS" badge in macOS App Store (it's still available as is)
- [ ] Game history button in profile view? (store past user games — who vs who — and then display hex FEN format)
  - [ ] Single player stored on device, multiplayer stored in cloud
- [ ] End game screen displaying username instead of color?
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



