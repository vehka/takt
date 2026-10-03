-- default CC slot params for known nb voices; other voices get their first
-- visible continuous params
--
-- match: Lua pattern for the voice's name
-- slots: keys of the params the six CC slots point at until others are picked
-- skip: keys of params that do nothing when a sequencer plays the voice
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
}
