#!/bin/bash
# overnight.sh -- the whole remaining verification, strictly one ngspice at a time
# (CLAUDE.md section 1), most important first. Appends every result to
# overnight_summary.txt. Safe to re-run: finished corners are skipped.
#   nohup setsid ./overnight.sh > overnight.out 2>&1 &
cd "$(dirname "$0")"
SUM="$PWD/overnight_summary.txt"
VW="$(dirname "$PWD")"
log() { echo "[$(date '+%F %T')] $*" | tee -a "$SUM"; }
wait_free() { while pgrep -x ngspice >/dev/null; do sleep 15; done; }

log "start"
# do not start inside the gap between the S3_buf3u and S3_cp3u ablation runs
until grep -q "exit rc" "$VW/S3_cp3u.log" 2>/dev/null; do sleep 30; done
wait_free
log "1. option A (cml_full: pump on cp_bias), 13 corners"
./run_suite.sh cml_full >> "$SUM" 2>&1
log "2. CID stress, both options"
for d in CID_full CID_buf; do
  if [ ! -f "$VW/${d}_chain.raw" ]; then
    wait_free
    ( cd "$VW" && ../safe_ngspice.sh decks/$d.spice $d.log 2500 2700 1500 >/dev/null )
  fi
  echo "== $d" >> "$SUM"
  ( cd "$VW" && python3 cid_analyze.py ${d}_chain.raw $d.dat cid_layout.txt ) >> "$SUM" 2>&1
done
log "3. option B (cml_buf: pump on tiny_pll_bias_gen), 13 corners"
./run_suite.sh cml_buf >> "$SUM" 2>&1
log "4. frozen design, 13 corners (reference)"
./run_suite.sh frozen >> "$SUM" 2>&1
log "done"
