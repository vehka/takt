#!/usr/bin/env bash
# Stress takt on desktop norns, restarting norns before every run so no run
# inherits a backed-up MIDI output or other state from the previous one.
#
# Needs: norns-desktop on PATH, ~/dust/code/takt -> $TAKT_WT (a takt worktree this
# script may check out revisions in), the venv from README, samples from gen_samples.py.
#   SPECS="new:upstream/04-docs base:f5d0cc1" LEVELS="normal heavy" SECS=30 ./run_desktop.sh
T=$(cd "$(dirname "$0")" && pwd)
TAKT_WT=${TAKT_WT:-$(readlink -f ~/dust/code/takt)}
SAMPLES=${SAMPLES:-$T/samples}
PY=${PY:-$T/venv/bin/python}
SECS=${SECS:-30}
repl() { "$PY" "$T/nrepl.py" "$@" >/dev/null; }

stop_norns() {
  pkill -f 'ws-wrapper ws://0.0.0.0:5555' 2>/dev/null
  for i in $(seq 30); do pgrep -f 'ws-wrapper ws://0.0.0.0:555[56]' >/dev/null || return 0; sleep 1; done
  pkill -9 -f 'ws-wrapper ws://0.0.0.0:555' 2>/dev/null; pkill -9 -x sclang 2>/dev/null; sleep 2
}
start_norns() {
  setsid norns-desktop >/tmp/norns-desktop.out 2>&1 </dev/null &
  until grep -q 'starting norns' /tmp/norns-desktop.out 2>/dev/null; do sleep 1; done
  sleep 15
}

for spec in ${SPECS:-new:upstream/04-docs base:f5d0cc1}; do
  name=${spec%%:*}; rev=${spec#*:}
  git -C "$TAKT_WT" checkout -q --detach "$rev"
  for level in ${LEVELS:-normal heavy}; do
    label="fresh_${name}_${level}"
    stop_norns; start_norns
    repl --wait 12 'norns.script.load("code/takt/takt.lua")'
    L=$(wc -l < ~/norns.log)
    repl --wait 1 "STRESS_SAMPLE_DIR='$SAMPLES/'; STRESS_LEVEL='$level'; STRESS_SECONDS=$SECS; STRESS_LABEL='$label'; dofile('$T/stress.lua')"
    timeout $((SECS + 60)) bash -c "until tail -n +$L ~/norns.log | grep -q 'STRESS DONE'; do sleep 1; done"
    tail -n +$((L + 1)) ~/norns.log | sed -n '/=== stress/,/STRESS DONE/p' | grep -v 'STRESS DONE'
    echo
  done
done
