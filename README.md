This is a fork of the original takt script for norns by itsyourbedtime.

To install, first ensure that you have uninstalled any previous version of takt.  
Then use the following commandline within maiden:

;install https://github.com/chailight/takt

See below for original documentation + modifications / extensions available in this fork
---

![docs](lib/doc.png)

@chailight extensions

Global Clock
------------
By default, this version uses the norns global clock.
Use the Clock options to determine whether takt syncs to Ableton Link, external Crow input or sends out MIDI clock, or modular clock via a Crow output

MIDI chord output
-----------------
You can select chord output instead of note output on a MIDI track.
On the MIDI page, use E2 to scroll to the next setting after the note selection tile. Instead of selecting the next tile, you should see the note symbol above the selected note value light up. 

![docs](lib/takt_note.png)

Use E3 to scroll to the right to select a chord type (M = major, m = minor, etc). The selected note value will be the root of the chord. Chord inversions are currently not supported. If your selected device supports polyphonic playback, then you'll get a chord instead of a single note. 

![docs](lib/takt_chord.png)

Chord types and root notes can be adjusted per step just like any other parameter lock.

Just Friends, w/syn and crow
----------------------------
Takt plays these through [nb](https://github.com/sixolet/nb) voices, not with code of its own:

- Just Friends: [nb_jf](https://github.com/sixolet/nb_jf) (`jf n 1`-`jf n 6`, `jf poly`, `jf unison`, `jf kit`, `jf mpe`)
- crow CV: [nb_crow](https://github.com/sixolet/nb_crow) (`crow 1/2`, `crow 3/4`, `crow para`)
- w/syn: [nb_wsyn](https://github.com/sixolet/nb_wsyn) (`w/syn`)

Install the mod, enable it in SYSTEM > MODS and restart. Then choose the voice for a MIDI track in PARAMS > OUTPUTS > nb voices, and set the track's Device tile to `NB`. The six CC tiles set the voice's parameters (crow's envelope, w/syn's ramp and FM...), per step if you like. See "nb Voices" in the [user manual](USER_MANUAL.md).

This replaces the earlier `JF`, `W/` and `CROW` devices and the crow / jf / wsyn output options. Tracks of an old project that used them show `--` as their device and are silent until you set them to `NB`.

**Not yet tested with the hardware.** If you have a crow, Just Friends or w/syn, reports are welcome.

LFO output
----------
Four LFOs (lib/lfos.lua, modelled on the norns lfo library) move the CC slots of the MIDI tracks, or the picked parameter of an nb voice.
You can set them up in PARAMS > MODULATION > lfo 1-4: pick a target, a shape, a cycle (synced to the clock, or free in seconds), a center and a depth, and turn the LFO on.

The target refers to the CC output "slot" on the MIDI page of a track, e.g. `CC1 8` is the first slot of track 8. You can still change the actual CC number to be whatever you want, e.g. CC 127, and the LFO assigned to that slot will continue to work.

A step that locks the slot's value wins over the LFO until the track's next step without a lock. See USER_MANUAL.md for the details.


