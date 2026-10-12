#!/bin/bash
# run_b1.sh -- run the B1 bias-scheme decks one at a time (never alongside
# another ngspice: CLAUDE.md section 1), then analyse.
set -eu
cd "$(dirname "$0")"
while pgrep -x ngspice >/dev/null; do sleep 5; done
for f in B1_*.spice; do
  ../../safe_ngspice.sh "$f" "${f%.spice}.log" 1000 120 1500 >/dev/null
done
./b1_analyze.py
