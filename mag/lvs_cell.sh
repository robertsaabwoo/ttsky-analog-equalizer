#!/bin/bash
# lvs_cell.sh <cellname> — LVS ONE cell against its schematic.
#
#   ./lvs_cell.sh d_latch
#
# Why this exists: `make lvs` only checks the whole chip, which is useless while
# you are building. This extracts a single .mag and compares it against the same
# cell inside the xschem netlist, so you can verify each block the moment you
# finish drawing it instead of discovering twenty errors at the end.
#
# Requires PDK_ROOT and PDK to be set.
set -u
CELL="${1:?usage: ./lvs_cell.sh <cellname>}"
MAGIC_RC="${PDK_ROOT}/sky130A/libs.tech/magic/sky130A.magicrc"
SRC=../xschem/simulation/ctle_cdr_rx_lvs.spice

cd "$(dirname "$0")"

[ -f "$CELL.mag" ]  || { echo "no $CELL.mag here"; exit 1; }
[ -f "$SRC" ]       || { echo "no $SRC -- regenerate it, see LAYOUT_HANDOFF.md §3"; exit 1; }

echo "[lvs_cell] extracting $CELL"
magic -rcfile "$MAGIC_RC" -noconsole -dnull tcl/extract_for_lvs.tcl "$CELL" >/dev/null 2>&1
rm -f ./*.ext
[ -f "$CELL.lvs.spice" ] || { echo "extraction produced nothing"; exit 1; }

echo "[lvs_cell] comparing against the schematic's $CELL"
netgen -batch lvs "$CELL.lvs.spice $CELL" "$SRC $CELL" \
       "${PDK_ROOT}/sky130A/libs.tech/netgen/sky130A_setup.tcl" \
       "$CELL.lvs.report" -blackbox >/dev/null 2>&1

echo
grep -E "^Circuit .* contains|^  Class:|Final result|Cell pin lists" "$CELL.lvs.report" | head -30
echo
if grep -q "Circuits match uniquely" "$CELL.lvs.report"; then
  echo "  ==> $CELL MATCHES"
else
  echo "  ==> $CELL does NOT match. Full detail: mag/$CELL.lvs.report"
  echo "      (device count/class differences are listed above)"
fi
