#!/bin/bash
# safe_ngspice.sh — run ngspice with hard resource guards so a runaway sim
# self-aborts instead of taking the (weak) VM down.
#
#   usage: safe_ngspice.sh <spicefile> <logfile> [mem_mb] [timeout_s] [floor_mb]
#     mem_mb    per-process virtual-memory cap (ulimit -v). default 3000
#     timeout_s wall-clock kill.                          default 900
#     floor_mb  watchdog kills ngspice if system MemAvailable drops below this.
#                                                          default 1200
#
# Layers of protection:
#   1. ulimit -v : kernel refuses allocations past the cap -> ngspice aborts
#      with an alloc error rather than exhausting RAM and OOM-crashing the host.
#   2. timeout --signal=KILL : bounds wall time (a stuck/pathological solve).
#   3. memory watchdog : polls /proc/meminfo; if free RAM gets low it SIGKILLs
#      ngspice (belt-and-suspenders with the ulimit).
#   4. nice -n 15 : keeps the box responsive.
set -u
SPICE="$1"; LOG="$2"; MEMMB="${3:-3000}"; TMO="${4:-900}"; FLOOR="${5:-1200}"

echo "[safe_ngspice] $SPICE  memcap=${MEMMB}MB timeout=${TMO}s floor=${FLOOR}MB" > "$LOG"
(
  ulimit -v $((MEMMB*1024)) 2>/dev/null
  exec timeout --signal=KILL "${TMO}" nice -n 15 ngspice -b "$SPICE"
) >> "$LOG" 2>&1 &
NGPID=$!

while kill -0 "$NGPID" 2>/dev/null; do
  AVAIL=$(awk '/MemAvailable/{print int($2/1024)}' /proc/meminfo)
  if [ "${AVAIL:-99999}" -lt "$FLOOR" ]; then
    echo "[safe_ngspice] WATCHDOG: MemAvailable ${AVAIL}MB < ${FLOOR}MB -> KILL" >> "$LOG"
    pkill -KILL -P "$NGPID" 2>/dev/null
    kill -KILL "$NGPID" 2>/dev/null
    break
  fi
  sleep 3
done
wait "$NGPID" 2>/dev/null
RC=$?
echo "[safe_ngspice] exit rc=$RC" >> "$LOG"
exit $RC
