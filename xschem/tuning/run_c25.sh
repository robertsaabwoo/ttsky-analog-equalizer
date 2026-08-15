#!/bin/bash
# run_c25.sh — the C25 end-to-end batch, run unattended and STRICTLY SEQUENTIAL.
#
#   ./run_c25.sh            # run all four
#   ./run_c25.sh b d        # run only the named decks
#
# Every run goes through safe_ngspice.sh (ulimit -v, wall-clock kill, /proc
# memory watchdog, nice) — see ../../CLAUDE.md for why that is not optional on
# this VM. Two ngspice must NEVER run at once, which is why this is a plain
# sequential loop and not a parallel fan-out.
#
# Results land in c25_summary.txt as each run finishes, so a partially
# completed batch is still useful.
set -u
cd "$(dirname "$0")"

MEM=3000        # MB, ulimit -v per process
TMO=5400        # s per run. C24's 2000 ns PRBS took 1451 s; 3000 ns should be
                # ~2200-2600 s, so this is generous on purpose — a run killed at
                # 99% completes zero `meas` statements and is a total loss.
FLOOR=1200      # MB of MemAvailable below which the watchdog kills ngspice

SUMMARY=c25_summary.txt

declare -A DECK=(
  [a]=e2e_c25a_0101   [b]=e2e_c25b_prbs
  [c]=e2e_c25c_pol    [d]=e2e_c25d_sens
)
declare -A WHAT=(
  [a]="0101 control, 3 us (A/B baseline for C24)"
  [b]="PRBS7, 3 us  <-- THE MERGE GATE"
  [c]="PRBS7, opposite data polarity (C23 gap 2)"
  [d]="PRBS7, 100 mVpp input sensitivity (C23 gap 5)"
)

# order matters: the cheap control first so the batch proves itself early,
# then the merge gate, then the two nice-to-haves.
ORDER=(a b c d)
[ $# -gt 0 ] && ORDER=("$@")

{
  echo "=========================================================="
  echo "C25 batch started $(date -Is)"
  echo "  host free RAM: $(awk '/MemAvailable/{print int($2/1024)"MB"}' /proc/meminfo)"
  echo "  order: ${ORDER[*]}"
  echo "=========================================================="
} >> "$SUMMARY"

for k in "${ORDER[@]}"; do
  d="${DECK[$k]:-}"
  if [ -z "$d" ]; then echo "unknown deck '$k'" >&2; continue; fi

  echo "[run_c25] === $k: ${WHAT[$k]}"
  echo "[run_c25]     deck=$d.spice  started $(date -Is)"
  T0=$SECONDS

  ./safe_ngspice.sh "$d.spice" "$d.log" "$MEM" "$TMO" "$FLOOR"
  RC=$?
  DT=$((SECONDS - T0))

  {
    echo ""
    echo "---------- $k : ${WHAT[$k]} ----------"
    echo "deck=$d.spice  rc=$RC  wall=${DT}s  finished=$(date -Is)"
    if grep -q "^vctrl_w4" "$d.log" 2>/dev/null; then
      # the measurements, in the order that makes the drift readable
      grep -hE "^(vctrl_w[1-4]|vctrl_ripp|t_release|rclkp_swing|rclkm_swing|rclkp_avg|rclkm_avg|rsum_avg|rsum_pp|cin_swing|ctle_swing)" "$d.log"
      grep -hiE "^(fp_late_mhz|fm_late_mhz|fp_early_mhz)" "$d.log"
      # the one-line verdict: has vctrl stopped moving between the last two windows?
      awk '
        /^vctrl_w3/ {w3=$3} /^vctrl_w4/ {w4=$3}
        END {
          if (w3 != "" && w4 != "") {
            d = w4 - w3; if (d < 0) d = -d
            printf "VERDICT: |vctrl_w4 - vctrl_w3| = %.1f mV  -> %s\n", d*1000,
                   (d < 0.005 ? "SETTLED (<5 mV between 2.45 and 2.85 us)" \
                              : "STILL MOVING")
          }
        }' "$d.log"
    else
      echo "NO MEASUREMENTS — run did not reach the .control block."
      echo "last lines of $d.log:"
      tail -5 "$d.log" | sed 's/^/    | /'
    fi
  } >> "$SUMMARY"

  echo "[run_c25]     done rc=$RC in ${DT}s"
done

{
  echo ""
  echo "C25 batch finished $(date -Is)"
  echo "=========================================================="
} >> "$SUMMARY"
echo "[run_c25] batch complete — see $SUMMARY"
