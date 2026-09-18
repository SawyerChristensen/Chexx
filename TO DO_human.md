# Hex Chess — Human To Do

Things only a person can do: artwork, App Store Connect, credentials and deploys, real-device checks, product decisions.
Each `##` heading matches a feature in `TO DO.md`. Check a box when it's done and auto-dev takes it from there.

---

## Native Mac port
- [ ] Unlock the Mac and run the native macOS build. Check that the main menu and board render, the 550×550 window looks right, hover feedback feels right, and a local game is playable with the mouse.

## "Now supports macOS" App Store update notice
- [ ] Run `scripts/upload_metadata.py --whats-new-only` to push the translated update notice to App Store Connect.

## Remove "Designed for iPad" badge on Mac App Store
- [ ] After the next Mac submission, confirm the "Designed for iPad. Not verified for macOS" badge is gone from the live listing.

## App Store screenshots (iPad, Mac, localized)
- [ ] Better iPad screenshots (about 1/3 of users)
- [ ] Mac screenshots
- [ ] Decide whether the gaps in the listing canvas should be shorter
- [ ] Revise the Russian screenshot text
- [ ] Revise the Chinese screenshot text and add Traditional Chinese
- [ ] Dutch screenshots

## Book icon aspect ratio fix
- [ ] Decide whether to keep the book icon change or undo it.

## Push notifications & Live Activities for online moves
- [ ] Deploy the Cloud Functions (`firebase deploy --only functions`) and confirm a move notification arrives on a real device.

## Haptics on check and game win
- [ ] Verify on a physical iPhone that check and game-win haptics fire and feel right.

## CPU learned evaluation
- [ ] Decide whether to turn on `GameCPU.useLearnedEvaluation` by default. The benchmark won 24 of 25 decisive games against material-only, but the sample is small and it searches 6–12× slower per node.

## Implement remaining achievements
- [ ] **Deploy `firestore.rules` (`firebase deploy --only firestore:rules`).** The new cross-game progress (Hexathon's win count, Hexperimenter's openings) writes an `achievementProgress` field that the rules must whitelist. **Fails quietly if skipped:** achievements still unlock locally, so testing looks fine — only surviving a reinstall breaks.
- [ ] Create App Store Connect achievement entries for all 11 new IDs: `TacticalHexcellence`, `HexclusionZone`, `UnHexcitingFinish`, `HexceptionalMorale`, `TheGreatHexcape`, `Hexplorer`, `HexpectTheUnexpected`, `Hexhausted`, `Hexathon`, `Hexperimenter`, `SeasonedHexpert`. Mark the last four in that list plus `UnHexcitingFinish` as **secret**. Until these exist, the code reports them and Game Center silently ignores it — nothing breaks, they just don't show up.
- [ ] Run `scripts/upload_metadata.py` once the new achievement strings are in `metadata.json`.
- [ ] **Translate the 22 new achievement strings into the other 24 locales.** They're in `Chexx/Localizable.xcstrings` with English only — the titles are puns on "hex" (Hexclusion Zone, Hexpect the Unexpected, The Great Hexcape), and inventing 24 versions of a pun would have meant shipping guesses into a live listing. Xcode's string catalog lists them as untranslated. Note the existing precedent in that file: pun titles like "Hexcalibur" are kept as-is in the Latin-script locales and only genuinely translated for ar/bn/he/hi/hy/ja/ko/ru/zh — so most of the title work is bulk copy. The descriptions ("Win 26 games") do need real translation everywhere.
- [ ] **Decide: does Hexplorer count a tile as visited when *either* player moves onto it, or only you?** Implemented as either-player, with starting squares not counting until something moves onto them. Say if you want it stricter — it's a one-line change.
- [ ] **Decide: should the older achievements be fixed to match?** Hexecutioner and Hextreme Measures currently unlock when *either* side wins by that method — so the CPU delivering a smothered-king mate can award you the achievement. Every new achievement is gated on you being the winner. Left alone rather than silently changing long-standing behaviour.

## 50-move and threefold repetition draw rules
- [ ] Translate three new strings in `Chexx/Localizable.xcstrings`: `Draw by %@!`, `Fifty-Move Rule`, `Threefold Repetition`. English only for now.
- [ ] Decide whether a draw should have its own sound. It currently plays the loss stinger, because there is no neutral one — which may read as "you lost" for what is actually a draw.

## Review Stockfish & other engine techniques against our CPU
- [ ] **Read `CPU_ENGINE_TECHNIQUES.md`** (repo root) and pick what's worth building. Nothing from it has been implemented — it's a review-first deliverable.
  - Headline finding: **there is no quiescence search**, so the search can stop in the middle of a capture sequence and score the position on material alone. That's the classic horizon effect, and it's the cheapest large strength gain available. It's also a prerequisite for trusting any evaluation work — which may explain why the learned-evaluation experiment cost 6–12× per node for a modest gain.
  - Ordering is currently capture-only (every quiet move scores 0), so killer moves + history heuristic are cheap follow-ups.
  - Things the doc recommends **against** for a hex board: magic bitboards, endgame tablebases, and (for now) bitboards generally.
  - Also decide whether the transposition table needs a size cap — it's never cleared between moves, so it grows unbounded over a long game.

## Update the project to the most recent frameworks
- [ ] Decide whether to raise the iOS/macOS deployment targets. That drops older devices, so it's a product call, not a cleanup.

## Move history above the board in chess.com-style notation
- [ ] **Decide the notation.** chess.com shows SAN (`Nf3`, `Qxd5+`, `O-O`), which assumes an 8×8 board and castling — neither is true here, so it has to be a hex analogue. Pick the coordinate scheme. Note this is the same decision as "Optional row/column labels (A–L, 1–11)" in Ideas; settling it once covers both.
- [ ] Decide whether the move history appears in the iMessage extension too, or main app only (the extension has much less vertical room).

## Whole-project folder reorganization (after both folders are blue)
- [ ] **Decide: shared folder, or a local Swift package?** You picked a folder, which is fine. Worth revisiting only because of the tvOS/visionOS idea: a folder can't stop someone adding `import UIKit` to shared code, and you'd find out when the new target fails to build. A package makes that a compile error. The folder converts to a package later without moving files twice, so there's no cost to starting with it.
- [ ] Confirm the proposed layout (`App/`, `Models/`, `Game/`, `Services/`, `Views/`, `Support/`, `Resources/`, `Shared/`) before any files move.

## Main app target folder is grey in Xcode while the iMessage extension is blue
- [ ] **Check an uncommitted change that was already in your working tree.** `project.pbxproj` had `platformFilters` on the "Embed Foundation Extensions" entries for both `HexChessLite.appex` and `ChexxWidgets.appex` changed from `(ios, ipados)` to `(ipados)`. Read literally that stops embedding the iMessage extension and widgets on iPhone while keeping them on iPad. It rode along in commit `a1b01fb` because it couldn't be separated from an unrelated edit to the same file. Confirm it was deliberate, or say the word and I'll revert just that hunk.

## Switch sound effects to PocketPoker's audio format
- [ ] Listen on a real device. The 2-voice round-robin pool for `piece_move`/`check` is a structural fix that couldn't be confirmed by ear in the run that made it — check that rapid moves and back-to-back checks don't clip each other.

## New achievement icons
- [ ] Design new icons for every achievement, including the unimplemented ones in the reference table.

## Secure online games
- [ ] Deploy `firestore.rules` (`firebase deploy --only firestore:rules`) and smoke-test create/join/move, leaderboard, matchmaking, and profile edits.

## Replace remaining width/height-scaled font sizes with standard text styles
- [ ] Look at the game-over card (main app and iMessage) once you next finish a game. Its `GeometryReader` was removed — it was only deriving font sizes — so the card's layout is worth one confirming glance. The two buttons are now the same width, where before they were 230 and 187 points.
- [ ] Check in-game text on **iPad or Mac**. Fonts no longer scale with screen size, so text is smaller there than before — intentional, but if it looks sparse the fix is a size-class bump, not a return to geometry scaling.

## iMessage: start game button sizing hardcoded per screen and language
- [ ] Check the "Start Game!" button in the iMessage extension, in **both compact and expanded** presentation, in Spanish (the longest translation at 1.64x English) and one of Indonesian/Polish/Italian. The Spanish-only duplicate button has been removed in favour of one that scales, so Spanish is now the real regression test.
- [ ] Also worth a look at a large accessibility text size — the button height is fixed, so growth is capped at `accessibility1`. Confirm the label isn't clipped at that cap.

## iMessage: "Waiting for opponent" wraps badly in Spanish
- [ ] Check the waiting badge on a device or simulator in a long locale — **French, Polish or Bengali**, not Spanish. Spanish turned out to be the mildest of the ten affected locales, so it's the weakest test. Confirm the pill stays inside the view and that the text size doesn't visibly jump as the animated dots cycle.

## iMessage: memory while resizing the window
- [ ] Profile memory in Instruments while repeatedly resizing the iMessage window in Messages.app. Note whether it really grows, and add what you saw here so the agent can fix it.
