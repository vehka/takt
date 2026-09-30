-- Split seqrun() time into params:set (set_locks), engine.noteOn and the rest, and
-- note GC activity. Run after stress.lua has filled the pattern, while stopped.
local function upv(f, name)
  for i = 1, 300 do
    local n, v = debug.getupvalue(f, i)
    if not n then return nil end
    if n == name then return v, i end
  end
end
local seqrun = upv(clocked_seq, "seqrun")
if seqrun == STRESS_WRAPPER then seqrun = STRESS_ORIG_SEQRUN end

local acc = { set = 0, set_n = 0, eng = 0, eng_n = 0, total = 0, max = 0, max_set = 0 }
-- a failed earlier probe may have left params.set wrapped; the raw method lives in the class
params.set = nil
local orig_set = params.set
params.set = function(self, ...)
  local t = util.time()
  orig_set(self, ...)
  local e = util.time() - t
  acc.set, acc.set_n = acc.set + e, acc.set_n + 1
  if e > acc.max_set then acc.max_set = e; acc.max_set_id = select(1, ...) end
end

local gc0 = collectgarbage("count")
for c = 1, 2048 do
  local t = util.time()
  seqrun(c)
  local e = util.time() - t
  acc.total = acc.total + e
  if e > acc.max then acc.max = e end
end
params.set = nil
print(string.format("probe: 2048 ticks total %.1f ms (max %.1f ms) | params:set %d calls %.1f ms (max %.2f ms, %s) | lua mem %.0f -> %.0f KB",
  acc.total * 1000, acc.max * 1000, acc.set_n, acc.set * 1000, acc.max_set * 1000, tostring(acc.max_set_id), gc0, collectgarbage("count")))
