# Chess Engine Techniques vs. Hex Chess

A survey of the techniques Stockfish and other strong engines use, checked against what
`Chexx/Game Logic/GameCPU.swift` already does, and against whether the idea even transfers to an
11-file, 91-tile Glinski's board.

**Nothing here has been implemented from this document.** It exists to be reviewed and prioritised
first — several of these are large, and a few are actively not worth doing for hex.

Status key: **Have it** · **Missing** · **Doesn't transfer**

---

## Summary table

| Technique | Status | Transfers to hex? | Worth doing |
| --- | --- | --- | --- |
| Alpha-beta minimax | Have it | Yes | — |
| Iterative deepening | Have it | Yes | — |
| Transposition table (Zobrist) | Have it | Yes | — |
| Null-move pruning | Have it (R=2, min depth 3) | Yes | — |
| Late move reductions (LMR) | Have it | Yes | — |
| MVV-LVA move ordering | Partial | Yes | Low — refine |
| TT-move-first ordering | Have it | Yes | — |
| Opening book | Partial (Black's 1st move only) | Yes | Low |
| **Quiescence search** | **Missing** | Yes | **Highest** |
| Killer moves | Missing | Yes | High |
| History heuristic | Missing | Yes | High |
| Check extensions | Missing | Yes | Medium–High |
| Principal variation search (PVS) | Missing | Yes | Medium |
| Aspiration windows | Missing | Yes | Medium |
| Positional evaluation terms | Partial (optional learned PST) | Partly | Medium |
| Static exchange evaluation (SEE) | Missing | Yes | Medium |
| Repetition detection in search | Missing | Yes | Medium |
| Futility pruning / razoring | Missing | Yes | Low–Medium |
| Bounded TT / replacement policy | Missing | Yes | Low–Medium |
| Bitboards | Missing | Awkwardly | Low |
| Magic bitboards | Missing | Poorly | Not worth it |
| Endgame tablebases | Missing | No | Not worth it |
| Lazy SMP / multithreading | Missing | Yes | Not yet |

---

## The one that matters most: quiescence search

**This is the single biggest gap, and it interacts badly with the material-only evaluator.**

The search stops at a fixed depth and calls `evaluateGameState`, which (by default) returns nothing
but material difference. So if depth runs out immediately after the CPU captures a defended pawn,
the position is scored as "up a pawn" — the recapture that loses a queen is one ply beyond the
horizon and never seen. This is the classic horizon effect, and a material-only leaf evaluation is
the worst case for it.

Quiescence search fixes it: at depth 0, instead of evaluating immediately, keep searching *only*
captures (and usually checks) until the position is quiet. It is normally one of the cheapest large
strength gains available, and it needs no new board representation — `generateAllFullMoves` already
produces the moves, they just need filtering to captures.

**Recommendation: do this before anything else on the list, including any evaluation work.** Tuning
an evaluator that's being fed mid-capture positions is building on sand. It also partly explains why
the learned PST evaluation benchmarked 6–12× slower per node for a modest win-rate gain — a better
leaf evaluator can't fix a position the search shouldn't have stopped at.

## Cheap wins after that

- **Killer moves** — remember the two quiet moves that caused a beta cutoff at each ply, try them
  first at sibling nodes. A small array and a few lines in the ordering function. Move ordering is
  what alpha-beta's performance lives or dies on, and ordering is currently *only* capture-based
  (`evaluateMove` returns 0 for every quiet move, so quiet moves are in generation order).
- **History heuristic** — a `[from][to]` table scored by cutoffs, used to order quiet moves. Pairs
  naturally with killers and fills the same gap.
- **Check extensions** — search one ply deeper when in check. Forcing lines are exactly where the
  horizon effect bites, and hex chess has more check-giving directions than orthodox chess (the king
  has 12 neighbours, not 8), so this may matter *more* here than on an 8×8 board.
- **Repetition detection in the search** — Zobrist hashing already exists, so detecting a repeated
  position is mostly plumbing. Note this overlaps with the separate "Threefold repetition draw rule"
  to-do item: the rule and the search-side detection want the same position history, so it would be
  sensible to build them together rather than twice.

## Worth doing, more work

- **PVS / NegaScout** — search the first move with a full window and the rest with a null window,
  re-searching on failure. Reliable gain, but needs the move ordering above to be good first, or the
  re-searches cost more than they save.
- **Aspiration windows** — start each iterative-deepening iteration with a narrow window around the
  previous score. Easy to add, but it wants a stable evaluation to narrow around.
- **SEE (static exchange evaluation)** — resolve a capture sequence on one square statically, to
  order captures properly and to prune losing captures inside quiescence. Best added *with*
  quiescence search rather than before it.
- **Positional evaluation** — mobility, king safety, pawn structure. **This is where hex intuition
  from orthodox chess is least reliable.** Hex pawns capture differently, there are three bishops per
  side on three separate colour complexes, and "pawn structure" concepts like doubled/isolated pawns
  don't map cleanly onto a board with variable-height columns. Any term borrowed from an 8×8 engine
  should be measured on this board, not assumed. The existing self-play harness and
  `~/HexChessCollection/ChexxCPUBenchmarkHistory.md` are the right tools for that.

## Where the board shape gets in the way

- **Bitboards** — 91 tiles doesn't fit a machine word. It needs `UInt128` or two `UInt64`s, so every
  set operation becomes two operations, and the ray-shift tricks that make 8×8 bitboards fast rely on
  file/rank arithmetic that hex geometry doesn't share. The payoff is real but much smaller than in
  orthodox chess, and it would mean rewriting `PieceRules` wholesale. Low priority: the same effort
  spent on search improvements will buy more.
- **Magic bitboards** — an optimisation *of* bitboard sliding-piece attacks, built on 8×8 occupancy
  patterns. The magics would all have to be re-derived for hex ray directions on top of an already
  awkward board representation. Not worth it.
- **Endgame tablebases** — Syzygy tables exist because orthodox chess endgames are a solved, shared,
  precomputed corpus. No such corpus exists for Glinski's, and generating one is a research project.
  Not worth it.
- **Lazy SMP / multithreading** — transfers fine in principle, but the search is currently driven
  from a serial actor (`CPUSearchExecutor`) and the app targets phones. Parallelism is the last thing
  to reach for, after the single-threaded search is efficient.

## One thing that isn't a technique, but showed up while reading

`transpositionTable` is a plain `[UInt64: TranspositionEntry]` dictionary, and it is deliberately
*not* cleared between moves (only `timedSearch` clears it). That's good for search efficiency, but it
means the table grows without bound over a long game — there's no size cap and no replacement policy.
Real engines use a fixed-size table with an explicit replacement scheme precisely to bound memory.
Worth measuring what it actually reaches over a 100-turn game on a phone before deciding whether it
needs fixing; noting it here because it's a memory question, and the project already has an
unexplained iMessage memory item open.

---

## Suggested order

1. Quiescence search — biggest single gain, and a prerequisite for trusting any evaluation work
2. Killer moves + history heuristic — cheap, and ordering is the current weak spot
3. Check extensions
4. Repetition detection, built together with the threefold-repetition rule
5. SEE, then PVS, then aspiration windows
6. Positional evaluation terms — measured on this board, never assumed from orthodox chess
7. Bound the transposition table if measurement says it needs it

Everything below that line is probably not worth it for this project.
