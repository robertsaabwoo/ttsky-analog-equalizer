#!/bin/bash
# run_r1t.sh [corner ...] -- run the R1T trim decks one at a time (CLAUDE.md section 1)
cd "$(dirname "$0")/decks"
cs=("$@"); [ ${#cs[@]} -eq 0 ] && cs=($(ls *.spice | sed 's/\.spice$//'))
for c in "${cs[@]}"; do
  [ -f "$c.log" ] && grep -q "exit rc=0" "$c.log" && continue
  while pgrep -x ngspice >/dev/null; do sleep 10; done
  ../../../safe_ngspice.sh $c.spice $c.log 2500 1800 1500 >/dev/null
  echo "$(date +%T) $c $(tail -1 $c.log)"
done
../r1t_analyze.py *.log
