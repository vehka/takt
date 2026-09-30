-- takt synthetic stress test. Run inside matron with takt loaded:
--   STRESS_LEVEL = "normal" | "heavy"; STRESS_SECONDS = 60; STRESS_LABEL = "x"; dofile(<this file>)
-- Works on any takt branch: seqrun() is wrapped from outside via clocked_seq's upvalue.
-- Results are printed and written to data/takt/stress_<label>.txt.

local LEVEL = STRESS_LEVEL or "normal"
local SECONDS = STRESS_SECONDS or 60
local LABEL = STRESS_LABEL or LEVEL
local SAMPLE_DIR = STRESS_SAMPLE_DIR or (_path.audio .. "common/808/")
local SAMPLES = { "808-BD.wav", "808-SD.wav", "808-CH.wav", "808-OH.wav", "808-CP.wav", "808-LT.wav", "808-CY.wav" }

local function upv_index(f, name)
  for i = 1, 300 do
    local n = debug.getupvalue(f, i)
    if not n then return nil end
    if n == name then return i end
  end
end

local data = select(2, debug.getupvalue(clocked_seq, upv_index(clocked_seq, "data")))
local seq_idx = upv_index(clocked_seq, "seqrun")
local orig_seqrun = select(2, debug.getupvalue(clocked_seq, seq_idx))
-- if a previous run's wrapper is still installed in this script instance, unwrap it
if orig_seqrun == STRESS_WRAPPER then orig_seqrun = STRESS_ORIG_SEQRUN end

math.randomseed(42)
local P = data.pattern

-- step positions that get triggers: every 16th (normal) or every 64th (heavy)
local every = LEVEL == "heavy" and 4 or 16

for tr = 1, 14 do
  local t = data[P][tr]
  data[P].track.mute[tr] = false
  data[P].track.pos[tr] = 0
  data[P].track.start[tr] = 1
  data[P].track.len[tr] = 256
  data[P].track.div[tr] = 5
  for pos = 0, 256 do
    t[pos] = 0
    local p = t.params[pos]
    for k in pairs(p) do p[k] = nil end
  end
  for pos = 1, 256, every do
    t[pos] = 1
    local p = t.params[pos]
    p.lock = 1
    if tr <= 7 then
      p.note = math.random(48, 72)
      p.filter_freq = math.random(200, 18000)
      p.filter_resonance = math.random() * 0.5
      p.pan = math.random() * 2 - 1
      p.amp = -math.random(0, 6)
      p.delay_send = -math.random(10, 40)
      p.reverb_send = -math.random(10, 40)
    else
      p.note = math.random(40, 70)
      p.chord = LEVEL == "heavy" and math.random(17, 19) or math.random(1, 26)
      p.length = 3
      p.velocity = math.random(60, 120)
      p.rule = (pos % 32 == 1) and 16 or 0 -- "+- NOTE" on some steps
    end
  end
end

for i = 1, 7 do params:set("sample_" .. i, SAMPLE_DIR .. SAMPLES[i]) end
for i = 1, 4 do
  params:set(i .. "lfo_target", 2)
  params:set(i .. "lfo_freq", 5)
  params:set(i .. "lfo", 2)
end

-- instrumentation
local r = {
  calls = 0, total = 0, max = 0, over = 0, hist = {},
  late_total = 0, late_max = 0,
  xruns = 0, xrun_times = {}, cpu_max = 0, cpu_total = 0, cpu_n = 0,
  mem_max = 0,
}
local budget -- seconds per 1/128 tick, fixed at start

local function wrapped(counter)
  local beats = clock.get_beats()
  local late = (beats - math.floor(beats * 128 + 0.5) / 128) * clock.get_beat_sec()
  local t0 = util.time()
  orig_seqrun(counter)
  local e = util.time() - t0
  r.calls = r.calls + 1
  r.total = r.total + e
  if e > r.max then r.max = e end
  if e > budget then r.over = r.over + 1 end
  local b = math.min(1000, math.floor(e * 10000))
  r.hist[b] = (r.hist[b] or 0) + 1
  r.late_total = r.late_total + late
  if late > r.late_max then r.late_max = late end
end

local function pct(p)
  local target, seen = r.calls * p, 0
  for b = 0, 1000 do
    seen = seen + (r.hist[b] or 0)
    if seen >= target then return b / 10 end
  end
  return 100
end

clock.run(function()
  clock.sleep(3) -- let samples load
  _norns.audio_get_xrun_count() -- clear the counter
  budget = clock.get_beat_sec() / 128
  STRESS_WRAPPER, STRESS_ORIG_SEQRUN = wrapped, orig_seqrun
  debug.setupvalue(clocked_seq, seq_idx, wrapped)
  local start_wall = os.date("%Y-%m-%d %H:%M:%S")
  local t_start = util.time()
  clock.transport.start()
  while util.time() - t_start < SECONDS do
    clock.sleep(0.25)
    local x = _norns.audio_get_xrun_count()
    if x > 0 then
      r.xruns = r.xruns + x
      r.xrun_times[#r.xrun_times + 1] = string.format("%.1f", util.time() - t_start)
    end
    local cpu = _norns.audio_get_cpu_load()
    r.cpu_total, r.cpu_n = r.cpu_total + cpu, r.cpu_n + 1
    if cpu > r.cpu_max then r.cpu_max = cpu end
    local mem = collectgarbage("count")
    if mem > r.mem_max then r.mem_max = mem end
  end
  clock.transport.stop()
  debug.setupvalue(clocked_seq, seq_idx, orig_seqrun)

  local lines = {
    string.format("=== stress %s (%s) started %s, %ds @ %.0f bpm ===", LABEL, LEVEL, start_wall, SECONDS, clock.get_tempo()),
    string.format("seqrun: %d calls, avg %.3f ms, p99 %.1f ms, p99.9 %.1f ms, max %.3f ms, over %.3f ms budget: %d",
      r.calls, r.total / math.max(1, r.calls) * 1000, pct(0.99), pct(0.999), r.max * 1000, budget * 1000, r.over),
    string.format("tick lateness: avg %.3f ms, max %.3f ms", r.late_total / math.max(1, r.calls) * 1000, r.late_max * 1000),
    string.format("audio: xruns %d%s, dsp load avg %.1f%%, max %.1f%%",
      r.xruns, #r.xrun_times > 0 and (" at s " .. table.concat(r.xrun_times, ",")) or "",
      r.cpu_total / math.max(1, r.cpu_n), r.cpu_max),
    string.format("lua memory max %.0f KB", r.mem_max),
    "STRESS DONE",
  }
  util.make_dir(norns.state.data)
  local f = io.open(norns.state.data .. "stress_" .. LABEL .. ".txt", "w")
  for _, l in ipairs(lines) do
    print(l)
    if f then f:write(l, "\n") end
  end
  if f then f:close() end
end)
