-- lfos
--
-- four LFOs for the CC slots of the MIDI tracks. A rate is a cycle length:
-- synced to the clock in note values and bars, or free in seconds.
-- The output is a 0-127 value around a centre.
--
-- modelled on norns' lib/lfo; replaces hnds (@justmat)

local number_of_outputs = 4
local TICK = 0.01 -- seconds between output updates

local shapes = { "sine", "square", "s+h", "triangle", "ramp up", "ramp down" }
local modes = { "sync", "free" }

-- synced cycle lengths, in beats
local sync_rates = {
  { "1/32", 1/8 }, { "1/16T", 1/6 }, { "1/16", 1/4 }, { "1/8T", 1/3 }, { "1/8", 1/2 },
  { "1/4T", 2/3 }, { "1/8.", 3/4 }, { "1/4", 1 }, { "1/4.", 3/2 }, { "1/2", 2 },
  { "1 bar", 4 }, { "2 bars", 8 }, { "3 bars", 12 }, { "4 bars", 16 }, { "6 bars", 24 },
  { "8 bars", 32 }, { "12 bars", 48 }, { "16 bars", 64 }, { "32 bars", 128 },
}
local DEFAULT_SYNC = 11 -- 1 bar

local lfo = {}
for i = 1, number_of_outputs do
  lfo[i] = {
    on = false,
    target = 1, -- index in lfo.targets, 1 = none
    shape = 1,
    sync = true,
    beats = sync_rates[DEFAULT_SYNC][2], -- synced cycle length
    period = 2, -- free cycle length in seconds
    center = 64,
    depth = 64,
    phase = 0, cycle = 0, time = 0, -- free running state
    rand = 0, rand_cycle = -1,
  }
end

-- redefine in user script ---------
lfo.targets = { "none" }

-- called when the value of a running LFO with a target changes
function lfo.output(i, target, value)
end
------------------------------------

-- synced LFOs follow the beats played since the sequencer was last reset, so
-- that their cycles line up with the pattern, and stand still while it is stopped
local running = false
local origin, held = 0, 0

local function song_beats()
  return running and clock.get_beats() - origin or held
end

function lfo.start()
  origin = clock.get_beats() - held
  running = true
end

function lfo.stop()
  held = song_beats()
  running = false
end

function lfo.reset()
  held = 0
  origin = clock.get_beats()
end

-- where LFO n is in its cycle (0-1), and how many cycles it has done
local function position(n)
  local l = lfo[n]
  if l.sync then
    local c = song_beats() / l.beats
    return c % 1, math.floor(c)
  end
  -- adding up the phase keeps the value from jumping when the rate changes
  local now = util.time()
  local phase = l.phase + (now - l.time) / l.period
  l.time = now
  l.cycle = l.cycle + math.floor(phase)
  l.phase = phase % 1
  return l.phase, l.cycle
end

local wave = {
  function(p) return math.sin(2 * math.pi * p) end, -- sine
  function(p) return p < 0.5 and 1 or -1 end, -- square
  function(p, l, cycle) -- s+h: a new random value every cycle
    if cycle ~= l.rand_cycle then
      l.rand_cycle = cycle
      l.rand = math.random() * 2 - 1
    end
    return l.rand
  end,
  function(p) -- triangle
    if p < 0.25 then return 4 * p end
    if p < 0.75 then return 2 - 4 * p end
    return 4 * p - 4
  end,
  function(p) return 2 * p - 1 end, -- ramp up
  function(p) return 1 - 2 * p end, -- ramp down
}

--- the current value of LFO n, 0-127
function lfo.value(n)
  local l = lfo[n]
  local p, cycle = position(n)
  return util.clamp(util.round(l.center + l.depth * wave[l.shape](p, l, cycle)), 0, 127)
end

local function format_seconds(param)
  local s = param:get()
  return string.format(s < 10 and "%.2f s" or "%.1f s", s)
end

local lfo_metro

function lfo.init()
  params:add_separator("takt_modulation", "MODULATION")
  for i = 1, number_of_outputs do
    local l = lfo[i]
    l.time = util.time()
    params:add_group("lfo " .. i, 8)
    -- modulation destination
    params:add_option(i .. "lfo_target", i .. " lfo target", lfo.targets, 1)
    params:set_action(i .. "lfo_target", function(value) l.target = value l.sent = nil end)
    -- lfo shape
    params:add_option(i .. "lfo_shape", i .. " lfo shape", shapes, 1)
    params:set_action(i .. "lfo_shape", function(value) l.shape = value end)
    -- lfo speed: the length of a cycle, on the clock or in seconds
    params:add_option(i .. "lfo_mode", i .. " lfo mode", modes, 1)
    params:set_action(i .. "lfo_mode", function(value)
      l.sync = value == 1
      l.time = util.time()
      if l.sync then
        params:show(i .. "lfo_sync")
        params:hide(i .. "lfo_free")
      else
        params:hide(i .. "lfo_sync")
        params:show(i .. "lfo_free")
      end
      _menu.rebuild_params()
    end)
    local names = {}
    for k, rate in ipairs(sync_rates) do names[k] = rate[1] end
    params:add_option(i .. "lfo_sync", i .. " lfo cycle", names, DEFAULT_SYNC)
    params:set_action(i .. "lfo_sync", function(value) l.beats = sync_rates[value][2] end)
    params:add_control(i .. "lfo_free", i .. " lfo cycle",
      controlspec.new(0.05, 300, "exp", 0, 2, "s", 1 / 200), format_seconds)
    params:set_action(i .. "lfo_free", function(value)
      position(i) -- the phase up to now ran at the old rate
      l.period = value
    end)
    params:hide(i .. "lfo_free")
    -- the value the lfo moves around, and how far to each side
    params:add_number(i .. "lfo_center", i .. " lfo center", 0, 127, 64)
    params:set_action(i .. "lfo_center", function(value) l.center = value end)
    params:add_number(i .. "lfo_amount", i .. " lfo depth", 0, 127, 64)
    params:set_action(i .. "lfo_amount", function(value) l.depth = value end)
    -- lfo on/off
    params:add_option(i .. "lfo", i .. " lfo", { "off", "on" }, 1)
    params:set_action(i .. "lfo", function(value) l.on = value == 2 l.sent = nil end)
  end

  lfo_metro = metro.init()
  lfo_metro.time = TICK
  lfo_metro.count = -1
  lfo_metro.event = function()
    for i = 1, number_of_outputs do
      local l = lfo[i]
      if l.on and l.target > 1 then
        local value = lfo.value(i)
        if value ~= l.sent then
          l.sent = value
          lfo.output(i, l.target, value)
        end
      end
    end
  end
  lfo_metro:start()
end

-- stop the metro before the script's params go away. A tick that is already
-- queued still arrives after that, so it gets nothing to run
function lfo.cleanup()
  if lfo_metro then
    lfo_metro:stop()
    lfo_metro.event = nil
  end
end


return lfo
