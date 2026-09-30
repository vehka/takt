# PR 2: seqrun() performance and MIDI note-off fix

**Branch:** `vehka:upstream/02-performance` → `chailight:master`
(builds on PR 1; new commits: ee7080f, 01da331, 3b58b50)

---

## Title

Fix MIDI note-off flood and speed up seqrun()

## Description

`seqrun()` runs 128 times per beat, so anything slow in it adds up fast. On a
Pi 3 under a busy pattern, upstream takt only managed to run about a fifth of
its sequencer ticks (the norns clock skips ticks it can't run in time). This
PR fixes the main cause, a MIDI note-off bug, and a couple of smaller things.

### MIDI note-offs were sent on every tick (bug fix)

After a MIDI note's length ran out, `seqrun()` sent its note-off but never
cleared the pending note. So it sent the note-off again **on every tick** until
the track's next note, and one more for each chord note, rebuilding the chord
with `music.generate_chord()` each time.

A single 16th note with length 3 gave about 250 note-offs per bar. A track
of 16th-note chords sent 2 884 note-offs for 231 note-ons. That is more than a
DIN MIDI port can carry with a few chord tracks, and it can also back up
virtual MIDI ports (I saw 100–500 ms stalls with fluidsynth).

In the same code, a new note overwrote the previous note without ending it,
and a note running past the pattern end never got a note-off, so notes could
hang.

Now a helper, `midi_note_off(tr)`, sends the note-off (and chord note-offs)
once and clears the pending note. It is called when the length runs out, when
the track wraps past the note start, and before a new note on the same track.
Every note now ends exactly once:

| case (1024 ticks, one MIDI track) | before: on / off | after: on / off |
|---|---|---|
| single note, length 3 | 3 / 502 | 3 / 2 |
| 16ths with 13th chords | 231 / 2 884 | 231 / 224 |
| overlapping notes, length 40 | 21 / 1 092 | 21 / 18 |
| note crossing the pattern end | 2 / 0 (hangs) | 2 / 2 |

(the remaining difference after the fix is the last note, still sounding when the test stopped)

### Chord lookup table

`music.generate_chord()` builds a new table on every call, and `seqrun()` called
it for every chord note-on and note-off. Chords now come from a table keyed by
chord type and root note, filled on first use. It gives the same notes as
`generate_chord()` for all 26 chords × 128 notes, is about 50× faster per call,
and makes no garbage while playing. The lookup uses the current note and chord
values, so it follows rules like RND NOTE, MIDI recording and track defaults.

**Behaviour change:** chord value 0 is shown as "no chord" but used to play a
major triad (`chord_names[0]` is nil, and `generate_chord()` then falls back to
major). It now plays no chord, matching the display.

### Smaller seqrun() savings

- Muted tracks with no trigger and no pending MIDI note-off are skipped early.
- The jf / w/syn / crow output settings are cached in locals, updated by their
  param actions, instead of calling `params:get()` for every triggered MIDI step.

### Results

Synthetic stress pattern: all 14 tracks with 16th notes, locks on the sample
tracks, random chords on the MIDI tracks, 4 LFOs, 60 s at 120 bpm. Measured
with this PR and the following ones (they don't change `seqrun()`):

| Pi 3 norns shield | ticks run (of 15 360) | seqrun avg | seqrun max |
|---|---|---|---|
| before | 3 190 | 12.4 ms | 631 ms |
| after | 13 417 | 1.2 ms | 251 ms |

On a desktop the average time per tick drops about 30% (0.147 → 0.105 ms).
The shield has no MIDI device connected, so the gain there is Lua time
(re-sent note-offs and chord rebuilds), not MIDI output.

Test protocol, tools and raw numbers:
https://github.com/vehka/takt/tree/perf/perf

### Testing

- Chord test script: all 26 chord types, chord -1 and 0, RND NOTE changing the
  root, and a chord inherited from the track default, checking MIDI note-on and
  note-off notes. 30/30 pass.
- Note-off balance script: the table above.
- Stress runs on desktop norns and a Pi 3 shield: the tables above.

---

<!-- Notes for us (not part of the PR text)
- The earlier per-step chord cache (commit f0271e1 in the fork) was dropped:
  it went stale with rules, MIDI recording and inherited defaults, and chords
  stopped playing (fork master failed 28/30 of the chord test).
- BEFORE OPENING, try by hand with real MIDI gear: chord tracks, long notes,
  notes crossing the pattern end, stop while notes are sounding (all notes off).
- The shield still xruns under this stress load, but >97% are
  "SuperCollider was not finished" (Timber engine DSP), not related to this PR.
-->
