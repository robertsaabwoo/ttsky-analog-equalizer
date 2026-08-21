"""info.yaml <-> src/project.v <-> mag/ consistency.

Tiny Tapeout builds the datasheet, the pin mapping and the harness wiring from
``info.yaml``.  Nothing in the flow cross-checks it against the Verilog or the
magic cell, so a renamed top module or an analog pin documented in one place
and not the other survives all the way to tapeout.  These tests close that gap
and cost milliseconds.
"""

import re
import unittest

import yaml

from ttcheck import MAG, REPO, verilog_bits_used, verilog_modules, read

# Valid tile sizes for an analog Tiny Tapeout project.
# https://tinytapeout.com/specs/analog/
LEGAL_ANALOG_TILES = {"1x2", "2x2"}

# The pinout section is fixed by the template: eight of each digital group and
# six analog pins.  "DO NOT delete or add any pins."
EXPECTED_PINOUT_KEYS = (
    [f"ui[{i}]" for i in range(8)]
    + [f"uo[{i}]" for i in range(8)]
    + [f"uio[{i}]" for i in range(8)]
    + [f"ua[{i}]" for i in range(6)]
)

# The standard Tiny Tapeout user-module port list.
EXPECTED_TT_PORTS = [
    "VGND", "VDPWR", "ui_in", "uo_out", "uio_in", "uio_out", "uio_oe",
    "ua", "ena", "clk", "rst_n",
]


class InfoYaml(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.raw = read(REPO / "info.yaml")
        cls.info = yaml.safe_load(cls.raw)
        cls.project = cls.info["project"]
        cls.pinout = cls.info["pinout"]
        cls.verilog = read(REPO / "src" / "project.v")
        cls.modules = verilog_modules(cls.verilog)

    # -- the template fields actually got filled in ------------------------

    def test_no_unfilled_template_markers(self):
        for marker in ("TODO", "FIXME", "XXX", "fill in"):
            self.assertNotIn(
                marker, self.raw,
                f"info.yaml still contains the template marker {marker!r}",
            )

    def test_required_fields_are_non_empty(self):
        for field in ("title", "author", "description", "language", "top_module"):
            value = self.project.get(field)
            self.assertTrue(
                isinstance(value, str) and value.strip(),
                f"info.yaml project.{field} is empty",
            )

    def test_discord_is_present_but_may_be_blank(self):
        # Optional field: it must exist (the TT schema reads it) but an empty
        # string is a legitimate value.
        self.assertIn("discord", self.project)

    def test_source_files_exist(self):
        for name in self.project["source_files"]:
            self.assertTrue(
                (REPO / "src" / name).is_file(),
                f"info.yaml lists src/{name}, which does not exist",
            )

    # -- geometry and pin counts -------------------------------------------

    def test_tiles_is_a_legal_analog_value(self):
        self.assertIn(self.project["tiles"], LEGAL_ANALOG_TILES)

    def test_mag_makefile_uses_the_declared_tile_template(self):
        makefile = read(MAG / "Makefile")
        m = re.search(r"^TEMPLATE_FILE\s*:=\s*(\S+)", makefile, flags=re.M)
        self.assertIsNotNone(m, "mag/Makefile has no active TEMPLATE_FILE")
        self.assertEqual(
            m.group(1), f"tt_analog_{self.project['tiles']}.def",
            "mag/Makefile draws a different tile size than info.yaml declares",
        )

    def test_analog_pins_matches_the_documented_ua_entries(self):
        documented = [i for i in range(6) if str(self.pinout[f"ua[{i}]"]).strip()]
        self.assertEqual(
            self.project["analog_pins"], len(documented),
            "info.yaml analog_pins disagrees with the number of described ua[] pins",
        )

    def test_analog_pins_in_range_and_contiguous(self):
        n = self.project["analog_pins"]
        self.assertTrue(0 <= n <= 6, "analog_pins must be 0..6")
        # TT connects ua[0..analog_pins-1]; a description on a higher pin would
        # document a pin that is not wired up.
        for i in range(n, 6):
            self.assertFalse(
                str(self.pinout[f"ua[{i}]"]).strip(),
                f"ua[{i}] is documented but analog_pins is only {n}",
            )

    def test_pinout_keys_are_exactly_the_template_set(self):
        self.assertEqual(list(self.pinout.keys()), EXPECTED_PINOUT_KEYS)

    # -- info.yaml <-> project.v -------------------------------------------

    def test_top_module_matches_project_v(self):
        top = self.project["top_module"]
        self.assertTrue(top.startswith("tt_um_"), "top_module must start with tt_um_")
        self.assertIn(
            top, self.modules,
            "info.yaml top_module is not defined in src/project.v",
        )

    def test_top_module_has_the_standard_tt_port_list(self):
        ports = self.modules[self.project["top_module"]]
        self.assertEqual(sorted(ports), sorted(EXPECTED_TT_PORTS))

    def test_documented_outputs_are_the_driven_outputs(self):
        documented = {i for i in range(8) if str(self.pinout[f"uo[{i}]"]).strip()}
        driven = verilog_bits_used(self.verilog, "uo_out")
        self.assertEqual(
            documented, driven,
            "the uo[] pins described in info.yaml are not the uo_out bits "
            "connected in src/project.v",
        )

    def test_documented_analog_pins_are_the_connected_analog_pins(self):
        documented = {i for i in range(6) if str(self.pinout[f"ua[{i}]"]).strip()}
        connected = verilog_bits_used(self.verilog, "ua")
        self.assertEqual(
            documented, connected,
            "the ua[] pins described in info.yaml are not the ua bits "
            "connected in src/project.v",
        )

    def test_digital_inputs_are_undocumented_and_unconnected(self):
        # This is an analog tile with no digital logic: ui_in/uio_* are
        # deliberately left undriven (mag/LAYOUT_HANDOFF.md section 1).  If that
        # ever changes, both the Verilog and the datasheet must change together.
        self.assertEqual(verilog_bits_used(self.verilog, "ui_in"), set())
        self.assertEqual(verilog_bits_used(self.verilog, "uio_out"), set())
        for group in ("ui", "uio"):
            for i in range(8):
                self.assertFalse(
                    str(self.pinout[f"{group}[{i}]"]).strip(),
                    f"{group}[{i}] is documented but nothing drives it",
                )

    # -- info.yaml <-> mag/ -------------------------------------------------

    def test_mag_top_cell_matches_top_module(self):
        top = self.project["top_module"]
        cell = MAG / f"{top}.mag"
        self.assertTrue(
            cell.is_file(),
            f"mag/{top}.mag is missing: the magic top cell and info.yaml "
            "top_module have diverged",
        )

    def test_mag_makefile_project_name_matches_top_module(self):
        makefile = read(MAG / "Makefile")
        m = re.search(r"^PROJECT_NAME\s*\?=\s*(\S+)", makefile, flags=re.M)
        self.assertIsNotNone(m, "mag/Makefile has no PROJECT_NAME")
        self.assertEqual(m.group(1), self.project["top_module"])

    def test_clock_hz_is_zero_for_a_reference_less_receiver(self):
        # The clock is recovered from the data; there is no on-chip reference.
        # A non-zero value here would make the datasheet claim a clock input
        # that the layout does not have.
        self.assertEqual(self.project["clock_hz"], 0)


if __name__ == "__main__":
    unittest.main()
