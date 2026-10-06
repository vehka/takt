-- default CC slot params for known nb voices; other voices get their first
-- visible continuous params
--
-- match: Lua pattern for the voice's name
-- slots: keys of the params the six CC slots point at until others are picked
-- skip: keys of params that do nothing when a sequencer plays the voice
-- follow: keys of params the voice reads at note on only, where
--   modulate_note(note, key, 0) makes a sounding note take the param's new value
-- variant: key of an option param (emplaitress's model) whose choices have
--   slots of their own, listed by option name in variants
--
-- a key is a param's id without the part all of the voice's ids share,
-- e.g. "timbre" for emplaitress's plaits_timbre_1

-- Plaits runs most models through a low-pass gate, shaped by decay and lpg
-- colour. The models with an envelope of their own bypass the gate, so those
-- two params do nothing there; they get aux mix and the fm (pitch) envelope
local plaits_gated = { "model", "harmonics", "timbre", "morph", "decay", "lpg_color" }
local plaits_enveloped = { "model", "harmonics", "timbre", "morph", "aux", "fm_mod" }

return {
  {
    match = "^emplait %d+$",
    slots = plaits_gated,
    skip = { "note" }, -- only read by the voice's own trigger and gate params
    follow = { "harmonics", "timbre", "morph" },
    variant = "model",
    variants = {
      ["classic analog"] = plaits_gated,
      ["waveshaping"] = plaits_gated,
      ["fm"] = plaits_gated,
      ["formant"] = plaits_gated,
      ["harmonic"] = plaits_gated,
      ["wavetable"] = plaits_gated,
      ["chord"] = plaits_gated,
      ["speech"] = plaits_gated,
      ["swarm"] = plaits_gated,
      ["noise"] = plaits_gated,
      ["particle"] = plaits_gated,
      ["string"] = plaits_enveloped,
      ["modal"] = plaits_enveloped,
      ["kick"] = plaits_enveloped,
      ["snare"] = plaits_enveloped,
      ["hat"] = plaits_enveloped,
    },
  },
  {
    -- nb_pp: the four macros (named after the model), then the low-pass gate
    match = "^palette %d+$",
    slots = { "harmonics", "timbre", "morph", "macro", "decay", "lpg_color" },
  },
  {
    match = "^polyperc %d+$",
    slots = { "cutoff", "decay", "pw", "tracking", "amp", "pan" },
  },
  {
    match = "^doubledecker$",
    slots = { "brilliance", "resonance", "mix", "detune", "lfo_rate", "lfo_to_filter" },
  },
  {
    match = "^fluid %d+$",
    slots = { "volume", "pan", "reverb", "chorus", "program", "bank" },
  },
  {
    -- nb_crow: the envelope of the output pair; not "tuned to" (freq), which
    -- retunes the voice
    match = "^crow %d/%d$",
    slots = { "attack_time", "decay_time", "sustain", "release_time", "portomento", "decay_shape" },
  },
  {
    match = "^crow para$",
    slots = { "attack_time", "decay_time", "sustain", "release_time", "attack_shape", "decay_shape" },
  },
  {
    -- nb_wsyn: the fm ratio (fm_num, fm_denom) can be picked for a slot
    match = "^w/syn$",
    slots = { "w/curve", "w/ramp", "w/fm_index", "w/fm_env", "w/lpg_time", "w/lpg_symmetry" },
  },
}
