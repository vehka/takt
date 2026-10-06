# TODO

## Roadmap

- Sample chopping.
- A sample -> chop -> p-lock -> resample workflow.
- Portability: an option to bundle a project's samples into its project
  directory.
- crow, Just Friends and w/syn now go through nb voices (nb_crow, nb_jf,
  nb_wsyn). Needs testing by someone with the hardware.

## Trigless locks

A step that changes parameters of the note that is already sounding, without
starting a new one.

- emplaitress supports this through nb's `modulate_note(note, key, value)`, for
  `harmonics`, `timbre`, `morph` and `amp`, in its poly and mono styles (not in
  the perc style). For the first three the value is added to the voice's param,
  so setting the param and sending 0 makes the note take the new value; `amp`
  is a multiplier instead.
- The LFOs already use this: `lfo.output()` in `takt.lua` calls
  `nb_out[tr]:modulate()` for the keys listed as `follow` in
  `lib/nb_defaults.lua`. A trigless lock can go the same way.
- Other nb voices: params with an action change the sound at once, so setting
  the param is enough. Voices that read params at note on only, and have no
  `modulate_note`, can't do it.
- MIDI tracks: send the CCs of the step without a note.
- Open: how a trigless step is entered and shown on the grid.

## Effects from the fx mod

Use the effects of the [fx mod](https://github.com/vehka/fx) with takt's
tracks.

- The mod has two send buses (`~sendA`, `~sendB`) and one insert on the main
  output. It has no inserts per track, and separate insert chains for 14
  tracks would likely cost more CPU than a Pi 3 has. So: sends per track.
- Sample tracks (1-7): `Engine_Timber_Takt.sc` already has reverb and delay
  sends per sample. It would need send A and send B levels too, writing to the
  mod's buses when the mod is there (emplaitress does
  `~sendA ? Server.default.outputBus`). Decide whether these come on top of
  the built-in reverb and delay or replace them, and where they go on the
  screen. Measure the DSP cost on the shield.
- nb tracks: the voice makes the sound, not takt's engine, so takt can't add
  sends to it. A voice built for the fx mod has send params of its own
  (emplaitress: `send_a`, `send_b`), and a CC slot can already point at them,
  with step locks and LFOs. Maybe make those the default for two slots of such
  voices in `lib/nb_defaults.lua`. Voices without send params only reach the
  mod's insert on the main output.
- MIDI tracks: no audio in norns, nothing to do.

## A cheaper reverb than JPverb

JPverb is the most expensive part of `Engine_Timber_Takt.sc`. On the shield
(Pi 3B+) it costs about 27 points of JACK DSP load (38% vs 11% at idle before
the reverb was paused while silent). It is now paused while its input and tail
are silent, but it still runs whenever the sequencer plays, since the default
send is -48 dB.

- Candidates: FreeVerb2 (core SC), GVerb (core SC), Greyhole (sc3-plugins).
  Measure each on the shield with the same settings, and listen: JPverb's long,
  modulated tail is part of takt's sound.
- Measure the cost while playing, not just at idle: the DSP load with a
  pattern running, and xruns from `_norns.audio_get_xrun_count()`.
- Keep the reverb params working (`reverbTime`, `reverbSize` …) or map them to
  the new reverb's params.
- Related: sending to a reverb from the fx mod instead (see above) would let
  users choose the reverb and its cost.
