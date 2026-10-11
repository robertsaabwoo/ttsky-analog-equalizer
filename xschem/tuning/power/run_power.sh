#!/bin/bash
# run_power.sh -- regenerate and run the power-analysis decks, ONE AT A TIME,
# each under safe_ngspice.sh, then print the summary.
#
#   ./run_power.sh                 # all decks (P0 is ~2-6 min, the rest seconds)
#   ./run_power.sh P1 P2           # just these
#   CLOAD=100f ./run_power.sh P0   # different output-pin load
#
# Never two ngspice at once (../../../CLAUDE.md §1). Results land in results/,
# which is gitignored; the numbers that matter are recorded in POWER.md.
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
SAFE="$HERE/../safe_ngspice.sh"
cd "$HERE"

./gen_power.py --cload "${CLOAD:-50f}" --tstop "${TSTOP:-1000}"
mkdir -p results
DECKS=("$@"); [ ${#DECKS[@]} -eq 0 ] && DECKS=(P1 P2 P3 P0)

for d in "${DECKS[@]}"; do
  deck=$(ls decks/${d}_*.spice)
  name=$(basename "$deck" .spice)
  case "$d" in P0) MEM=2500; TMO=1800 ;; *) MEM=1500; TMO=600 ;; esac
  echo "run   $name  (memcap ${MEM} MB, timeout ${TMO} s)"
  t0=$(date +%s)
  # cwd = results/, so wrdata output lands next to the logs
  (cd results && "$SAFE" "../$deck" "$name.log" "$MEM" "$TMO" 1500)
  echo "      $(tail -1 results/$name.log)  $(( $(date +%s) - t0 )) s"
done

./collect_power.py
