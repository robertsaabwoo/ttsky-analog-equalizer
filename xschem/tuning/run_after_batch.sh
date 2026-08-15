#!/bin/bash
# Waits for the C25 batch to finish, then runs the cheap charge-pump mismatch
# measurement. Exists so the two never overlap — ../../CLAUDE.md forbids two
# ngspice at once, and cp_mismatch.spice is seconds of work that would
# otherwise have to wait for a human.
set -u
cd "$(dirname "$0")"
while pgrep -x ngspice >/dev/null 2>&1 || pgrep -f run_c25.sh >/dev/null 2>&1; do
  sleep 20
done
echo "[after_batch] batch clear at $(date -Is); running cp_mismatch"
./safe_ngspice.sh cp_mismatch.spice cp_mismatch.log 2000 600 1200
{
  echo ""
  echo "---------- E : charge-pump up/down mismatch (C25 hypothesis test) ----------"
  echo "finished=$(date -Is)"
  grep -iE "^icp_" cp_mismatch.log
} >> c25_summary.txt
echo "[after_batch] done"
