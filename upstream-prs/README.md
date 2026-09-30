# Upstream PRs to chailight/takt

Drafts of the pull request descriptions for sending the fork's work upstream
in small steps. Upstream base: chailight/takt `master` at `f5d0cc1`.

| # | Branch (vehka/takt) | Draft | Summary |
|---|---|---|---|
| 1 | `upstream/01-cleanup` | [01-cleanup.md](01-cleanup.md) | Remove dead metro/beatclock code, group Timber voice params |
| 2 | `upstream/02-performance` | [02-performance.md](02-performance.md) | seqrun() speedups, chord lookup, MIDI note-off flood fix |
| 3 | `upstream/03-hardware-ux` | [03-hardware-ux.md](03-hardware-ux.md) | Optional 4-step grid support, param menu sections, BPM limit, transport start |
| 4 | `upstream/04-docs` | [04-docs.md](04-docs.md) | User manual |

## How the branches stack

Each branch builds on the previous one: `02` contains `01`, and so on. A PR
from `upstream/02-performance` opened before #1 is merged will show #1's
commits too. Options:

- **One at a time (simplest to review):** open #1, wait for the merge, then open #2.
- **All at once:** open them all, and say in #2–#4 "builds on #N, only the last
  commits are new" and list which commits are new.

If the maintainer changes something in #1 before merging, or merges with
squash or rebase, rebase the rest onto the new upstream master before opening
the next PR:

```
git fetch upstream   # remote for chailight/takt
git rebase --update-refs --onto upstream/master upstream/01-cleanup upstream/04-docs
```

## Things to raise with the maintainer first

- **Behaviour changes** to agree on:
  - Chord value 0 now plays no chord, matching the display (it used to play a
    major triad) — #2
  - The internal clock starts at once instead of at the next bar (play still
    continues after stop; MOD + play restarts, as before) — #3
  - BPM is capped at 300 — #3
- **The 4-step grid support** depends on the optional
  [ledmap](https://github.com/andr-ew/ledmap) library. Is an optional
  dependency OK, or would they rather have the mapping built into takt? — #3
- **The user manual** is about 900 lines: does it belong in the repo, or the
  wiki / norns community page? — #4
- **Known upstream bugs not fixed yet**, useful to mention as future PRs:
  - Clock drift: one tick lost every 256, so takt falls a beat behind every 64 bars
  - The "midi out bpm scale" setting has no effect with the norns global clock
  - The Timber engine uses about 46% DSP on a Pi 3 with nothing playing, so it
    xruns easily when playing

## Evidence

The test protocol, tools and measurements are in [`../perf/`](../perf/)
(online: https://github.com/vehka/takt/tree/perf/perf). Link to them from the
PRs where the numbers matter (#2).
