* cml_bias -- tail-current reference for the CML cells (option 2a, 2026-10-12)
* vbn replaces the vbias pin on every CML tail gate. Iref = (VDD - Vgs) / R_ref
* with R_ref in res_high_po, the CML load material, so the swing I x R_load is
* set by a resistor RATIO and VDD - Vgs: B1 measured +-8 % over process and
* temperature at fixed VDD (against -51 % / +66 % for the vbias-gate bias).
* Diode = 1/4 of a W=3 L=0.5 tail at the same current density (R_ref 4x the
* L=28 of B1): the reference branch draws ~13.5 uA for 54 uA per W=3 tail.
.subckt cml_bias VDD VSS vbn
XRr vbn VDD VSS sky130_fd_pr__res_high_po_0p69 L=112
XD vbn vbn VSS VSS sky130_fd_pr__nfet_01v8 W=0.75 L=0.5
* ~200 fF of MOS decoupling against tail kickback
XCd VSS vbn VSS VSS sky130_fd_pr__nfet_01v8 W=5 L=5
.ends
