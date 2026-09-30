-- note-on/off balance: every note that starts must stop exactly once
local function upv(f, name)
  for i = 1, 300 do
    local n, v = debug.getupvalue(f, i)
    if not n then return nil end
    if n == name then return v end
  end
end
local seqrun = upv(clocked_seq, "seqrun")
if seqrun == STRESS_WRAPPER then seqrun = STRESS_ORIG_SEQRUN end
local data = upv(clocked_seq, "data")
local notes_off = upv(clock.transport.stop, "notes_off_midi") -- may be nil
local P, TR = data.pattern, 8
local vp = midi.vports[1]
local function case(label, trigs, length, chord)
  for tr = 1, 14 do
    data[P].track.mute[tr] = tr ~= TR
    for pos = 0, 256 do data[P][tr][pos] = 0 end
  end
  for _, pos in ipairs(trigs) do
    data[P][TR][pos] = 1
    local p = data[P][TR].params[pos]
    p.lock, p.note, p.chord, p.length = 1, 60 + pos % 12, chord, length
  end
  data[P].track.pos[TR] = 0
  upv(seqrun, "choke")[TR][6] = nil -- forget the previous case's sounding note
  local sounding, ons, offs, bad = {}, 0, 0, 0
  vp.note_on = function(_, n) ons = ons + 1; if sounding[n] then bad = bad + 1 end; sounding[n] = true end
  vp.note_off = function(_, n) offs = offs + 1; if not sounding[n] then bad = bad + 1 end; sounding[n] = nil end
  for c = 1, 1024 do seqrun(c) end -- two passes through the pattern
  local hanging = 0
  for _ in pairs(sounding) do hanging = hanging + 1 end
  vp.note_on, vp.note_off = nil, nil
  print(string.format("noteoff2 %-34s on %4d off %4d, double/unmatched %d, still sounding %d (max 1 chord ok)", label, ons, offs, bad, hanging))
end
case("single note, length 3", { 1 }, 3, -1)
case("16ths, length 3, 13th chord", { 1, 17, 33, 49, 65, 81, 97, 113, 129, 145, 161, 177, 193, 209, 225, 241 }, 3, 17)
case("overlapping, length 40", { 1, 17, 33 }, 40, 1)
case("across the wrap, pos 250 len 20", { 250 }, 20, -1)
print("noteoff2 done")
