"""The generated low-power CML receiver in xschem/cml/ stays consistent with itself.

These are the checks that need neither xschem nor netgen (CI has neither); the
full netlist-vs-reference comparison is xschem/cml/verify.sh.
"""
import re
import unittest
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
CML = REPO / "xschem" / "cml"
FROZEN_TOP = REPO / "xschem" / "ctle_cdr_rx.sym"


def sym_pins(path):
    return [m.group(1) for m in re.finditer(r"^B 5 \S+ \S+ \S+ \S+ \{name=([^ }]+)", path.read_text(), re.M)]


def subckt_ports(text):
    return {m.group(1): m.group(2).split() for m in re.finditer(r"^\.subckt (\S+)(.*)$", text, re.M)}


@unittest.skipUnless(CML.is_dir(), "no xschem/cml/ on this branch")
class CmlSchematics(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.cells = (CML / "cells.txt").read_text().split()
        cls.ref = subckt_ports((CML / "reference.spice").read_text())

    def test_every_cell_has_a_schematic_and_a_symbol(self):
        for c in self.cells:
            self.assertTrue((CML / f"{c}.sch").is_file(), f"{c}.sch missing")
            self.assertTrue((CML / f"{c}.sym").is_file(), f"{c}.sym missing")

    def test_every_cell_is_in_the_reference(self):
        for c in self.cells:
            self.assertIn(c, self.ref, f"{c} is not in reference.spice")

    def test_symbol_pins_follow_the_reference_ports(self):
        for c in self.cells:
            self.assertEqual(sym_pins(CML / f"{c}.sym"), self.ref[c], f"{c}.sym pin order")

    def test_macro_ports_match_the_frozen_macro(self):
        frozen = sym_pins(FROZEN_TOP)
        tops = [c for c in self.cells if c.startswith("ctle_cdr_rx_cml")]
        self.assertTrue(tops, "no ctle_cdr_rx_cml* top in cells.txt")
        for c in tops:
            self.assertEqual(self.ref[c], frozen, f"{c} ports differ from ctle_cdr_rx")

    def test_lvs_wrapper_instantiates_the_tops(self):
        text = (CML / "cml_lvs.sch").read_text()
        for c in self.cells:
            if c.startswith("ctle_cdr_rx_cml"):
                self.assertIn(f"cml/{c}.sym", text)


if __name__ == "__main__":
    unittest.main()
