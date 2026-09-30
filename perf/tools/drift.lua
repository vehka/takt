-- Clock drift: run the transport on the internal clock and compare seqrun() calls
-- to elapsed clock beats. The sequencer should run 128 ticks per beat.
--   DRIFT_SECONDS = 20; dofile(<this file>)
local function upv_index(f, name)
  for i = 1, 300 do
    local n = debug.getupvalue(f, i)
    if not n then return nil end
    if n == name then return i end
  end
end
local idx = upv_index(clocked_seq, "seqrun")
local orig = select(2, debug.getupvalue(clocked_seq, idx))
if orig == STRESS_WRAPPER then orig = STRESS_ORIG_SEQRUN end
local calls = 0
debug.setupvalue(clocked_seq, idx, function(c) calls = calls + 1 orig(c) end)
clock.transport.start()
clock.run(function()
  clock.sleep(4) -- skip the start, which may wait for the bar
  local b0, c0 = clock.get_beats(), calls
  clock.sleep(DRIFT_SECONDS or 20)
  local beats, ticks = clock.get_beats() - b0, calls - c0
  clock.transport.stop()
  debug.setupvalue(clocked_seq, idx, orig)
  print(string.format("drift: %.2f beats, %d ticks, %.3f ticks/beat (expected 128)", beats, ticks, ticks / beats))
end)
