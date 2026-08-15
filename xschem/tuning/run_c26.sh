#!/bin/bash
# Waits for BOTH the C25 batch and the queued cp_mismatch run to clear, then
# runs the C26 jitter measurement and parses it.
#
# A separate script rather than an edit to run_after_batch.sh, because that one
# is already executing and bash reads scripts incrementally -- editing a running
# script corrupts it.
set -u
cd "$(dirname "$0")"
while pgrep -x ngspice >/dev/null 2>&1 \
   || pgrep -f run_c25.sh >/dev/null 2>&1 \
   || pgrep -f run_after_batch.sh >/dev/null 2>&1; do
  sleep 20
done
echo "[c26] clear at $(date -Is); starting jitter run"
./safe_ngspice.sh e2e_c26_jitter.spice e2e_c26_jitter.log 3000 5400 1200
RC=$?
{
  echo ""
  echo "---------- C26 : jitter through the CTLE+CDR chain ----------"
  echo "rc=$RC  finished=$(date -Is)"
  grep -iE "^(vctrl_w3|vctrl_w4|vctrl_ripp|e1200|e1800|e1740)" e2e_c26_jitter.log
  grep -iE "^f600_mhz|^f60_mhz" e2e_c26_jitter.log
  if [ -f c26_rclk.raw ]; then
    echo "--- edge analysis ---"
    python3 jitter_parse.py c26_rclk.raw 1.665 1800 2>&1
  else
    echo "no c26_rclk.raw produced"
  fi
} >> c25_summary.txt
echo "[c26] done rc=$RC"
