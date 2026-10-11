#!/bin/bash
# run_cml.sh -- regenerate and run the all-CML experiment decks, ONE AT A TIME,
# each under safe_ngspice.sh, then print the closed-loop comparison.
#
#   ./run_cml.sh                       # C0 C1 C2_ring_none C2_ring_dai C3_chain_dai
#   ./run_cml.sh C3_chain_dai          # just the closed loop (~3.5 min)
#   VTAIL=0.8 ./run_cml.sh C3_chain_dai
#
# C3 compares against ../power/results/P0_chain.log -- run ../power/run_power.sh P0
# first if that log does not exist. Never two ngspice at once (CLAUDE.md §1).
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
SAFE="$HERE/../safe_ngspice.sh"
cd "$HERE"

./gen_cml.py --variant dai --vtail "${VTAIL:-0.85}"
mkdir -p results
DECKS=("$@")
[ ${#DECKS[@]} -eq 0 ] && DECKS=(C0_size C1_pd C2_ring_none C2_ring_dai C3_chain_dai C4_jitter_dai)

for name in "${DECKS[@]}"; do
  echo "run   $name"
  t0=$(date +%s)
  TMO=1800; [[ "$name" == C4_* ]] && TMO=2700   # the 6 us run takes ~20 min
  (cd results && "$SAFE" "../decks/$name.spice" "$name.log" 2500 "$TMO" 1500)
  echo "      $(tail -1 results/$name.log)  $(( $(date +%s) - t0 )) s"
done

if [ -f results/C3_chain_dai.log ] && [ -f ../power/results/P0_chain.log ]; then
  ./collect_cml.py dai
fi
