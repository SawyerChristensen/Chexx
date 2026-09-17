#!/usr/bin/env python3
"""
Cross-checks achievement identifiers across the three places they have to agree.

Every achievement is declared in three independent spots, and a mismatch between any two of
them fails *silently* rather than loudly:

  - AchievementManager.achievements  — unlockAchievement() does `guard let index = ... else
    { return }`, so an unregistered id is a no-op and the achievement simply never unlocks.
  - GameCenterManager.reportAchievement(identifier:) — GameKit ignores an identifier with no
    App Store Connect entry, and reportAchievement swallows the error.
  - scripts/metadata.json — the source of truth for what gets uploaded to App Store Connect.

Note the two id conventions are different (snake_case locally, CamelCase for Game Center),
which is exactly the sort of thing that drifts.

Run from the repo root. Exits non-zero if anything is out of sync.
"""

import glob
import io
import json
import re
import sys


def swift_sources():
    src = ""
    for pattern in ("Chexx/**/*.swift", "HexChessLite/**/*.swift", "ChexxWidgets/**/*.swift"):
        for path in glob.glob(pattern, recursive=True):
            src += io.open(path, encoding="utf-8").read()
    return src


def main():
    metadata = set(json.load(io.open("scripts/metadata.json", encoding="utf-8"))["achievements"])
    src = swift_sources()
    reported = set(re.findall(r'reportAchievement\(identifier:\s*"([^"]+)"', src))
    registered = set(re.findall(r'Achievement\(id:\s*"([^"]+)"', src))

    problems = []

    missing_in_metadata = sorted(reported - metadata)
    if missing_in_metadata:
        problems.append(
            "Reported to Game Center but absent from metadata.json (these will never appear in "
            "App Store Connect, and the report is silently dropped):\n  " +
            "\n  ".join(missing_in_metadata)
        )

    never_reported = sorted(metadata - reported)
    if never_reported:
        problems.append(
            "Present in metadata.json but never reported from code (uploaded, but unreachable):\n  " +
            "\n  ".join(never_reported)
        )

    if len(registered) != len(metadata):
        problems.append(
            "Count mismatch: %d registered in AchievementManager, %d in metadata.json. Every "
            "achievement needs an entry in both." % (len(registered), len(metadata))
        )

    if problems:
        print("Achievement ids are out of sync:\n")
        print("\n\n".join(problems))
        return 1

    print("Achievement ids are in sync: %d registered, %d reported, %d in metadata.json."
          % (len(registered), len(reported), len(metadata)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
