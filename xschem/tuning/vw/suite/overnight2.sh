#!/bin/bash
# overnight2.sh -- the queue after the 2026-10-12 05:55 disk-full stop (option A's
# 13 corners had finished; everything after failed in 3 s). Results are gzipped as
# they land. Strictly one ngspice at a time (CLAUDE.md section 1).
#   nohup setsid ./overnight2.sh > overnight2.out 2>&1 &
cd "$(dirname "$0")"
SUM="$PWD/overnight_summary.txt"
VW="$(dirname "$PWD")"
log() { echo "[$(date '+%F %T')] $*" | tee -a "$SUM"; }
wait_free() { while pgrep -x ngspice >/dev/null; do sleep 15; done; }
space() { [ "$(df -m --output=avail / | tail -1)" -gt 300 ] || { log "STOP: under 300 MB free"; exit 1; }; }

log "restart after disk-full; $(df -h --output=avail / | tail -1) free"
log "5. frozen at option A's non-locking corners (is it the CML design or the ring?)"
space; ./run_suite.sh frozen tt_ll_27C_1p80V ss_typ_m40C_1p80V tt_hh_27C_1p80V >> "$SUM" 2>&1
log "6. option A tt/-40C rerun (first run truncated by the full disk)"
space; ./run_suite.sh cml_full tt_typ_m40C_1p80V >> "$SUM" 2>&1
log "7. option B (cml_buf: pump on tiny_pll_bias_gen), 13 corners"
space; ./run_suite.sh cml_buf >> "$SUM" 2>&1
log "8. CID stress, both options"
for d in CID_full CID_buf; do
  space
  if [ ! -f "$VW/${d}_chain.raw.gz" ]; then
    wait_free
    ( cd "$VW" && ../safe_ngspice.sh decks/$d.spice $d.log 2500 2700 1500 >/dev/null )
  fi
  echo "== $d" >> "$SUM"
  ( cd "$VW" && python3 cid_analyze.py ${d}_chain.raw $d.dat cid_layout.txt && gzip -f1 ${d}_chain.raw $d.dat ) >> "$SUM" 2>&1
done
log "9. frozen, remaining corners"
space; ./run_suite.sh frozen >> "$SUM" 2>&1
log "done"
