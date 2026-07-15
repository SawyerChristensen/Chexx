# Hex Chess — To Do
---

## Update 1.4 — More Localizations  🌐
- [x] Transition TO DO to a markdown file
- [x] Prompt user to review Hex Chess after a multiplayer win (and after a CPU win when it is sufficiently advanced)
- [ ] Add Armenian, Chinese Traditional, Danish, Finnish, Hebrew, Icelandic, Indonesian, Norwegian, Swedish & Turkish to project & ASC
  - [x] In project settings
  - [x] Reorder the info plist files to be alphabetical
  - [x] Translate the bundle display names
  - [x] Make all info plist bundle display name files have the same header "// Bundle display name"
  - [x] Copy upload metadata.json file from DeckedOut project as well as the upload metadata python script
  - [x] Modify the script to work with Chexx (Hex Chess), not DeckedOut
  - [ ] Review if we have the most update to date framework for cf bundle display names. do we need all the different infoplist files or is a string catalog more modern? is what we have outdated? only transition if there is a more modern approach
  - [ ] Pull the other App Store listing titles we have for other languages in ASC through the App Store API. Put them in the Metadata json file. Create new titles and subtitles in the metadata json file for each new language we've added and push them to ASC.
  - [ ] Create a new update notice "New localizations! [The local app name] now supports Armenian, Chinese Traditional, Danish, Finnish, Hebrew, Icelandic, Indonesian, Norwegian, Swedish & Turkish" and push it to ASC as well using the new upload metadata python script
  - [ ] Archive, upload the build, & add app for review in ASC
- [x] Have Claude review the entire project and identify areas for efficiency improvements
  - [x] CPU: `filterMovesThatExposeKing`/`isKingInCheckUsingKingSight` (PieceRules.swift) re-simulate the whole board for every candidate move at every minimax node — likely the single biggest cost driver of CPU move time
  - [x] CPU: move representation is string-based (`parseMove`/`boardToHex`) and gets parsed/formatted constantly in the search hot path — switch to lightweight index structs
  - [x] CPU: `evaluateGameState` (GameCPU.swift) rescans the whole board at every leaf node instead of tracking material incrementally
  - [x] CPU: `orderMoves` re-derives its sort key via string parsing at every node — compute the ordering score once at move-generation time
  - [x] CPU: no transposition table or iterative deepening in `minimaxMove` — deadline cutoffs can return a weaker move than already found; add Zobrist hashing + a TT
  - [x] CPU: flatten `board` from `[[Piece?]]` to a single `[Piece?]` (91 tiles) for cheaper copies/hashing
  - [x] UI: `ProfileView` re-sorts the ~200-element `countries` array on every body re-render instead of once
  - [x] UI: `GameScene.findNearestHexagon` and other `childNode(withName:)` lookups linearly scan the node graph — build a `[String: HexagonNode]` dictionary once
  - [x] The `columns` array literal is redefined in ~23 functions across GameState/PieceRules/GameCPU/GameScene — hoist to one shared constant
  - [x] `MultiplayerManager.listenForOpponentJoined` re-fetches opponent profile info on every snapshot update, not just when the opponent first joins
  - [x] `hasLegalMovesForCurrentPlayer` builds full move lists per piece instead of short-circuiting on the first legal move found
  - [x] En-passant target is found by scanning the whole board (`resetEnPassant`) instead of tracking a single field on GameState
  - [x] Force-unwraps in board/move hot paths (PieceRules.swift, GameScene.swift, GameState.swift) risk crashing mid-search instead of failing gracefully
  - [x] Game state is saved to disk synchronously on the main thread after every single move — move off-thread or debounce
  - [ ] `AsyncImage` for profile/opponent pictures has no caching, so images re-download on every view appearance
- [ ] Review if transitioning our grey xcode folder project structure to blue folders is a good idea. This is a high risk transition since we are modifying project wide data. Make sure there is a git push before this so that if something goes wrong we can roll back onto it.
- [ ] Do we really need the storyboard files? I only use the launch screen one. How do we modify the project settings to remove the storyboard files but still have the launch image that we have set? Thats the only thing we use with the storyboarsd. if I could have my launch image in assets or some other place and then just call that as the launch image the same way the storyboard does, that would be great

---

## Update 1.5 — iPad UI & Mac Port  💻
NOTE: DO NOT START ON THIS UNTIL ALL OF 1.4 IS DONE
- [ ] Refine UI for iPad (country picker, font, achievement stars)
- [ ] Add an official Mac Port of Hex Chess that has a square window. Modify our scroll views or whatever to use what is reccomended UI for Mac
- [ ] App Store Connect/photoshop work:
  - [ ] Better App Store pictures for iPad (1/3 of all users!!)
  - [ ] Listing canvas gaps should be shorter?
  - [ ] Modify Russian listing photo text?
  - [ ] Modify the Chinese listing photo text?

---

## Update 1.6 — Multiplayer v2  􀉬
- [ ] Change profile icon to Game Center access point? (Apple only!!)
- [ ] Add Notifications! (for main app obviously)
  - [ ] Add live activities for games?
- [ ] "Waiting for opponent..." should be animated like in iMessage
- [ ] See if how we determine winner color is redundant
- [ ] Pulsating element on main menu?
- [ ] Changing Google icon breaks Google icon retrieval in app
- [ ] Stalemate is not a draw. Instead the player delivering stalemate receives 0.75 points and the stalemated player receives 0.25 (implement for multiplayer ruling)
- [ ] In multiplayer, add the player's flag next to their username if they have a country selected in profile view
- [ ] Game Center icon only loads the second time looking at the profile
- [ ] If you create an online game, enter, do nothing, and leave, the game does not automatically get deleted. Currently not an issue since each account is "allowed" one empty created game — any previously created game is removed from the server on every new create-game call. Better to delete the game when the game view is dismissed and it is empty
- [ ] Login does not check if your email is actually real
- [ ] Look into Apple Games app multiplayer invites?
- [ ] Home Screen quick actions?
- [ ] Facebook sign in? (nah)
- [ ] In multiplayer, show opponent's Game Center icon if they don't have a Google icon
- [ ] If user is anonymous, do not update Elo
  - [ ] Is this still needed?
- [ ] User country loads from Firestore every time profile is opened; local storage should update from Firestore once the app is opened, then pull from local every profile view
- [ ] Elo is checked every profile view — can maybe use a local toggle to see if it's been changed in a recent game before asking the server, eliminating redundant server calls (not necessary for now)
- [ ] Store user picture on device and only load when it changes? Having it load is a little jarring (low priority)

---

## Update 1.7 — CPU  🤖
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

### iMessage
- [ ] Figure out memory problem with resizing the window??
- [ ] Make `applyUpdate` more elegant — wait until the view is completely on screen before showing what the last user did. Right now it applies the move AS the view is scrolling up and being presented, jumping the gun a little. Currently we call `applyUpdate` by setting `latestHexPGN` whenever the view is activated or selected
- [ ] Make the message captions different based on user and also animated (like GamePigeon)
- [ ] Standardize the start game button across languages (we currently have a bandaid fix). Make the text adjustable for accessibility/device — right now it's hardcoded by screen size
- [ ] "Waiting for opponent" in Spanish is really weird and breaks to multiple lines

### General
- [ ] Android version?
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
