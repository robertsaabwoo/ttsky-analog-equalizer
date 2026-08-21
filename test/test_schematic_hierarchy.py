"""Structural checks on the frozen xschem hierarchy.

The design is frozen and netlist-verified (``xschem/STATUS.md``), and the
layout will be checked against it by LVS.  The cheap failure mode this guards
against is a *silent* one: xschem resolves symbols through
``XSCHEM_LIBRARY_PATH`` and, if a symbol cannot be found, it emits a truncated
netlist with no error at all -- which is documented in ``CLAUDE.md`` as a trap
that has already cost time on this project.  Moving, renaming or deleting a
``.sym`` therefore does not fail loudly; it fails quietly, in the netlist that
LVS trusts.

These tests re-walk the hierarchy from the chip top and assert that every
reference still resolves, that the expected blocks are still instantiated, and
that the macro's pin list still matches ``src/project.v``.  They need no PDK
and no xschem binary.
"""

import unittest

from ttcheck import (
    LVS_WRAPPER_SCH,
    REPO,
    TOP_SCH,
    XSCHEM,
    read,
    sch_child_symbols,
    sch_instances,
    sch_ports,
    sym_pins,
    verilog_modules,
    walk_hierarchy,
)

# The macro pin order, from xschem/simulation/ctle_cdr_rx_lvs.spice:
#   .subckt ctle_cdr_rx vinp vinm vbias clkout_p clkout_n VDPWR VGND
MACRO_PINS = ["vinp", "vinm", "vbias", "clkout_p", "clkout_n", "VDPWR", "VGND"]

# The 20 sub-cells reachable from the chip top (xschem/STATUS.md: "xschem/ now
# contains only the 22 cells reachable from the chip top" -- these 20 plus
# ctle_cdr_rx itself and its LVS wrapper).
EXPECTED_HIERARCHY = {
    "CTLE.sym",
    "CDR.sym",
    "inverter_chain.sym",
    "alexander_phase_detector.sym",
    "d_flip_flop.sym",
    "d_latch.sym",
    "robs_xor.sym",
    "ring_oscillator.sym",
    "ring_inverter.sym",
    "diff_amp_inv.sym",
    "inverter_buffer.sym",
    "single_inverter.sym",
    "vctrl_precharge.sym",
    "tiny_pll_charge_pump.sym",
    "tiny_pll_bias_gen.sym",
    "tiny_pll_bias_gen_res.sym",
    "tiny_pll_loop_filter.sym",
    "tiny_pll_loop_filter_cap1.sym",
    "tiny_pll_loop_filter_cap2.sym",
    "tiny_pll_loop_filter_res.sym",
}


class Hierarchy(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.resolved, cls.dangling = walk_hierarchy(TOP_SCH)

    def test_top_level_files_exist(self):
        for path in (TOP_SCH, LVS_WRAPPER_SCH, XSCHEM / "ctle_cdr_rx.sym"):
            self.assertTrue(path.is_file(), f"{path} is missing")

    def test_no_dangling_symbol_references(self):
        self.assertEqual(
            self.dangling, [],
            "symbol references that resolve in neither xschem/ nor "
            "xschem/attic/ -- xschem would netlist these silently",
        )

    def test_every_reachable_symbol_has_a_schematic(self):
        for symbol, path in sorted(self.resolved.items()):
            self.assertTrue(
                path.with_suffix(".sch").is_file(),
                f"{symbol} has no matching .sch: its contents would be empty "
                "in the netlist",
            )

    def test_hierarchy_is_exactly_the_expected_set(self):
        self.assertEqual(set(self.resolved), EXPECTED_HIERARCHY)

    def test_top_level_children(self):
        children = sch_child_symbols(TOP_SCH)
        self.assertEqual(
            sorted(children),
            ["CDR.sym", "CTLE.sym", "inverter_chain.sym", "inverter_chain.sym"],
            "the chip top level must be CTLE -> CDR -> two inverter chains; "
            "both clock phases are buffered so the ring oscillator stays "
            "symmetrically loaded (mag/LAYOUT_HANDOFF.md)",
        )

    def test_cdr_contains_the_whole_loop(self):
        children = set(sch_child_symbols(XSCHEM / "CDR.sch"))
        for block in (
            "alexander_phase_detector.sym",   # bang-bang phase detector
            "tiny_pll_charge_pump.sym",       # charge pump (already taped out)
            "tiny_pll_bias_gen.sym",          # its bias
            "tiny_pll_loop_filter.sym",       # loop filter
            "ring_oscillator.sym",            # the VCO
            "vctrl_precharge.sym",            # startup precharge (NOTES.md 17)
        ):
            self.assertIn(block, children, f"CDR.sch no longer instantiates {block}")

    def test_phase_detector_is_four_flip_flops_and_two_xors(self):
        children = sch_child_symbols(XSCHEM / "alexander_phase_detector.sch")
        self.assertEqual(children.count("d_flip_flop.sym"), 4)
        self.assertEqual(children.count("robs_xor.sym"), 2)

    def test_flip_flop_is_two_latches(self):
        children = sch_child_symbols(XSCHEM / "d_flip_flop.sch")
        self.assertEqual(children.count("d_latch.sym"), 2)

    def test_ring_oscillator_is_five_stages(self):
        children = sch_child_symbols(XSCHEM / "ring_oscillator.sch")
        self.assertEqual(
            children.count("ring_inverter.sym"), 5,
            "the VCO is a five-stage differential ring (NOTES.md 20b); the "
            "stage count sets the frequency plan",
        )

    def test_instance_names_are_unique_per_sheet(self):
        # xschem allows duplicate refdes if disable_unique_names is set; a
        # duplicate produces a netlist that silently drops an instance.
        for sch in sorted(XSCHEM.glob("*.sch")):
            names = [n for sym, n in sch_instances(sch)
                     if n and not sym.startswith("devices/")]
            self.assertEqual(
                len(names), len(set(names)),
                f"{sch.name} has duplicate instance names",
            )


class MacroInterface(unittest.TestCase):
    """The macro pin list is the LVS contract with src/project.v."""

    def test_symbol_pin_order(self):
        pins = [name for name, _ in sym_pins(XSCHEM / "ctle_cdr_rx.sym")]
        self.assertEqual(pins, MACRO_PINS)

    def test_symbol_pin_directions(self):
        directions = dict(sym_pins(XSCHEM / "ctle_cdr_rx.sym"))
        self.assertEqual(directions["vinp"], "in")
        self.assertEqual(directions["vinm"], "in")
        self.assertEqual(directions["vbias"], "in")
        self.assertEqual(directions["clkout_p"], "out")
        self.assertEqual(directions["clkout_n"], "out")

    def test_schematic_ports_match_the_symbol(self):
        labels = {lab for _, lab in sch_ports(TOP_SCH)}
        self.assertEqual(labels, set(MACRO_PINS))

    def test_verilog_blackbox_matches_the_symbol(self):
        modules = verilog_modules(read(REPO / "src" / "project.v"))
        self.assertIn(
            "ctle_cdr_rx", modules,
            "src/project.v no longer declares the analog macro that LVS matches",
        )
        self.assertEqual(modules["ctle_cdr_rx"], MACRO_PINS)

    def test_lvs_wrapper_instantiates_the_macro_once(self):
        # Netlisting ctle_cdr_rx.sch directly makes it the netlist top and emits
        # no .subckt for netgen; the wrapper exists solely to force one.
        children = sch_child_symbols(LVS_WRAPPER_SCH)
        self.assertEqual(children, ["ctle_cdr_rx.sym"])
        labels = {lab for _, lab in sch_ports(LVS_WRAPPER_SCH)}
        self.assertEqual(labels, set(MACRO_PINS))


if __name__ == "__main__":
    unittest.main()
