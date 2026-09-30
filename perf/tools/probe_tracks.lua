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
local function run(label, lo, hi)
  for tr = 1, 14 do data[data.pattern].track.mute[tr] = not (tr >= lo and tr <= hi) end
  local t = util.time()
  for c = 1, 512 do seqrun(c) end
  print(string.format("probe2 %s: 512 ticks %.1f ms", label, (util.time() - t) * 1000))
end
run("sample tracks 1-7", 1, 7)
run("midi tracks 8-14", 8, 14)
run("none", 99, 99)
print("probe2 done")
