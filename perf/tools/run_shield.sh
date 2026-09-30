#!/usr/bin/env bash
# Stress test takt on the norns shield: upstream (base) vs the rebuilt stack (new).
# Replaces ~/dust/code/takt on the shield and restarts norns (sclang must compile
# the Timber_Takt engine). Results stay on the device in ~/dust/data/takt/ and are
# copied to shield_results/ here.
# Built for flaky wifi: every remote step retries, runs with results are skipped,
# and a run whose result never shows up is started again. Re-run freely.
set -u
#   BASE=f5d0cc1 NEW=upstream/04-docs SECS=60 ./run_shield.sh
T=$(cd "$(dirname "$0")" && pwd)
REPO=${REPO:-$(git -C "$T" rev-parse --show-toplevel)}
IP=${IP:-10.0.0.138}
HOST=we@$IP
SECS=${SECS:-60}
BASE=${BASE:-f5d0cc1}
NEW=${NEW:-upstream/04-docs}
PY=${PY:-$T/venv/bin/python}
TMP=$(mktemp -d)
OUT=${OUT:-$T/../results/raw/$(date +%F)-shield}
mkdir -p "$OUT"

retry() { # retry <tries> <cmd...>
  local n=$1; shift
  for ((i = 1; i <= n; i++)); do
    "$@" && return 0
    echo "  (attempt $i failed, retrying)" >&2; sleep 5
  done
  return 1
}
rssh() { ssh -o ConnectTimeout=10 -o ServerAliveInterval=5 -o ServerAliveCountMax=3 -o LogLevel=ERROR $HOST "$@"; }
repl() { "$PY" "$T/nrepl.py" --host $IP "$@" >/dev/null 2>&1; }

git -C "$REPO" archive --prefix=takt/ "$BASE" | gzip > "$TMP/takt_base.tgz"
git -C "$REPO" archive --prefix=takt/ "$NEW" | gzip > "$TMP/takt_new.tgz"
echo "base=$(git -C "$REPO" rev-parse --short "$BASE") new=$(git -C "$REPO" rev-parse --short "$NEW")" > "$OUT/revisions.txt"
retry 10 scp -q -o ConnectTimeout=10 -o LogLevel=ERROR "$TMP/takt_base.tgz" "$TMP/takt_new.tgz" "$T/stress.lua" $HOST:/home/we/ || exit 1

for name in new base; do
  todo=0
  for level in normal heavy; do [ -s "$OUT/shield_${name}_${level}.txt" ] || todo=1; done
  [ $todo = 1 ] || { echo "[$name] done already, skipping"; continue; }

  want="$name-$(md5sum < "$TMP/takt_$name.tgz" | cut -c1-8)"
  deployed=$(retry 10 rssh 'cat ~/takt_deployed 2>/dev/null; true')
  if [ "$deployed" != "$want" ]; then
    retry 10 rssh "cd ~/dust/code && rm -rf takt && tar xzf ~/takt_$name.tgz && echo $want > ~/takt_deployed && sudo systemctl restart norns-sclang norns-main" || exit 1
    echo "[$name] deployed, norns restarting..."; sleep 45
  fi

  for level in normal heavy; do
    label="shield_${name}_${level}"
    [ -s "$OUT/$label.txt" ] && { echo "[$name/$level] have result, skipping"; continue; }
    for run in 1 2 3; do
      retry 10 rssh "rm -f ~/dust/data/takt/stress_$label.txt" || exit 1
      retry 10 repl --wait 25 'norns.script.load("code/takt/takt.lua")' || exit 1
      start=$(retry 10 rssh 'date "+%Y-%m-%d %H:%M:%S"')
      retry 10 repl --wait 1 "STRESS_LEVEL='$level'; STRESS_SECONDS=$SECS; STRESS_LABEL='$label'; dofile('/home/we/stress.lua')" || exit 1
      echo "[$name/$level] running ${SECS}s (attempt $run)..."; sleep $((SECS + 10))
      for try in $(seq 12); do
        rssh "cat ~/dust/data/takt/stress_$label.txt" > "$OUT/$label.txt.tmp" 2>/dev/null \
          && grep -q 'STRESS DONE' "$OUT/$label.txt.tmp" && break
        sleep 10
      done
      if grep -q 'STRESS DONE' "$OUT/$label.txt.tmp" 2>/dev/null; then
        mv "$OUT/$label.txt.tmp" "$OUT/$label.txt"
        retry 10 rssh "journalctl -u norns-jack --since '$start' --no-pager | grep -i xrun; true" > "$OUT/${label}_journal.txt"
        cat "$OUT/$label.txt"
        echo "journal xrun lines: $(grep -c . "$OUT/${label}_journal.txt")"; echo
        break
      fi
      echo "[$name/$level] no result, starting the run again"
    done
  done
done
echo "SHIELD DONE"
