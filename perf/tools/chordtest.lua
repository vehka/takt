-- Functional chord test for takt, run inside matron: dofile(<this file>)
-- Drives seqrun() directly on MIDI track 8 and logs vport note on/off.
local music = require 'musicutil'

local function upv(f, name)
  for i = 1, 300 do
    local n, v = debug.getupvalue(f, i)
    if not n then return nil end
    if n == name then return v end
  end
end

local data = upv(clocked_seq, 'data')
local seqrun = upv(clocked_seq, 'seqrun')
local chord_names = {"Major", "Minor", "Dominant 7", "Major 7", "Minor 7", "Minor Major 7", "Major 6", "Minor 6", "Major 69", "Minor 69", "Ninth", "Major 9", "Minor 9", "Eleventh", "Major 11", "Minor 11", "Thirteenth", "Major 13", "Minor 13", "Sus4", "Seventh sus4", "Diminished", "Diminished 7", "Half Diminished 7", "Augmented", "Augmented 7"}

local on, off = {}, {}
local vp = midi.vports[1]
local orig_on, orig_off = vp.note_on, vp.note_off
vp.note_on = function(self, n, v, ch) on[#on + 1] = n end
vp.note_off = function(self, n, v, ch) off[#off + 1] = n end

local fails = 0
local function check(label, ok, detail)
  if not ok then fails = fails + 1 end
  print(string.format("%s %s%s", ok and "PASS" or "FAIL", label, detail and ("  " .. detail) or ""))
end
local function same(a, b)
  if #a ~= #b then return false end
  table.sort(a) table.sort(b)
  for i = 1, #a do if a[i] ~= b[i] then return false end end
  return true
end
local function list(t) return "{" .. table.concat(t, ",") .. "}" end

local P = data.pattern
local TR = 8
local tr = data[P][TR]
for i = 1, 14 do data[P].track.mute[i] = (i ~= TR) end

-- play one trigger at pos 1 with given step settings; run until note-off
local function play(step_setup, ticks)
  for i = 0, 256 do tr[i] = 0 end
  tr[1] = 1
  for k in pairs(tr.params[1]) do tr.params[1][k] = nil end
  for k, v in pairs(step_setup) do tr.params[1][k] = v end
  data[P].track.pos[TR] = 0
  data[P].track.len[TR] = 256
  data[P].track.div[TR] = 5
  on, off = {}, {}
  for c = 1, ticks or 8 do seqrun(c) end
end

-- 1. every chord type, locked step
for c = 1, 26 do
  play({ lock = 1, note = 60, chord = c, length = 2 })
  local expect = music.generate_chord(60, chord_names[c])
  check("chord " .. c .. " " .. chord_names[c], same(on, expect) and same(off, expect), "on " .. list(on) .. " off " .. list(off))
end

-- 2. chord -1 and 0 play only the root
for _, c in ipairs({ -1, 0 }) do
  play({ lock = 1, note = 60, chord = c, length = 2 })
  check("chord " .. c .. " root only", same(on, { 60 }) and same(off, { 60 }), "on " .. list(on))
end

-- 3. RND NOTE rule changes the note at play time; chord must follow the new root
math.randomseed(1)
play({ lock = 1, note = 60, chord = 1, rule = 15, length = 2 })
local root = tr.params[1].note
check("RND NOTE chord follows new root " .. root, same(on, music.generate_chord(root, "Major")) and same(off, on), "on " .. list(on) .. " off " .. list(off))

-- 4. unlocked step inherits track default chord
local default = tr.params[tostring(TR)]
local saved_chord, saved_note = default.chord, default.note
default.chord, default.note = 2, 64
play({ lock = 0, length = 2 })
check("inherited default chord (Minor on 64)", same(on, music.generate_chord(64, "Minor")), "on " .. list(on))
default.chord, default.note = saved_chord, saved_note

vp.note_on, vp.note_off = orig_on, orig_off
for i = 0, 256 do tr[i] = 0 end
for i = 1, 14 do data[P].track.mute[i] = false end
print(string.format("chordtest done: %d failures", fails))
