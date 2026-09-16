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

## New achievement icons
- [ ] Design new icons for every achievement, including the unimplemented ones in the reference table.

## Secure online games
- [ ] Deploy `firestore.rules` (`firebase deploy --only firestore:rules`) and smoke-test create/join/move, leaderboard, matchmaking, and profile edits.

## iMessage: memory while resizing the window
- [ ] Profile memory in Instruments while repeatedly resizing the iMessage window in Messages.app. Note whether it really grows, and add what you saw here so the agent can fix it.
