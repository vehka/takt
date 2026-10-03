# TODO

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
