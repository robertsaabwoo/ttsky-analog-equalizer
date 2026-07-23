#!/bin/bash
# run_pvt.sh -- run the generated PVT decks ONE AT A TIME under safe_ngspice.sh.
#
#   ./run_pvt.sh T0            # cheap: VCO tuning range      (~14 runs)
#   ./run_pvt.sh T1            # cheap: precharge cell alone  (~45 runs)
#   ./run_pvt.sh T2            # HEAVY: full CDR loop         (~7 runs, ~20 min each)
#   ./run_pvt.sh T1 --budget 1800   # stop starting new runs after 30 min
#   ./run_pvt.sh T2 --only T2_bad_ss_typ_125C_1p80
#
# Design rules for this weak VM (7.8 GB / 4 CPU):
#   * strictly sequential -- never two ngspice at once
#   * every run wrapped in safe_ngspice.sh (ulimit -v + timeout + mem watchdog)
#   * RESUMABLE: a deck whose log already ends in "exit rc=" is skipped, so an
#     interrupted T2 session can simply be re-invoked
#   * a free-RAM floor is checked BEFORE each launch, not just during
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
SAFE="$HERE/../safe_ngspice.sh"
DECKS="$HERE/decks"
RESULTS="$HERE/results"

TIER="${1:-}"
[ -z "$TIER" ] && { echo "usage: $0 <T0|T1|T2|ALL> [--budget SEC] [--only NAME] [--force]"; exit 1; }
shift

BUDGET=0; ONLY=""; FORCE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --budget) BUDGET="$2"; shift 2 ;;
    --only)   ONLY="$2";   shift 2 ;;
    --force)  FORCE=1;     shift ;;
    *) echo "unknown arg: $1"; exit 1 ;;
  esac
done

# per-tier guard settings: memcap MB, timeout s, free-RAM floor MB
case "$TIER" in
  T0) MEM=1500; TMO=600;  FLOOR=1200; PAT="T0_" ;;
  T1) MEM=1500; TMO=600;  FLOOR=1200; PAT="T1_" ;;
  T2) MEM=2500; TMO=1800; FLOOR=1500; PAT="T2_" ;;
  ALL) MEM=2500; TMO=1800; FLOOR=1500; PAT="T" ;;
  *) echo "bad tier: $TIER"; exit 1 ;;
esac

mkdir -p "$RESULTS"
START=$(date +%s)
n=0; skipped=0; ran=0

for deck in "$DECKS"/${PAT}*.spice; do
  [ -e "$deck" ] || { echo "no decks match ${PAT}* -- run ./gen_pvt.py first"; exit 1; }
  name=$(basename "$deck" .spice)
  [ -n "$ONLY" ] && [ "$name" != "$ONLY" ] && continue
  n=$((n+1))
  log="$RESULTS/$name.log"

  # ---- resume: skip anything that already completed
  if [ "$FORCE" -eq 0 ] && [ -f "$log" ] && grep -q "exit rc=" "$log"; then
    skipped=$((skipped+1)); echo "skip  $name (already done)"; continue
  fi

  # ---- wall-clock budget: stop STARTING new runs (never kill a running one)
  if [ "$BUDGET" -gt 0 ]; then
    ELAPSED=$(( $(date +%s) - START ))
    if [ "$ELAPSED" -ge "$BUDGET" ]; then
      echo "budget ${BUDGET}s reached after ${ELAPSED}s -- stopping. Re-run to resume."
      break
    fi
  fi

  # ---- pre-flight RAM check (safe_ngspice guards during the run; this guards
  #      the decision to start one at all)
  AVAIL=$(awk '/MemAvailable/{print int($2/1024)}' /proc/meminfo)
  if [ "${AVAIL:-0}" -lt "$FLOOR" ]; then
    echo "ABORT: only ${AVAIL}MB free (< ${FLOOR}MB floor). Not starting $name."
    break
  fi

  echo "run   $name  (free ${AVAIL}MB, memcap ${MEM}MB, timeout ${TMO}s)"
  t0=$(date +%s)
  ( cd "$RESULTS" && "$SAFE" "$deck" "$log" "$MEM" "$TMO" "$FLOOR" ) >/dev/null 2>&1
  rc=$?
  echo "      rc=$rc  $(( $(date +%s) - t0 ))s"
  ran=$((ran+1))
  sleep 2   # let the box breathe between runs
done

echo
echo "tier $TIER: $ran run, $skipped skipped, $n matched"
echo "collect with:  ./collect_pvt.py $TIER"
