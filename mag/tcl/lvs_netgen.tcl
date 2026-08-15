set layout [readnet spice $project.lvs.spice]
set source [readnet spice /dev/null]
readnet spice $::env(PDK_ROOT)/$::env(PDK)/libs.ref/sky130_fd_sc_hd/spice/sky130_fd_sc_hd.spice $source

# top level GL verilog
readnet verilog ../src/project.v $source

# add an GL verilog of any digital blocks:
# readnet verilog ../verilog/gl/your_design.v $source

# add any spice files of your analog blocks:
#
# ctle_cdr_rx is the whole receiver (CTLE + CDR + output inverter chains).
# src/project.v instantiates it as a blackbox; this netlist supplies its
# contents so netgen can check the layout all the way down to devices.
#
# Regenerate with (from xschem/, PDK_ROOT set):
#   xschem -n -s -x -q --rcfile ./xschemrc -o simulation ctle_cdr_rx_lvs.sch
# Note it is the _lvs wrapper that is netlisted, not ctle_cdr_rx.sch itself --
# netlisting the latter directly makes it the top and emits no .subckt.
readnet spice ../xschem/simulation/ctle_cdr_rx_lvs.spice $source

lvs "$layout $project" "$source $project" $::env(PDK_ROOT)/sky130A/libs.tech/netgen/sky130A_setup.tcl lvs.report -blackbox
