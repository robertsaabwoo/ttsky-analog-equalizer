#!/bin/bash
# verify.sh -- netlist the generated schematics with xschem and compare every
# cell with reference.spice (the simulated netlists) in netgen.
#   cd xschem/cml && ./verify.sh
# Exit status 0 only if xschem found every symbol and every cell matches.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
XS="$(dirname "$HERE")"
OUT="$HERE/.verify"
mkdir -p "$OUT"
export PDK_ROOT=/home/ttuser/pdk
# from xschem/, with PWD stamped (docs/SIMULATION_TRAPS.md section 9)
( cd "$XS" && PWD="$XS" xschem -n -s -x -q --rcfile xschemrc -o "$OUT" cml/cml_lvs.sch ) > "$OUT/xschem.log" 2>&1
rc=$?
if [ $rc -ne 0 ] || grep -qi "not found" "$OUT/xschem.log"; then
  echo "xschem netlisting failed (rc=$rc) or missed a symbol:"; cat "$OUT/xschem.log"; exit 1
fi
NET="$OUT/cml_lvs.spice"
# reference + the frozen cells it instantiates, from the same xschem netlist
cp "$HERE/reference.spice" "$OUT/ref_full.spice"
cat "$XS/tuning/cml/.netlists/frozen.inc" >> "$OUT/ref_full.spice"
fail=0
for cell in cml_latch cml_dff cml2cmos cml2cmos_w2 cx_xor cml_pd_cx3w cml_bias cml_clkbuf cp_bias \
            cml_loop_filter ring_core CDR_cml CDR_cml_bg ctle_cdr_rx_cml ctle_cdr_rx_cml_bg; do
  netgen -batch lvs "$NET $cell" "$OUT/ref_full.spice $cell" \
         "$PDK_ROOT/sky130A/libs.tech/netgen/sky130A_setup.tcl" "$OUT/$cell.out" > "$OUT/$cell.log" 2>&1
  # "match uniquely" is topology only: netgen reports wrong W/L/mult on a
  # separate "Property errors were found" line, with the topology still matching
  if grep -q "Circuits match uniquely" "$OUT/$cell.out" && ! grep -q "Property errors" "$OUT/$cell.out"; then
    printf "%-20s match (topology and properties)\n" "$cell"
  else
    printf "%-20s MISMATCH (see .verify/%s.out)\n" "$cell" "$cell"; fail=1
  fi
done
exit $fail
