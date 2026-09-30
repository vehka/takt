# Takt - Codebase Documentation for AI Assistants

## Overview

Takt is a comprehensive sequencer script for the [norns](https://monome.org/docs/norns/) sound computer. It provides 14 sequencer tracks (7 sample-based via Timber engine, 7 MIDI-based) with extensive parameter control, modulation via LFOs, and support for multiple output devices including MIDI, Just Friends (JF), w/syn, and Crow.

**Key Stats:**
- Main script: `takt.lua` (~2100 lines)
- Engine integration: `lib/timber_takt.lua` (~800 lines)
- UI rendering: `lib/ui.lua` (~900 lines)
- Supports 100 sample voices with 50+ params each
- Runs at 128ppqn (128 pulses per quarter note)
- Core sequencer loop: `seqrun()` called 128 times per beat

## Architecture

### Core Components

```
takt.lua                 # Main script - sequencer logic, MIDI, clock management
├── lib/
│   ├── timber_takt.lua  # Timber engine integration (sample playback)
│   ├── ui.lua           # Screen rendering and UI state
│   ├── hnds.lua         # LFO modulation system
│   ├── _utils.lua       # Default pattern/param structures
│   └── browser.lua      # File browser for samples
└── lib/Engine_Timber_Takt.sc  # SuperCollider engine
```

### Data Structure

**Pattern data** (`lib/_utils.lua:40-88`):
```lua
data[pattern_num][track_num] = {
  [0-256] = 0 or 1,  -- trigger on/off for each position
  params = {
    [0-256] = {       -- per-step parameters
      note, velocity, chord, device, channel, length,
      lock, offset, rule, retrig, div,
      chord_notes,    -- cached chord (optimization)
      -- + many engine params for sample tracks
    }
  }
}
```

**Track structure**:
- Tracks 1-7: Sample-based (Timber engine)
- Tracks 8-14: MIDI/modulation output
- Each track has 256 positions (0-255)
- UI shows 16 "steps", each containing 16 substeps
- Position calculation: `get_step(x) = (x * 16) - 15` (takt.lua:371)

### Clock and Sequencer

**Clock resolution**: 128ppqn (takt.lua:1348)
```lua
function clocked_seq()
  while true do
    for i=1,256 do
      clock.sync(1/128)  -- Sync at 128ppqn
      seqrun(math.floor(i))
    end
  end
end
```

**Timing**:
- 256 loop iterations = 2 beats (at 128ppqn)
- 128 seqrun() calls per beat
- At 120 BPM: 256 calls/second
- Budget per seqrun(): ~3.9ms (at 120 BPM)

**Position advancement** (takt.lua:654-659):
- `advance_step(tr, counter)` increments track position
- Each track can have independent length (1-256) and start position
- Track cycling for pattern rules

### Key Functions

**`seqrun(counter)`** (takt.lua:661+) - **PERFORMANCE CRITICAL**
- Called 128 times per beat
- Advances track positions
- Checks triggers and fires notes/samples
- Handles note-off (choke) logic
- Applies rules, retrigs, dividers
- Outputs to MIDI, engine, JF, w/syn, Crow

**`get_params(tr, pos, override_lock)`** (takt.lua:591-611)
- Retrieves parameters for a track at a position
- Handles parameter locking (per-step vs track default)
- Called twice per trigger by design (see takt.lua:711-716 comments)
- Returns step params with metatable fallback to track defaults

**`midi_event(d)`** (takt.lua:843-889)
- Handles incoming MIDI for live play and recording
- Records notes when `PATTERN_REC` is active
- Routes to appropriate output device

**`cache_chord_for_step(tr, s)`** (takt.lua:124-135)
- Pre-computes chord notes when params change
- Stores in `step.chord_notes` to avoid expensive inline generation
- Called by note/chord param change handlers

### Rules System

**Rules** (takt.lua:185-214+) are **trigger conditions**:
- Probabilistic: "10%", "50%", "90%" chance to trigger
- Pattern-based: "/ 2" (every 2nd cycle), "/ 4", etc.
- Generative: "RND NOTE", "RND START", "+- NOTE"

**Offset** (takt.lua:444, 1142): Used for retrigger pattern shifting, not timing.

**No swing or micro-timing offset exists** - timing precision comes from 128ppqn resolution.

### Device Output Types

1. **Timber Engine** (tracks 1-7): Sample playback via SuperCollider
2. **MIDI** (device 1-4, 17+): Standard MIDI output
3. **Just Friends** (device 5): i2c modular synth via Crow
4. **w/syn** (device 6): i2c modular synth via Crow
5. **Crow CV** (device 7): Direct CV/gate output

### Cached Device Checks (Optimization)

**Problem**: Checking device params every seqrun() call was expensive (~3000 calls/pattern).

**Solution** (takt.lua:71-74, 1258-1281): Cache device states in locals:
```lua
local takt_jf_enabled = false
local takt_wsyn_enabled = false
local takt_crow_mode = 1

params:set_action("takt_jf", function(x)
  takt_jf_enabled = (x == 2)  -- Cache on param change
  -- ... setup code
end)
```

### Choke Array (Note-off Management)

**Purpose**: Track active notes for proper note-off handling.

**Structure** (takt.lua:826):
```lua
choke[tr] = {
  [1] = device,      -- MIDI device or engine
  [2] = note,        -- Note number
  [3] = velocity,    -- Velocity
  [4] = channel,     -- MIDI channel
  [5] = pos,         -- Position when triggered
  [6] = length,      -- Note length
  [7] = chord,       -- Chord type index
  [8] = chord_notes  -- Cached chord notes array
}
```

## File Reading Guidelines

### Large Files (Use offset/limit)

**takt.lua** (~30K tokens):
```lua
-- Read specific sections:
Read(file_path, offset=1342, limit=25)  -- Read clocked_seq
Read(file_path, offset=661, limit=200)  -- Read seqrun
```

**ui.lua** and **timber_takt.lua**: Also require offset/limit.

### Search Strategy

**For specific features**:
1. Use `Grep` for initial location finding
2. Use `Read` with offset/limit for context
3. Use LSP tools for definitions/references if available

**For exploratory work**:
- Use Task tool with `subagent_type=Explore`
- Specify thoroughness: "quick", "medium", or "very thorough"

## Common Patterns

### Parameter Access Pattern

**ALWAYS read params before editing** - the Edit tool requires prior Read.

```lua
-- Access pattern with metatable fallback:
local step_param = data[pattern][tr].params[pos]
-- If step_param.note not locked, falls back to track default
```

### UI Redraw Pattern

UI rendering uses double-buffered params:
```lua
redraw_params[1] = current_displayed_params
redraw_params[2] = previous_params_for_change_detection
```

### Profiling Pattern

```lua
if ENABLE_PROFILING then
  -- Track metrics
  profile_stats.some_counter = profile_stats.some_counter + 1
end
```

Enable via params: "Enable Profiling", "Print Stats", "Reset Stats"

## Performance Considerations

### Optimization History

**Completed Optimizations** (optimize/seqrun-performance branch):

1. **Device Type Caching** - Cache params in locals vs 3000+ get() calls/pattern
   - Result: ~5% avg time reduction, ~20% fewer tracks processed

2. **Early Skip for Inactive Tracks** - Skip muted tracks with no triggers
   - Result: ~20% reduction in tracks processed

3. **Chord Pre-computation** - Cache chord notes on param change
   - Result: **~47% avg time reduction**, 35-65% max time reduction
   - Eliminated all inline `music.generate_chord()` calls during seqrun()

**Performance Metrics** (120 BPM, post-optimization):
- Average: 0.103-0.108 ms per seqrun() call
- Max: 2.914-5.375 ms
- Budget: 3.906 ms (max occasionally exceeded in run 1)

### Performance Critical Code

**Never add expensive operations to**:
- `seqrun()` - called 128 times/second at 120 BPM
- `get_params()` - called multiple times per trigger

**Optimization strategies**:
1. Cache param lookups that don't change during playback
2. Pre-compute values when params change (like chord_notes)
3. Early exit/skip for inactive cases
4. Profile with `ENABLE_PROFILING` flag

### Known Performance Bottlenecks

1. **Clock resolution**: 128ppqn means 256 seqrun() calls/second at 120 BPM
2. **Timber param volume**: 100 samples × 50 params = 5000 params (now grouped)
3. **music.generate_chord()**: Expensive, now cached
4. **LFO modulation**: `hnds.lua` applies modulation, not yet profiled

## Development Workflow

### Commit messages

* NEVER insert the "Claude code" text at the end of a commit

### Branch Strategy

- `master`: Stable releases
- `feature/*`: New features (e.g., `feature/nbout-support`)
- `refactor/*`: Code cleanup (e.g., `refactor/clock-stability`)
- `optimize/*`: Performance work (e.g., `optimize/seqrun-performance`)

### Common Issues

**Syntax checking**:
```bash
luac -p /home/hwileniu/git/takt/takt.lua
```

**File too large errors**: Use offset/limit parameters with Read tool.

**String mismatch in Edit**: Comments may contain typos (e.g., `chord[i]` vs `chord[j]`). Read exact text first.

## Future features / optimization

### High Priority

1. **Configurable Clock Resolution**
   - **Why**: 128ppqn may be overkill for non-recording use
   - **Benefit**: 24ppqn = 5.3× performance boost, 48ppqn = 2.7× boost
   - **Approach**: Add param for ppqn selection (16/24/48/96/128)
   - **Complexity**: Moderate - affects clock.sync and position calculations
   - **Files**: takt.lua (clocked_seq, seqrun, advance_step)

2. **Profile LFO Modulation Impact**
   - **Why**: `hnds.lua` applies modulation, never profiled
   - **Benefit**: Unknown - could be significant
   - **Approach**: Add profiling to LFO update/apply functions
   - **Complexity**: Low - follow existing profiling pattern
   - **Files**: lib/hnds.lua

3. **Optimize get_params() Metatable Lookups**
   - **Why**: Called multiple times per trigger
   - **Benefit**: Small but cumulative
   - **Approach**: Cache resolved params for active steps
   - **Complexity**: Medium - requires cache invalidation strategy
   - **Files**: takt.lua:591-611

### Medium Priority

4. **Lazy UI Redraw**
   - **Why**: UI redraws may happen unnecessarily
   - **Benefit**: Reduced CPU usage for UI thread
   - **Approach**: Only redraw on actual state changes
   - **Complexity**: Medium - requires change detection
   - **Files**: lib/ui.lua, takt.lua (redraw calls)

5. **Pattern Data Compression**
   - **Why**: 256 steps × 14 tracks × multiple patterns = memory usage
   - **Benefit**: Reduced memory, potentially better cache locality
   - **Approach**: Run-length encoding for empty steps
   - **Complexity**: High - affects data structure throughout
   - **Files**: lib/_utils.lua, takt.lua (data access patterns)

6. **Batch MIDI Output**
   - **Why**: Individual note_on calls may have overhead
   - **Benefit**: Unknown - likely small
   - **Approach**: Batch multiple MIDI messages per sync
   - **Complexity**: Low-medium
   - **Files**: takt.lua (MIDI output sections)

### Low Priority / Future Features

7. **Swing/Groove Implementation**
   - **Why**: No micro-timing offset currently exists
   - **Benefit**: Musical expressiveness
   - **Approach**: Add per-step or per-track timing offset
   - **Complexity**: Medium - affects clock sync timing
   - **Files**: takt.lua (seqrun, clock.sync calls)

8. **Pattern Chaining/Song Mode**
   - Implement similar features to Octatrack's song mode

9. **MIDI CC Recording**
   - **Why**: Only note recording currently supported
   - **Benefit**: Capture modulation from controllers
   - **Approach**: Record CC to param locks
   - **Complexity**: Medium
   - **Files**: takt.lua (midi_event, place_note)

10. **Euclidean Pattern Generator**
    - **Why**: Common sequencer feature
    - **Benefit**: Quick pattern creation
    - **Approach**: Add euclidean algorithm, integrate with UI
    - **Complexity**: Low-medium
    - **Files**: takt.lua (new utility function), UI integration

11. play bar sync, always start from 1st slot

12. sample chooser starts from previous folder/sample pos
13. instastart
14. easier profiling
15. polyphonic midi record
16. shortcut to reset trig conditions and parameter locks
17. /2 trig condition broken?
18. retain focus when returning to parameter lock edit
19. Create better docs
20. Add conditional trigs (neighbour, fill, etc)
21. inspect if jf, crow and w/syn support should be done via nb
22. two ways to select track (e1 or k1 + e3 when focus), doesn't make sense


## Code Quality Notes

### Recent Cleanup

- **Dead code removed**: Original metro-based sequencer code (59 lines)
- **Param grouping**: 5000 flat params → 100 grouped voices (UX improvement)

### Potential Cleanup

1. **Commented code**: Some old sequencer_metro references remain in comments
2. **Magic numbers**: Consider constants for 256 (positions), 16 (substeps), 14 (tracks)
3. **Function documentation**: Many functions lack doc comments
4. **Error handling**: Limited error checking in MIDI/device operations

## External Dependencies

### Norns Libraries
- `midi`: MIDI device handling
- `clock`: Transport and timing
- `params`: Parameter system
- `engine`: SuperCollider engine interface
- `crow`: Hardware CV interface

### Mods
- **nbout** (optional): Virtual MIDI device for nb voices (channel 17)
  - Supported via extended device handling (feature/nbout-support branch)
  - See: `/home/hwileniu/git/nbout/lib/mod.lua`

### SuperCollider
- Engine: `Engine_Timber_Takt.sc`
- Handles sample playback, envelopes, filters, effects

## Useful References

- Norns documentation: https://monome.org/docs/norns/
- Norns development: `../monosda/AGENTS.md`
- Norns source code and API docs `../norns/docs/`

## Quick Reference

### Key Line Numbers (takt.lua)

- Line 26-61: Profiling infrastructure
- Line 71-74: Cached device type flags
- Line 124-135: `cache_chord_for_step()`
- Line 185-214+: Rules definitions
- Line 371-373: `get_step()` - UI step to position conversion
- Line 591-611: `get_params()` - parameter resolution
- Line 661+: `seqrun()` - main sequencer loop
- Line 843-889: `midi_event()` - MIDI input handling
- Line 1342-1356: `clocked_seq()` - clock loop
- Line 1348: `clock.sync(1/128)` - 128ppqn sync

### Enable Profiling

1. Edit `ENABLE_PROFILING = true` at takt.lua:26
2. OR add param control: "Enable Profiling" in SYSTEM > STATS menu
3. Print stats: "Print Stats" param
4. Reset: "Reset Stats" param

---

*Last updated: 2026-01-04 (optimize/seqrun-performance branch)*
*Optimization status: Chord caching complete, ~47% avg speedup achieved*
