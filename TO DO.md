# Hex Chess — To Do

`[ ]` not started · `[~]` in progress · `[x]` done (open for deletion)
🤖 agent = open tasks in `TO DO_agent.md` · 👤 human = open tasks for humans in `TO DO_human.md`
Auto-dev works top to bottom. It never starts anything in 💡 Ideas; move an item into a section above to queue it.

---

## Update 1.5 — Mac Port 💻
- [~] Native Mac port — 👤 human
- [~] "Now supports macOS" App Store update notice — 👤 human
- [~] Remove "Designed for iPad" badge on Mac App Store — 👤 human
- [~] App Store screenshots (iPad, Mac, localized) — 👤 human
- [x] 120Hz in the iMessage extension
- [x] Larger button text
- [~] Book icon aspect ratio fix — 👤 human
- [~] Push notifications & Live Activities for online moves — 👤 human
- [x] Smaller CPU "Thinking" indicator
- [x] iMessage "Waiting for opponent" reserved-space animation
- [~] Haptics on check and game win — 👤 human
- [x] Review prompt after 2nd CPU win
- [x] Replace DispatchQueue with Swift concurrency (Tasks)
- [~] Switch sound effects to PocketPoker's audio format — 👤 human
- [ ] Review StockFish and techniques it uses to run a normal chess engine. See if we can use them or if it makes sense to use them in Hexagonal Chess.

## Update 1.6 — CPU 🤖
- [x] Default search depth 5
- [x] Opening book for Black's first move
- [x] Only show "Thinking" for long searches
- [x] Deeper endgame search
- [x] Engine optimizations (iterative deepening, null-move pruning, LMR)
- [~] CPU learned evaluation — 👤 human
- [x] Move CPU training & eval files to HexChessCollection
- [x] CPU considers knight underpromotion
- [x] Background pondering on the player's turn
- [~] Review Stockfish & other engine techniques against our CPU — 👤 human

## Update 1.7 — More Achievements 🏅
- [x] Game Center achievement translations (all locales)
- [x] Dutch Game Center achievements
- [~] Implement remaining achievements — 👤 human
- [~] New achievement icons — 👤 human

## Update 1.8 — Multiplayer v2 􀉬
- [x] Animated "Waiting for opponent"
- [x] Winner color logic cleanup
- [x] Google icon retrieval fix
- [x] Stalemate scoring (0.75 / 0.25)
- [x] Country flags next to usernames
- [x] Home Screen quick actions
- [x] Elo leaderboard
- [x] Email verification
- [x] Opponent Game Center avatar fallback
- [x] Random matchmaking
- [~] Secure online games — 👤 human
- [x] Skip Elo updates for guests
- [x] Cache country & Elo locally
- [x] Cache profile pictures on disk

## 🛑 Known Issues
- [x] CPU wrongly finding no legal moves
- [x] Game Center icon only loading on second visit
- [x] Abandoned empty online games not deleted
- [x] Mac Catalyst build break (ActivityKit)
- [x] iMessage: opponent's move animating before the view settles
- [~] iMessage: memory while resizing the window — 👤 human
- [~] iMessage: "Waiting for opponent" wraps badly in Spanish — 👤 human
- [~] iMessage: start game button sizing hardcoded per screen and language — 👤 human
- [ ] Main app target folder is grey in Xcode while the iMessage extension is blue
- [ ] GameSceneInteractionTests.testTappingFarOutsideTheBoardDeselectsWithoutMoving fails

## 🗺️ Planned
- [ ] iMessage: per-player animated captions live transcript layouts like in deckedout/pocketpoker
- [ ] 50-move no-capture draw rule
- [ ] Threefold repetition draw rule
- [ ] Option to play as Black against the CPU
- [ ] iPad/macOS/iPhone Duo UI refinement (country picker, fonts, achievement stars)
- [ ] Replace remaining width/height-scaled font sizes with standard text styles
- [ ] Check for newly added Unicode flags
- [ ] Update the project to the most recent frameworks
- [ ] Move history above the board in chess.com-style notation — 👤 human
- [ ] Whole-project folder reorganization (after both folders are blue) — 👤 human

## 💡 Ideas
- [ ] Android version
- [ ] Apple Games app multiplayer invites
- [ ] Game Center access point as the profile icon
- [ ] Game history in profile
- [ ] Optional row/column labels (A–L, 1–11)
- [ ] Usernames instead of colors on the end-game screen
- [ ] Alternate board color schemes
- [ ] Mirror-match option for local play (iPad)
- [ ] Favorite opening in profile
- [ ] Variants: Mathewson's, McCooey's, McQuay's
- [ ] Delete storyboards

---

## 📎 Reference

### Achievements
| Achievement | Description | Status | Icon graphic |
| --- | --- | --- | --- |
| Hexceptional Win! | Win your first game | Implemented | 1 - Gold |
| Hex Machina | Checkmate the CPU | Implemented | Robot emoji - Blue |
| Hexceeded Hexpectations | Win a joined game | Implemented | Hands shaking emoji - Blue |
| Friendly Hexchange | Have a player join a game you created | Implemented | Mail emoji - Blue |
| Hexcalibur | Underpromote a pawn to a knight | Implemented | Knight icon - Green |
| Hexecutioner | Checkmate after capturing all enemy pieces | Implemented | Swords emoji - Red |
| Hexperimenter | Win with 10 different openings | | |
| Hexathon | Win 26 games | | |
| Hexpedition | Move your king to the opposing king's starting position | Implemented | Map emoji - Blue |
| Hexplorer | Visit every tile in a single game | | |
| Hextra Power | Promote a pawn for the first time | Implemented | Pawn icon - Green |
| Hexceptional Morale | Promote 3 pawns in a single game | | |
| The Great Hexcape | Checkmate after being put in check 3 times | | |
| Hexclusion Zone | Deliver a smothered mate | | |
| Hextreme Measures | Checkmate using your own king | Implemented | King icons - Red |
| Tactical Hexcellence | Checkmate without losing any pieces | | |

#### Secret
| Achievement | Description | Status | Icon graphic |
| --- | --- | --- | --- |
| Hexpect the Unexpected | Open by moving your king | | |
| Hexhausted | Have a game last over 100 turns | | |
| Seasoned Hexpert | Complete all other achievements | | |
| Un-Hexciting Finish | Deliver a stalemate | | |

### Resources
- [Ways to update chess AI / increase computational efficiency](https://web.archive.org/web/20071026090003/http://www.brucemo.com/compchess/programming/index.htm)
- [General Chess Programming Info](https://www.chessprogramming.org/Main_Page)
- [Glinski's Hexchess (Hexagonal chess)](https://en.wikipedia.org/wiki/Hexagonal_chess)
