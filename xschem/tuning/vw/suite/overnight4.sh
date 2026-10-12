#!/bin/bash
# overnight4.sh -- after overnight3.sh:
#  a) rerun the R1 deck that ran with the broken measure syntax
#  b) the frozen decks abort ("timestep too small") on the PRBS edge at 1.067 us
#     at 9 of 13 corners, even with 10 ohm on vbias; try solver options on tt_ll
#     (1.3 us runs), and if one passes, rerun the failed frozen corners with it.
# One ngspice at a time (CLAUDE.md section 1).
cd "$(dirname "$0")"
SUM="$PWD/overnight_summary.txt"
log() { echo "[$(date '+%F %T')] $*" | tee -a "$SUM"; }
wait_free() { while pgrep -x ngspice >/dev/null; do sleep 10; done; }
while pgrep -f overnight3.sh >/dev/null; do sleep 60; done
log "11. R1 rerun of cml_full/ff_typ_27C (broken measure syntax in the first run)"
mv r1/cml_full/ff_typ_27C_1p80V.log r1/cml_full/ff_typ_27C_1p80V.log.bad 2>/dev/null
wait_free
( cd r1/cml_full && ../../../../safe_ngspice.sh ff_typ_27C_1p80V.spice ff_typ_27C_1p80V.log 2500 1800 1500 >/dev/null )
./r1_analyze.py r1/cml_full >> "$SUM" 2>&1
log "12. frozen convergence: solver options on tt_ll to 1.3 us"
mkdir -p conv
BASE='.options method=gear reltol=0.001 abstol=1e-12'
declare -A OPT=(
  [rshunt]="$BASE rshunt=1e12"
  [reltol]=".options method=gear reltol=0.002 abstol=1e-12 itl4=100"
  [both]=".options method=gear reltol=0.002 abstol=1e-12 itl4=100 rshunt=1e12"
)
WIN=""
for k in rshunt reltol both; do
  sed -e "s/^\.options method=gear reltol=0.001 abstol=1e-12\s*$/${OPT[$k]}/" -e "s/tran 20p 3000n/tran 20p 1300n/" \
      frozen/tt_ll_27C_1p80V.spice > conv/$k.spice
  grep -q "^${OPT[$k]}" conv/$k.spice || { log "  $k: option substitution failed"; continue; }
  wait_free
  ( cd conv && ../../../safe_ngspice.sh $k.spice $k.log 2500 900 1500 >/dev/null )
  if grep -q "Timestep too small" conv/$k.log; then
    log "  $k: still aborts ($(grep -o 'time = [^,]*' conv/$k.log | head -1))"
  else
    log "  $k: passes the 1.067 us edge"; WIN=$k; break
  fi
done
rm -f conv/*.raw conv/*.dat
[ -z "$WIN" ] && { log "no option fixed it; frozen corners left as they are"; exit 0; }
log "13. frozen: rerun the aborted corners with '$WIN'"
mkdir -p frozen/aborted2
for c in $(grep -l "Timestep too small" frozen/*.log | xargs -n1 basename | sed 's/\.log$//'); do
  mv frozen/$c.log frozen/$c.dat.gz frozen/${c}_chain.raw.gz frozen/aborted2/ 2>/dev/null
  sed -i "s/^\.options method=gear reltol=0.001 abstol=1e-12\s*$/${OPT[$WIN]}/" frozen/$c.spice
done
./run_suite.sh frozen >> "$SUM" 2>&1
log "done overnight4"
