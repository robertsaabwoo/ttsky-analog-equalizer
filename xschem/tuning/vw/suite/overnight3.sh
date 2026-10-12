#!/bin/bash
# overnight3.sh -- after overnight2.sh: R1 open-loop ring f(vctrl) at every corner,
# CML (option A loading) and frozen, one ngspice at a time (CLAUDE.md section 1).
cd "$(dirname "$0")"
SUM="$PWD/overnight_summary.txt"
log() { echo "[$(date '+%F %T')] $*" | tee -a "$SUM"; }
while pgrep -f overnight2.sh >/dev/null; do sleep 60; done
log "10. R1 open-loop ring f(vctrl), cml_full and frozen loading"
for d in cml_full frozen; do
  for deck in r1/$d/*.spice; do
    c=${deck%.spice}
    [ -f "$c.log" ] && grep -q "exit rc=0" "$c.log" && continue
    while pgrep -x ngspice >/dev/null; do sleep 10; done
    ( cd r1/$d && ../../../../safe_ngspice.sh "$(basename "$deck")" "$(basename "$c").log" 2500 1800 1500 >/dev/null )
  done
  ./r1_analyze.py r1/$d >> "$SUM" 2>&1
done
log "done R1"
