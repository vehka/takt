# PR 3: 4-step grids, param menu sections, BPM limit, transport start

**Branch:** `vehka:upstream/03-hardware-ux` → `chailight:master`
(builds on PR 2; new commits: 73764df, 08c4c8f, 0f3a900, 9abadd4)

---

## Title

Optional 4-step grid support, param menu sections, transport start fixes

## Description

A few small usability changes, one per commit, so any of them can be dropped
if you'd rather not have it.

### Optional support for 4-step brightness grids (2011 models)

Older monome grids only show 4 brightness levels, so takt's dim levels
disappear on them. A new **grid brightness** param (varibright / 4-step)
remaps the levels with the [ledmap](https://github.com/andr-ew/ledmap) library
by @andr-ew.

ledmap is **optional**. takt only loads it if `dust/code/ledmap` is installed,
and only then shows the param (in a HARDWARE section), so takt without ledmap
behaves exactly as before. `cleanup()` removes the mapping on exit.

### Param menu sections

The PARAMS menu now has named sections: SCALE, HARDWARE (only with ledmap),
OUTPUTS, MODULATION, MIXER, SAMPLES, and inside the Timber params SAMPLE LFOs,
DELAY, REVERB and COMPRESSOR. Separators get explicit `takt_*` ids, because a
separator named "REVERB" or "COMPRESSOR" would collide with the norns system
params `reverb` and `compressor`, and norns then drops the separator. Param ids
are unchanged, so psets are not affected.

### BPM limit 300

The pattern BPM went up to 999, but the norns clock tempo param stops at 300.
The limit now matches.

### Transport start

- **Internal clock:** play starts at once instead of waiting for the next
  bar, and always starts from step 1. Before, plain play continued from where
  it stopped, and MOD + play restarted from the beginning. That pause/continue
  behaviour is gone. If you'd like to keep it, I can make "always restart"
  optional or drop that part.
- **Link and crow clock:** still wait for the next bar, so takt stays in phase
  with the external source.
- **MIDI clock:** unchanged; there's no wait, because the MIDI start message
  marks the downbeat.

### Testing

- Desktop norns: loads without errors both with and without ledmap installed.
  With ledmap, the grid brightness param appears and switches modes.
  Without it, there is no HARDWARE section.
- No separator-collision warnings at startup.

---

<!-- Notes for us (not part of the PR text)
- BEFORE OPENING, test by hand and add to Testing:
  - with a real 2011 / 4-step grid (the mapping was only checked in code, not on hardware)
  - internal clock: press play, it starts at once from step 1; stop/play again restarts from step 1
  - Link (e.g. Ableton) and crow clock: play waits for the bar and stays in phase
  - MIDI clock from external gear: starts on MIDI start
  - the PARAMS menu sections look right on the device
- Ask the maintainer: optional ledmap dependency OK, or built-in mapping?
  (ledmap has no license file, so it can't be vendored as is.)
- Behaviour change to point out: internal clock no longer waits for the bar,
  and it no longer continues from the stop position (upstream: plain play
  continued, MOD + play restarted, see the key handler around takt.lua:1100 in f5d0cc1).
-->
