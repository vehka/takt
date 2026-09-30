# PR 4: User manual

**Branch:** `vehka:upstream/04-docs` → `chailight:master`
(builds on PR 3; new commits: 3d089d4 … 0eb2b19)

---

## Title

Add a user manual

## Description

takt has a lot of features that are hard to discover from the screen and grid
alone. The README has the original reference image plus notes on your
extensions, but no walkthrough.
This adds `USER_MANUAL.md`, a full manual, with two screenshots in `images/`:

- Overview, norns controls and grid controls
- Views and modes, sequencer features (trig conditions, retrigs, dividers,
  parameter locks)
- Sample playback, MIDI features (chords, CCs, program change, crow / JF / w/syn)
- Modulation and effects, pattern management and metaseq
- Configuration (the PARAMS sections), quick reference, tips and troubleshooting

It documents takt as it is after the previous PRs (param menu sections, grid
brightness, BPM limit, instant start), including play/continue and MOD + play
to restart.

The Patterns view, metaseq and pattern copy sections were corrected against
the code. Corrections are very welcome if anything doesn't match how you meant
things to work.

If you'd rather keep docs somewhere else (lines, the wiki, the README), I'm
happy to move it.

---

<!-- Notes for us (not part of the PR text)
- If parts of PR 3 are dropped (ledmap / HARDWARE section, transport change,
  BPM 300), update the manual's Configuration and Troubleshooting sections
  to match before opening this PR.
- Optionally add a link from README.md to USER_MANUAL.md in this PR.
- The manual says PPQN is "fixed at 128"; that stays true unless the clock
  drift fix changes the loop.
- Before opening, read it through once more against the merged upstream code.
-->
