"""The repository's own analysis scripts, checked against known answers.

The numbers quoted in README.md and in the design logs are produced by the
small pure-stdlib analysis scripts in `xschem/tuning/` --- the eye metric, the
jitter parser, the PVT collector. Those scripts are the measuring instruments
of this project, so they get calibrated here against synthetic signals whose
answer is known analytically (see `test/fixtures/make_fixtures.py`).

The fixtures are NOT simulation results and none of these tests assert anything
about the circuit; they assert that the tools which measured the circuit still
compute what they claim to compute. No PDK, no simulator, no network.
"""

import os
import runpy
import sys
import unittest

from ttcheck import REPO

FIXTURES = os.path.join(os.path.dirname(os.path.abspath(__file__)), "fixtures")
TUNING = os.path.join(REPO, "xschem", "tuning")
CTLE = os.path.join(TUNING, "ctle")
PVT = os.path.join(TUNING, "pvt")

for p in (CTLE, PVT):
    if p not in sys.path:
        sys.path.insert(0, p)

UI = 1.665e-9
JITTER = 20e-12


class EyeMetric(unittest.TestCase):
    """ctle/eyemetrics.py -- the source of every eye height/width quoted."""

    @classmethod
    def setUpClass(cls):
        import eyemetrics
        cls.em = eyemetrics
        cls.rows = eyemetrics.read_blocks(
            os.path.join(FIXTURES, "ideal_nrz.dat"))[0][1]
        cls.bits = [int(c) for c in "01001101110100011011001011101000"]

    def test_parses_the_wrdata_layout(self):
        self.assertEqual(len(self.rows), 640)
        self.assertEqual(len(self.rows[0]), 2)   # [t, v]

    def test_ideal_eye_height_is_exactly_the_signal_swing(self):
        ph, h, w, m1, m0, sgn = self.em.eye(self.rows, 1, self.bits, 1e-9)
        self.assertAlmostEqual(h, 0.300, places=6,
                               msg="a +/-150 mV ideal NRZ must measure a 300 mV eye")

    def test_ideal_eye_is_open_for_most_of_the_ui(self):
        ph, h, w, m1, m0, sgn = self.em.eye(self.rows, 1, self.bits, 1e-9)
        # 100 ps of the 1 ns bit is spent on the edges
        self.assertGreater(w, 0.85)
        self.assertLessEqual(w, 1.0)

    def test_non_inverting_signal_is_reported_as_non_inverting(self):
        # the CTLE inverts and the metric undoes that; it must not "undo" an
        # inversion that is not there
        ph, h, w, m1, m0, sgn = self.em.eye(self.rows, 1, self.bits, 1e-9)
        self.assertEqual(sgn, 1.0)
        self.assertGreater(m1, m0)

    def test_inverted_copy_measures_the_same_eye(self):
        flipped = [[r[0], -r[1]] for r in self.rows]
        ph, h, w, m1, m0, sgn = self.em.eye(flipped, 1, self.bits, 1e-9)
        self.assertEqual(sgn, -1.0)
        self.assertAlmostEqual(h, 0.300, places=6)


class JitterParser(unittest.TestCase):
    """tuning/jitter_parse.py -- the source of the C26 jitter numbers."""

    @classmethod
    def setUpClass(cls):
        argv = sys.argv
        sys.argv = ["jitter_parse.py",
                    os.path.join(FIXTURES, "ideal_clock.raw"), "1.665", "0"]
        try:
            cls.g = runpy.run_path(os.path.join(TUNING, "jitter_parse.py"))
        finally:
            sys.argv = argv

    def test_finds_every_edge(self):
        self.assertEqual(len(self.g["per"]), 60,
                         "61 rising edges must yield 60 periods")

    def test_mean_period_is_exact(self):
        self.assertAlmostEqual(self.g["pm"], UI, delta=1e-15)

    def test_rms_jitter_is_exact(self):
        # every period is UI +/- 20 ps, so the population stdev is 20 ps
        self.assertAlmostEqual(self.g["ps"], JITTER, delta=1e-14)

    def test_peak_to_peak_is_exact(self):
        per = self.g["per"]
        self.assertAlmostEqual(max(per) - min(per), 2 * JITTER, delta=1e-14)

    def test_edge_times_are_monotonic(self):
        use = self.g["use"]
        self.assertTrue(all(b > a for a, b in zip(use, use[1:])))


class PvtCollector(unittest.TestCase):
    """pvt/collect_pvt.py -- the pass/fail criteria behind the PVT tables."""

    @classmethod
    def setUpClass(cls):
        import collect_pvt
        cls.cp = collect_pvt

    def _vals(self, name):
        vals, rc, done = self.cp.parse(os.path.join(FIXTURES, name))
        self.assertEqual(rc, 0)
        self.assertTrue(done)
        return vals

    def test_corner_names_are_decoded(self):
        p = self.cp.name_parts("T1_ss_hh_-40C_1p80")
        self.assertEqual(p["tier"], "T1")
        self.assertEqual(p["mos"], "ss")
        self.assertEqual(p["rc"], "hh")
        self.assertEqual(p["temp"], -40)
        self.assertEqual(p["vdd"], 1.80)

    def test_t0_passes_when_the_baud_rate_is_inside_the_tuning_range(self):
        verdict, why, info = self.cp.check_t0(self._vals("T0_pass.log"))
        self.assertEqual(verdict, "PASS", why)
        self.assertAlmostEqual(info["fmin"], 514.0, places=1)
        self.assertAlmostEqual(info["fmax"], 621.0, places=1)
        self.assertAlmostEqual(info["f079"], 602.0, places=1)

    def test_t0_fails_when_the_ring_cannot_reach_the_baud_rate(self):
        # this is the shape of the five accepted 125 C / 1.62 V failures (§20b)
        verdict, why, info = self.cp.check_t0(self._vals("T0_slow.log"))
        self.assertEqual(verdict, "FAIL")
        self.assertIn("outside range", why)

    def test_t1_passes_when_the_seed_clears_the_cliff(self):
        verdict, why = self.cp.check_t1(self._vals("T1_pass.log"), 1.80, 0.70)
        self.assertEqual(verdict, "PASS", why)

    def test_t1_fails_when_the_seed_sits_below_the_cliff(self):
        verdict, why = self.cp.check_t1(self._vals("T1_fail.log"), 1.80, 0.70)
        self.assertEqual(verdict, "FAIL")
        self.assertIn("cliff", why)

    def test_baud_rate_constant_matches_the_design(self):
        # a 2x error in this constant is exactly the bug that cost three
        # sessions in NOTES.md 14
        self.assertAlmostEqual(self.cp.BAUD_MHZ, 600.6, places=2)


if __name__ == "__main__":
    unittest.main()
