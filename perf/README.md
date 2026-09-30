# takt performance lab

Test tools, protocol and results for takt performance work. This lives on the
orphan `perf` branch so it never mixes with code headed upstream. Check it out
next to the code:

```
git worktree add ../takt-perf perf
```

Results are in [`results/`](results/): one dated write-up per session, raw
output under `results/raw/<date>-<machine>/` with a `revisions.txt` naming the
commits that were measured.

## Tools (`tools/`)

All Lua tools run inside matron while takt is loaded, via `nrepl.py`
(`dofile('<path>')`). They reach takt internals through upvalues of the global
`clocked_seq` (`data`, `seqrun`, `choke`), so they work on any takt revision
without changes to takt itself. If a takt refactor renames those locals, the
tools need updating.

| Tool | What it does |
|---|---|
| `nrepl.py` | Send Lua to a matron REPL over websocket (`--host`, `--wait`) |
| `stress.lua` | Synthetic stress pattern + measurement (below) |
| `chordtest.lua` | Chord correctness on a MIDI track: all 26 chords, chord -1/0, RND NOTE, inherited default |
| `noteoff.lua` | MIDI note-on/off balance: every note must end exactly once |
| `drift.lua` | seqrun ticks per clock beat (should be 128) |
| `probe_params.lua` | Share of seqrun time spent in `params:set` |
| `probe_tracks.lua` | seqrun time with only sample tracks, only MIDI tracks, or none unmuted |
| `run_desktop.sh` | Stress runs on desktop norns, norns restarted before each run |
| `run_shield.sh` | Stress runs on the norns shield, base vs new, resumable over flaky wifi |
| `gen_samples.py` | Synthetic drum samples for desktop runs |

Setup on the desktop:

```
cd tools
python3 -m venv venv && venv/bin/pip install -r requirements.txt
python3 gen_samples.py
```

## Stress test protocol

### Pattern (`stress.lua`)

All 14 tracks on, default divider (16 steps per bar), 120 bpm:

- **normal**: a trigger on every 16th note
- **heavy**: a trigger on every 64th note, and MIDI chords are all 13ths (7 notes)
- Sample tracks 1–7: seven 808 hits, every trigger locks note, filter cutoff and
  resonance, pan, amp, delay and reverb send (so `set_locks` → `params:set` runs)
- MIDI tracks 8–14: device 1, random chord (1–26), length 3, every other step
  with the `+- NOTE` rule
- All 4 LFOs on, target 2, 5 Hz
- `math.randomseed(42)`, so the pattern is the same every run

### Measurements

- **seqrun**: wall time of each call (avg, p99, p99.9, max, calls over the
  1/128 beat budget, 3.906 ms at 120 bpm). p99 values are from 0.1 ms buckets
  capped at 100 ms, so "100.0" means ≥100 ms.
- **ticks run**: seqrun calls in the run. Expected is `SECS × bpm / 60 × 128`
  (15 360 for 60 s at 120 bpm). **This is the key sequencer metric**: when
  seqrun is too slow, the norns clock skips ticks rather than running them
  late, so *tick lateness* stays near zero even when the sequencer is drowning.
- **audio**: `_norns.audio_get_xrun_count()` polled every 0.25 s, and
  `_norns.audio_get_cpu_load()` (JACK DSP load). `run_shield.sh` also saves the
  jackd journal lines, which name the client that missed its deadline.
- **lua memory**: max `collectgarbage("count")`.

### Procedure

1. Same machine, same tempo (120), same duration (desktop 30 s, shield 60 s).
2. Restart norns before each revision (shield) or each run (desktop). A backed-up
   MIDI output or engine state carries over otherwise and slows every later run.
3. Reload the script before each run (the runners do this).
4. Don't have the norns home menu open: it reads (and resets) the xrun counter.
5. Also record idle: takt loaded, transport stopped, 30 s of xruns and DSP load.
   It separates the engine's own cost from what playing adds.
6. Write the raw output to `results/raw/<date>-<machine>/` with `revisions.txt`,
   and a summary in `results/<date>.md`.

### Pitfalls met so far

- **Stale wrappers**: a global holding the "original" seqrun survives script
  reloads, so later runs measured an old script instance. `stress.lua` now only
  unwraps its own wrapper.
- **MIDI device 1 on the desktop is fluidsynth** (nb_fluid mod). Upstream's
  note-off flood fills its virtual port until writes block, giving 100–500 ms
  stalls that grow run after run. The shield has no MIDI devices.
- **"Fewer xruns" can mean "fewer notes"**: a starved sequencer plays less, so
  the engine does less. Compare xruns only together with ticks run.
- A `clock.resume ... thread expected` error after transport stop is a race in
  the norns clock scheduler, not takt.

## Machines

| Name | Hardware | norns | Audio |
|---|---|---|---|
| desktop | x86-64 Manjaro, norns-desktop port | converged fork | PipeWire JACK |
| shield | Raspberry Pi 3, norns shield (10.0.0.138) | 260616 converged | jackd 48 kHz, 128 × 3 frames |
