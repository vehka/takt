# PR 1: Remove dead clock code, group Timber voice params

**Branch:** `vehka:upstream/01-cleanup` → `chailight:master`

---

## Title

Remove dead metro/beatclock code and group Timber voice params

## Description

Hi! This is the first of a few small PRs from my fork. It's a cleanup that
doesn't change how takt plays. It makes the later performance work easier to
review.

### Dead clock code

The old metro/beatclock sequencer only ran when `original_clock` was set, and
nothing ever sets it. So every `if original_clock then ... else ... end` branch
always took the global-clock path. This PR removes those branches,
`sequencer_metro`, `midi_clock` and the `beatclock` require, and keeps only the
global-clock code. Net result: about 60 fewer lines in `takt.lua`.

It also fixes five small bugs:

- `is_running = flase` → `false` (it only worked because `flase` is nil)
- Changing **midi out bpm scale** (`sync_div`) crashed: its handler set
  `midi_clock.send`, but `midi_clock` is only created in the dead metro path,
  so it was nil. The setting is still stored, with a TODO. MIDI clock out for
  the global clock system would be a separate change.
- In notes input mode, a grid key on a MIDI track raised an error
  (`step_parame`, an undefined variable) after the note had been sent, so
  notes played on the grid were never recorded on MIDI tracks. The broken
  duplicate `note_on` is removed; `linn.grid_key()` already sends the note.
- Changing or reloading the script could print a traceback from
  `lib/hnds.lua`: the LFO metro kept running after the script's params were
  cleared and read them once more. The script now has a `cleanup()` that
  stops it.
- On the MIDI screen, the tiles of CC 4, 5 and 6 were shown as locked by
  comparing them with the track's CC 3, 4 and 4 values. With the sequencer
  running, a track-level value on one of those slots made its tile flash in
  time with any locked steps. They are now compared with their own slots.

### Timber voice params in groups

Timber adds 50 params for each of its 100 sample slots, so the PARAMS menu was
a flat list of about 5000 entries. Each slot is now a `Voice N` group, which
makes the menu usable. Param ids don't change, so existing psets are not affected.

### Testing

- Loads without errors on desktop norns (norns 260616) and runs the sequencer.
- Chord output on a MIDI track checked with a test script: same as before.
- Checked that each `Voice N` group has exactly 50 params, the same number
  `add_sample_params` adds.

---

<!-- Notes for us (not part of the PR text)
- BEFORE OPENING, test by hand on a real norns and add to Testing:
  start/stop from K2 and the grid; tempo change from the UI; change
  "midi out bpm scale" (crashes upstream, should not crash here); load an
  existing project/pset; open a Voice group in PARAMS; record notes from the
  grid keyboard on a MIDI track (checked on desktop norns with a test script only).
- Commits: b08a156 (param groups), 080826f (dead code), 8a3f7e5 (grid keyboard fix),
  3c37b01 (LFO metro cleanup), 7e6399b (CC tile lock highlight)
- Group ids are "Voice N", with spaces. Norns accepts this (the name is optional
  and defaults to the id). If the maintainer prefers ids without spaces, use
  add_group("timber_voice_"..i, "Voice "..i, 50); that needs norns 2.7+.
-->
