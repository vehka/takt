# TAKT - User Manual

## Table of Contents

1. [Overview](#overview)
2. [Norns Controls](#norns-controls)
3. [Grid Controls](#grid-controls)
4. [Views and Modes](#views-and-modes)
5. [Sequencer Features](#sequencer-features)
6. [Sample Playback](#sample-playback)
7. [MIDI Features](#midi-features)
8. [Modulation and Effects](#modulation-and-effects)
9. [Pattern Management](#pattern-management)
10. [Configuration](#configuration)
11. [Quick Reference](#quick-reference)

---

## Overview

**Takt** is a parameter-locking sequencer for norns featuring:

- **14 sequencer tracks**
  - Tracks 1-7: Sample playback (Timber engine)
  - Tracks 8-14: MIDI output
- **64 patterns** with meta-sequencer for automatic pattern switching
- **256 steps per track** (16 main steps × 16 substeps each)
- **Per-step parameter locking** with full automation
- **Multiple output types**: MIDI, Just Friends, w/syn, Crow CV
- **Effects**: Delay, reverb, compressor (global)
- **Modulation**: 4 main LFOs + 2 engine LFOs
- **Real-time performance**: Grid-based triggering and recording

---

## Norns Controls

### Buttons (K1, K2, K3)

#### K1 (Left Button)
- **Single press**: Returns to main parameter view (ui_index = 1)
- **Hold**: Access quick-edit mode for track-level parameters
  - Hold K1 + E2: Navigate quick-edit parameters
  - Hold K1 + E3: Adjust quick-edit parameter values

**Quick-Edit Parameters** (K1 + E2):
- **-6**: Global pattern selector
- **-5**: Track selector (same as E1, for quick access)
- **-4**: Global BPM (1-300)
- **-3**: Track scale divider (1-7)
- **-2**: MIDI sync divider (0-7)
- **-1**: Sidechain send level

#### K2 (Center Button)
- **In Patterns view**: Exit patterns, return to last sequencer view
- **In Browser**: Exit browser

#### K3 (Right Button)
- **On Sample parameter**: Open browser to load samples
- **On Filter parameters**: Cycle through filter types
- **In Sampling view**: Trigger sampling actions (record/play/clear)
- **In Notes Input**: Toggle pattern recording on/off
- **General**: Used as modifier for other operations

### Encoders

#### E1 (Track Selector)
- **Rotate**: Select active track (1-14)
  - Tracks 1-7: Sample/engine tracks
  - Tracks 8-14: MIDI tracks
- **Range**: Continuous wrap at boundaries

#### E2 (Parameter Navigator)
- **Without K1**: Navigate through parameter pages
  - Range depends on current view and track type
  - Steps view: (sample engine) or (MIDI)
  - Patterns view: -1 to 18
  - Sampling view: -1 to 6
- **With K1**: Navigate quick-edit parameters (-6 to -1)

#### E3 (Parameter Editor)
- **Adjusts current parameter** based on ui_index
- **With K3 held**: Coarse adjustment for fine-grained parameters
- See [Parameter Reference](#parameter-reference) for details

---

## Grid Controls

### Main Grid (Rows 1-7, Columns 1-16)

#### Standard Mode (No Modifiers)

**Button presses**:
- **First press**: Select step for editing
- **Second press**: Toggle trigger on/off at that step
- **Long hold (>0.2s)**: Clear all substeps under that main step

#### SHIFT Mode (Grid bottom right corner held)

**Columns 1-7**: Set track clock divider
- **Column 1**: 1/16× speed (very slow)
- **Column 2**: 1/8× speed
- **Column 3**: 1/4× speed
- **Column 4**: 1/3× speed
- **Column 5**: 1/2× speed (highlighted)
- **Column 6**: 1.5× speed
- **Column 7**: 1× speed (normal)

**Column 16**: Mute/unmute track
- **Bright (15)**: Track is muted
- **Medium (6)**: Track is active

#### ALT Mode (Left of shift)

**Set loop points**:
- **First press**: Set loop start position
- **Second press**: Set loop end position
- **Display**: Dim (3) shows loop range

#### MOD Mode (Grid X=13 held)

**Copy/paste steps**:
- **First press**: Mark source step (copies 16 substeps)
- **Second press**: Paste to destination
- Copies all triggers and parameter locks

### Control Row (Row 8)

**Button functions**:
- **X=1**: Play/Stop sequencer
  - Bright (15): Running
  - Medium (6): Stopped
- **X=3**: Pattern record indicator (when recording)
- **X=5**: Switch to Engine tracks view (steps_engine)
- **X=6**: Switch to MIDI tracks view (steps_midi)
- **X=8**: Toggle Notes Input mode
- **X=10**: Toggle Sampling mode
- **X=11**: Toggle Patterns view
- **X=13**: MOD button (copy mode)
- **X=15**: ALT button (loop setting)
- **X=16**: SHIFT button (divider/mute)

---

## Views and Modes

### Steps View (Default)

The main sequencer interface showing one track at a time.

**Screen display**:
- Top: Track name, BPM, playback position
- Center: Parameter editor for current ui_index
- Bottom: Waveform (engine) or MIDI visualization (MIDI tracks)

**Grid display**:
- 16 columns = 16 main steps
- 7 rows = 7 visible tracks (switches between 1-7 or 8-14)
- Playhead indicator shows current position

**Access**: Default view, or press Grid X=5/X=6

### Patterns View

Manage and sequence multiple patterns.

**Screen display**:
- 4×16 grid showing all 64 pattern slots
- Current pattern highlighted
- Metaseq range visualization
- Pattern names/numbers

**Grid display**:
- **Rows 1-4**: Pattern slots 1-64
  - **Bright (15)**: Active pattern
  - **Glow (5-14)**: Pattern change pending or in metaseq range
  - **Medium (9)**: Patterns in metaseq range
  - **Dim (6)**: Existing patterns
  - **Off (2)**: Empty slots
- **Row 6**: Metaseq divider selector (columns 1-16)

**Operations**:
- **Single press**: Select pattern to switch to
- **SHIFT + press**: Delete pattern
- **MOD + press (×2)**: Copy pattern
- **E2**: Set metaseq from/to range

**Access**: Press Grid X=11

### Notes Input Mode

Live keyboard for real-time note input and recording.

**Screen display**:
- Keyboard layout visualization
- Record indicator when pattern recording active
- Current track and note information

**Grid display**:
- **Rows 1-4**: Keyboard layout (Linn-style drum machine)
- Buttons trigger notes on current track
- **ALT + buttons**: Show playhead position

**Pattern recording**:
1. Enable Notes Input mode (Grid X=8)
2. Start sequencer (Grid X=1)
3. Toggle pattern record (K3)
4. Play notes on grid - they record at current position
5. Toggle record off when done (K3)

**Access**: Press Grid X=8

### Sampling Mode

Record and manage samples.

**Screen display**:
- Sampling mode indicator
- Waveform display
- Source selection (input L/R/stereo)
- Start/end position markers

**Controls**:
- **E1**: Select target track (1-7)
- **E2**: Navigate sampling parameters
  - -1: Mode (pass-through, record, play, clear)
  - 0: Source (input L/R or stereo)
  - 3: Target slot (1-100)
  - 5: Start position
  - 6: Length
- **E3**: Adjust current parameter
- **K3**: Execute sampling action (record/play/clear based on mode)

**Access**: Press Grid X=10

---

## Sequencer Features

### Triggers and Steps

**Main steps**: 16 positions per track (grid columns 1-16)

**Substeps**: Each main step contains 16 subdivisions
- Total resolution: 256 steps per track
- Allows for precise micro-timing and polyrhythms

**Creating triggers**:
1. Select step (grid press)
2. Press again to create trigger
3. Adjust parameters with E3

**Editing triggers**:
- Select step (grid) + adjust parameters (E2/E3)
- Long-hold step to clear all substeps

### Parameter Locking

**Per-step automation**: Each step can have unique parameter values.

**How to lock parameters**:
1. Select a step on the grid
2. Navigate to parameter (E2)
3. Adjust value (E3)
4. Lock is automatically created for that step

**Lock indicator**: UI shows when parameter is locked to current step

**Default values**: Unlocked steps use track-level default parameters

### Trigger Parameters

Special parameters that control trigger behavior (ui_index -3 to 0):

#### Divider (ui_index -3)
**Values**: 1-7
- Subdivides or multiplies step timing
- 1 = every step, 2 = every other, etc.

#### Rule (ui_index -2)
**Probability-based triggering**:
- **0**: OFF (always triggers)
- **1-7**: Percentage chance (10%, 20%, 30%, 50%, 60%, 70%, 90%)
- **8-14**: Cyclic patterns (/2, /3, /4, /5, /6, /7, /8)

**Examples**:
- Rule 4 (50%): Trigger fires randomly 50% of the time
- Rule 8 (/2): Trigger fires every 2nd cycle only
- Rule 10 (/4): Trigger fires every 4th cycle only

#### Retrig (ui_index -1)
**Values**: 0-15
- Number of repeated triggers within the 16-substep window
- Creates stutter and polyrhythmic effects

#### Offset (ui_index 0)
**Values**: 0-15
- Shifts the retrig pattern start position
- Used in combination with retrig value

**Example**: Retrig=4, Offset=2
- Creates 4 equally-spaced triggers starting at substep 2

---

## Sample Playback

### Loading Samples

**Method 1: Browser**
1. Navigate to Sample parameter (ui_index 1)
2. Press K3 to open browser
3. Select audio file
4. Sample loads into current slot

**Method 2: PARAMS menu**
1. Navigate to PARAMS > SAMPLES
2. Select "Load Folder"
3. Choose folder containing samples
4. Samples load into consecutive slots

**Supported formats**: WAV, AIFF (mono or stereo)

### Sample Parameters (Engine Tracks)

**ui_index 1-20** for sample playback control:

1. **Sample**: Select sample slot (1-100)
2. **Note**: Pitch transposition (25-127 MIDI note)
   - Hold K3: Detune in cents (-100 to +100)
3. **Start Frame**: Sample start position
4. **End Frame**: Sample end position
5. **Freq LFO1**: Frequency modulation amount (0-1)
6. **Freq LFO2**: Frequency modulation amount (0-1)
7. **Amplitude**: Volume level (-64 to +16 dB)
8. **Pan**: Stereo position (-1 left, 0 center, +1 right)
9. **Attack**: Amplitude envelope attack (0-5s)
10. **Decay**: Amplitude envelope decay (0.01-5s)
11. **Sustain**: Amplitude envelope sustain level (0-1)
12. **Release**: Amplitude envelope release (0-10s)
13. **Amp LFO1**: Amplitude modulation amount (0-1)
14. **Filter LFO2**: Filter frequency modulation amount (0-1)
15. **Quality**: Sample rate quality (1-5)
16. **Play Mode**: Playback behavior (1-4)
17. **Filter Freq**: Cutoff frequency (20Hz-20kHz)
18. **Filter Res**: Resonance (0-1, self-oscillates at 1.0)
19. **Delay Send**: Delay effect send level (-48 to 0 dB)
20. **Reverb Send**: Reverb effect send level (-48 to 0 dB)

### Play Modes (ui_index 16)

1. **Oneshot**: Plays sample once from start to end, then stops
2. **Loop**: Continuously loops between start and end frames
3. **Sustain**: Loops while trigger is active, stops when released
4. **Toggle**: Start/stop playback on each trigger (manual gate)

### Envelope Shaping

**ADSR envelope** (ui_index 9-12):
- **Attack**: Fade-in time when note triggered
- **Decay**: Time to decay from peak to sustain level
- **Sustain**: Held level while trigger active
- **Release**: Fade-out time after trigger released

**Typical settings**:
- Percussive: A=0, D=short, S=0, R=short
- Pad: A=medium, D=medium, S=0.7, R=long
- Pluck: A=0, D=medium, S=0, R=medium

---

## MIDI Features

### MIDI Output (Tracks 8-14)

**ui_index 1-19** for MIDI control:

1. **Note**: MIDI note number (25-127)
   - For Crow: 0-120 (raw voltage output)
2. **Chord**: Chord type (-1 to 26)
   - -1 = Off (single note)
   - 0-25 = Various chord types (see [Chord Types](#chord-types))
3. **Velocity**: Note velocity (0-127)
4. **Length**: Note duration in steps (1-256)
5. **Channel**: MIDI channel (1-16)
6. **Device**: Output device (1-10, see [Output Devices](#output-devices))
7. **Program Change**: MIDI program number (-1=off, 0-127)
8-13. **CC Values**: Control Change values (0-127)
14-19. **CC Numbers**: Control Change numbers (1-127)

### Chord Types

**-1**: Off (single note only)

**Major chords** (0-6):
- 0: Major
- 6: Major 6
- 7: Major 7
- 8: Major 69
- 12: Major 9
- 15: Major 11
- 17: Major 13

**Minor chords** (1, 5-8, 13, 16, 18):
- 1: Minor
- 5: Minor 7
- 6: Minor Major 7
- 8: Minor 6
- 9: Minor 69
- 13: Minor 9
- 16: Minor 11
- 18: Minor 13

**Dominant/Jazz chords** (2-4, 11, 14):
- 2: Dominant 7
- 11: Ninth
- 14: Eleventh
- 17: Thirteenth

**Suspended/Altered** (19-25):
- 19: Sus4
- 20: Seventh sus4
- 21: Diminished
- 22: Diminished 7
- 23: Half Diminished 7
- 24: Augmented
- 25: Augmented 7

### Output Devices

1-4. **MIDI Devices 1-4**: Standard MIDI output ports
5. **Just Friends**: i2c modular synth (via Crow)
6. **w/syn**: WaveShaper synthesizer (via Crow i2c)
7. **Crow**: CV output (4 channels, gate/pitch)
8-17. **Additional MIDI devices** (if available via nbout mod)

### MIDI Recording

**External MIDI input**:
1. Connect MIDI controller to norns
2. Set PARAMS > OUTPUTS > "midi input track" (0=grid focus, 1-14=specific track)
3. Enable Notes Input mode (Grid X=8)
4. Start sequencer (Grid X=1)
5. Toggle pattern recording (K3)
6. Play MIDI controller - notes record to pattern
7. Toggle recording off (K3)

**Recorded data**: Note values locked to steps as triggers fire

---

## Modulation and Effects

### LFOs (Low Frequency Oscillators)

**4 Main LFOs** (synchronized to master clock):

**Access**: PARAMS > MODULATION > lfo 1-4

**Per-LFO parameters**:
- **Target**: Modulation destination (select from lfo_targets list)
- **Shape**: Waveform (sine, triangle, saw, square, random, etc.)
- **Frequency**: LFO rate (Hz)
- **Depth**: Modulation amount (0-100%)
- **Phase**: Start phase offset (0-360°)
- **Offset**: DC offset (-4.0 to +3.0)

**Engine LFO modulation** (per-step):
- **ui_index 5**: Frequency modulation (LFO 1)
- **ui_index 6**: Frequency modulation (LFO 2)
- **ui_index 13**: Amplitude modulation (LFO 1)
- **ui_index 14**: Filter frequency modulation (LFO 2)

**LFO Targets** (examples):
- CC values for MIDI tracks (8-14)
- Sample parameters
- Filter frequency
- Amplitude
- Pan

**2 Engine LFOs** (Timber internal):

**Access**: PARAMS > SAMPLES > SAMPLE LFOs

- **LFO1 Freq**: Frequency (Hz)
- **LFO1 Shape**: Waveform
- **LFO2 Freq**: Frequency (Hz)
- **LFO2 Shape**: Waveform

**Usage**: Automatically modulate assigned parameters per sample

### Effects (Global Processing)

#### Delay

**Access**: PARAMS > SAMPLES > DELAY

- **Time**: Delay duration (0.0001-5s, exponential)
- **Feedback**: Wet signal recirculation (0-100%)
- **Level**: Output mix level (-48 to 0 dB)

**Per-step send**: ui_index 19 (Delay Send)

#### Reverb

**Access**: PARAMS > SAMPLES > REVERB

- **Time**: Decay length (0.1-60s)
- **Size**: Room size simulation (0.5-5.0)
- **Damp**: High-frequency damping (0-1)
- **Diff**: Diffusion/scatter amount (0-1)
- **Mod Depth**: Chorus modulation depth (0-1)
- **Mod Freq**: Chorus modulation rate (0-10 Hz)
- **Low/Mid/High Mult**: EQ multipliers (0-1)
- **Low/High Cut**: EQ cutoff frequencies (Hz)

**Per-step send**: ui_index 20 (Reverb Send)

#### Compressor

**Access**: PARAMS > SAMPLES > COMPRESSOR

- **Level**: Makeup gain output (-24 to +24 dB)
- **Dry/Wet**: Mix ratio (0-100%)
- **Threshold**: Compression threshold (0.01-1.0)
- **Slope Below**: Ratio below threshold (0.1-1.5)
- **Slope Above**: Ratio above threshold (0.5-10)
- **Clamp Time**: Attack speed (0.001-0.1s)
- **Relax Time**: Release speed (0.01-1s)

**Global processing**: Affects entire mix after individual track processing

**Sidechain**: Track-level sidechain send (ui_index -1 in quick-edit)

---

## Pattern Management

### Patterns (64 Total)

**What is a pattern?**
- Complete sequencer state for all 14 tracks
- Includes: triggers, parameter locks, loop points, mutes, dividers
- Independent playback and editing

**Pattern Grid**: 4 rows × 16 columns = 64 slots

**Pattern slots**:
- Row 1: Patterns 1-16
- Row 2: Patterns 17-32
- Row 3: Patterns 33-48
- Row 4: Patterns 49-64

### Pattern Operations

**Switching patterns**:
1. Enter Patterns view (Grid X=11)
2. Press pattern slot to queue change
3. Pattern switches at end of current cycle (if sequencer running)
   - Or immediately if stopped

**Creating patterns**:
- Patterns automatically created when you sequence on empty slots
- Copy existing pattern: MOD + source + destination

**Deleting patterns**:
- SHIFT + pattern slot press (in Patterns view)
- Cannot delete currently active pattern

**Copying patterns**:
1. Enter Patterns view (Grid X=11)
2. Press MOD (Grid X=13)
3. Press source pattern
4. Press destination pattern
5. Full pattern data duplicated

### Meta-Sequencer (Automatic Pattern Chaining)

**What is metaseq?**
- Automatically cycles through a range of patterns
- Based on track playback position and divider

**Setting up metaseq**:
1. Enter Patterns view (Grid X=11)
2. **E2 rotate**: Set "from" pattern (first press)
3. **E2 rotate**: Set "to" pattern (second press)
4. **Grid Row 6**: Select metaseq divider (columns 1-16)

**How it works**:
- When track reaches end position, pattern advances
- Cycles from "from" → "to" pattern continuously
- Divider controls how many cycles before advancing

**Example**:
- From: Pattern 1
- To: Pattern 4
- Divider: 4
- Result: Plays pattern 1 for 4 cycles, then 2, then 3, then 4, repeats

**Disabling metaseq**: Set from=to (same pattern)

### Project Management

**Saving projects**:
1. Navigate to PARAMS > PROJECT
2. Select "Save project"
3. Enter project name
4. All patterns, samples, and settings saved

**Loading projects**:
1. Navigate to PARAMS > PROJECT
2. Select "Load project"
3. Browse and select .pset file
4. Entire project state restored

**Creating new project**:
1. PARAMS > PROJECT > "New"
2. Initializes fresh pattern data

---

## Configuration

### Scale Settings

**Access**: PARAMS > SCALE

- **Scale mode**: Select musical scale (Major, Minor, Dorian, etc.)
- **Root note**: Base note (C, C#, D, ..., B)

**Usage**: Quantizes sample playback to selected scale

### Hardware Settings

**Access**: PARAMS > HARDWARE

- **Grid brightness**:
  - Varibright: Full 16-level brightness (default)
  - 4-step (2011): Compatibility mode for older grids (4 levels)

### Output Configuration

**Access**: PARAMS > OUTPUTS

**Device enables**:
- **Crow output**: Off / Full voice / 2 voices / JF+Crow
- **JF output**: Enable/disable Just Friends i2c
- **w/syn output**: Enable/disable WaveShaper i2c
- **MIDI input track**: Route external MIDI (0=grid focus, 1-14=specific)

**Crow options** (group):
- Output quantization (note/raw voltage)
- Output 1-4 range (0-10V or ±5V)
- Slew rate per output
- Scale per output

**w/syn options** (group):
- AR mode (off/on)
- Velocity, Curve, FM settings
- Envelope parameters
- Additional synthesis controls

### Clock Settings

**Access**: PARAMS > CLOCK (norns system params)

- **Source**: Internal / MIDI / Link / Crow
- **Tempo**: BPM when using internal clock
- **PPQN**: Pulses per quarter note (fixed at 128 for takt)

### Mixer Settings

**Access**: PARAMS > MIXER > track controls

**Per-track controls** (Tracks 1-7):
- **Volume**: Track output level (-64 to +16 dB)
- **Reverb Send**: Track reverb send level (-64 to +16 dB)
- **Delay Send**: Track delay send level (-64 to +16 dB)
- **Cutoff**: Track filter cutoff (0.1 to 20000 Hz)

**Usage**: Quick mix adjustments without editing individual step locks

### System Settings

**Access**: PARAMS > SYSTEM

**Profiling** (advanced users):
- **Enable Profiling**: Turn on performance monitoring (yes/no)
- **Print Profile Stats**: Display current stats in console
- **Reset Profile Stats**: Clear accumulated data

**Stats tracked**:
- seqrun() execution time (avg/max)
- Triggers fired
- Chord generations
- MIDI/engine outputs

---

## Quick Reference

### Grid Button Map (Row 8)

```
 1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16
[►] [ ] [R] [ ] [E] [M] [ ] [N] [ ] [S] [P] [ ] [MOD] [ ] [ALT] [SFT]

► = Play/Stop
R = Record (when in Notes Input)
E = Engine tracks view
M = MIDI tracks view
N = Notes Input mode
S = Sampling mode
P = Patterns view
MOD = Copy mode
ALT = Loop set mode
SFT = Shift (divider/mute)
```

### Norns Button Shortcuts

| Action | Buttons | Description |
|--------|---------|-------------|
| Select track | E1 | Tracks 1-14 |
| Navigate params | E2 | ui_index -3 to 20 |
| Edit param | E3 | Adjust current value |
| Quick-edit | K1 + E2 | Track params -6 to -1 |
| Load sample | K3 | When on Sample param |
| Toggle filter | K3 | When on Filter param |
| Pattern record | K3 | In Notes Input mode |
| Sampling action | K3 | In Sampling mode |

### Parameter Ranges (Engine Tracks)

| Parameter | Range | Description |
|-----------|-------|-------------|
| Sample | 1-100 | Sample slot |
| Note | 25-127 | MIDI note (pitch) |
| Detune | -100 to +100 | Cents (K3 held) |
| Start Frame | 0 to length | Sample start position |
| End Frame | 0 to length | Sample end position |
| Amplitude | -64 to +16 | Volume in dB |
| Pan | -1 to +1 | Stereo position |
| Attack | 0 to 5 | Envelope attack (s) |
| Decay | 0.01 to 5 | Envelope decay (s) |
| Sustain | 0 to 1 | Envelope sustain level |
| Release | 0 to 10 | Envelope release (s) |
| Filter Freq | 20 to 20000 | Cutoff frequency (Hz) |
| Filter Res | 0 to 1 | Resonance amount |
| Delay Send | -48 to 0 | Delay send (dB) |
| Reverb Send | -48 to 0 | Reverb send (dB) |

### Parameter Ranges (MIDI Tracks)

| Parameter | Range | Description |
|-----------|-------|-------------|
| Note | 25-127 | MIDI note number |
| Chord | -1 to 26 | Chord type |
| Velocity | 0-127 | Note velocity |
| Length | 1-256 | Note duration (steps) |
| Channel | 1-16 | MIDI channel |
| Device | 1-17 | Output device |
| Program | -1 to 127 | Program change |
| CC 1-6 | 0-127 | CC values |

### Trigger Parameters

| Parameter | Range | Description |
|-----------|-------|-------------|
| Divider | 1-7 | Clock division |
| Rule | 0-14 | Probability/pattern |
| Retrig | 0-15 | Repeat count |
| Offset | 0-15 | Retrig offset |

### Common Workflows

**Basic sequence**:
1. E1 → Select track
2. Grid press → Select step
3. Grid press → Create trigger
4. E2/E3 → Edit parameters
5. Grid X=1 → Start

**Pattern chain**:
1. Grid X=11 → Patterns view
2. Create patterns
3. E2 → Set metaseq from/to
4. Grid Row 6 → Set divider

**Sample loading**:
1. E2 → ui_index 1 (Sample)
2. K3 → Open browser
3. Select file
4. Sample loads

**MIDI chord sequence**:
1. E1 → Select MIDI track (8-14)
2. Grid → Create triggers
3. E2 → ui_index 2 (Chord)
4. E3 → Select chord type

**Loop recording**:
1. Grid X=8 → Notes Input
2. Grid X=1 → Start
3. K3 → Toggle record
4. Play grid notes
5. K3 → Stop record

---

## Tips and Tricks

### Performance Techniques

**Live muting**:
- SHIFT + Grid X=16 (row Y=track) to quickly mute/unmute tracks
- Build arrangements by muting/unmuting combinations

**Pattern switching**:
- Queue pattern changes in Patterns view
- Switches happen at bar boundaries for seamless transitions

**Parameter locks**:
- Lock parameters per-step for evolving sequences
- Different velocities, notes, filter settings per trigger

**Retrigs for fills**:
- Use retrig parameter for drum fills and stutter effects
- Combine with offset for polyrhythmic patterns

### Sound Design

**Layering samples**:
- Use multiple tracks with same sample
- Different start/end points create variation
- Pan and detune for width

**Envelope tricks**:
- Zero attack + short decay = percussive
- Long attack + long release = pad/drone
- Sustain = 0 for pluck sounds

**Filter motion**:
- Lock filter frequency per step
- Use Filter LFO2 modulation for movement
- High resonance for emphasis

**Effects routing**:
- Higher delay/reverb sends on melodic elements
- Dry drums, wet pads/leads
- Sidechain compressor for pumping

### Modulation Ideas

**LFO targets**:
- Modulate CC values for external gear parameter sweeps
- Filter frequency for rhythmic filtering
- Pan for stereo movement
- Amplitude for tremolo

**Envelope modulation**:
- Use amplitude envelope on bass for punch
- Long attack on pads for swells
- Short release on hi-hats for tight sound

---

## Troubleshooting

**No sound from engine tracks**:
- Check sample is loaded (ui_index 1)
- Verify amplitude is not at minimum
- Check track is not muted (SHIFT + Grid X=16)
- Ensure sequencer is running (Grid X=1)

**MIDI not sending**:
- Verify device is selected (ui_index 6)
- Check MIDI channel matches receiving device
- Confirm track is not muted
- Test with different MIDI device

**Grid buttons not responding**:
- Verify grid is connected
- Check grid brightness setting (PARAMS > HARDWARE)
- Try unplugging and reconnecting grid
- Restart norns

**Clock sync issues**:
- Set clock source (PARAMS > CLOCK)
- For external sync, ensure MIDI clock is being sent
- Check divider settings aren't conflicting
- Verify BPM is set correctly

**Samples won't load**:
- Confirm file format is supported (WAV, AIFF)
- Check file isn't corrupted
- Ensure sufficient memory available
- Try loading smaller file first

**Performance/lag**:
- Disable profiling if enabled (PARAMS > SYSTEM)
- Reduce number of active LFOs
- Lower chord generation usage
- Consider reducing sample count

---

*User manual generated for takt v2.3+*
*For latest updates and community support, visit: https://llllllll.co*
