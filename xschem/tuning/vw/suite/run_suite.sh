#!/bin/bash
# run_suite.sh <design> [corner-tag ...] -- run the suite decks one at a time
# (never alongside another ngspice: CLAUDE.md section 1), skipping corners that
# already have results, then print the table. ~11 min per CML corner, ~21 per
# frozen corner, on this VM.
set -u
cd "$(dirname "$0")/$1"
shift
decks=("$@")
[ ${#decks[@]} -eq 0 ] && decks=($(ls *.spice | sed 's/\.spice$//'))
for c in "${decks[@]}"; do
  [ -f "$c.dat.gz" ] && [ -f "${c}_chain.raw.gz" ] && continue
  while pgrep -x ngspice >/dev/null; do sleep 10; done
  t0=$(date +%s)
  ../../../safe_ngspice.sh "$c.spice" "$c.log" 2500 3600 1500 >/dev/null
  echo "$(basename "$PWD")/$c: $(tail -1 "$c.log") $(( $(date +%s) - t0 )) s"
  # ~45 MB per corner uncompressed; a full disk killed the 2026-10-12 queue
  gzip -f1 "$c.dat" "${c}_chain.raw" 2>/dev/null
done
cd .. && ./suite_analyze.py "$(basename "$OLDPWD")"
