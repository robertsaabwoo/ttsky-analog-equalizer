"""The real-number receiver model in model/ must still lock, settle and recover bits.

``model/rx_cdr_rnm.sv`` is a behavioural model of the analog macro: it exists so
the receiver can be closed into a link simulation, which a SPICE deck cannot be.
A behavioural model that is not simulated in CI rots immediately, and a CDR
model that silently stops locking is worse than no model at all -- the first
version of this one railed vctrl into the supply because the phase detector was
combinational rather than one decision per UI, and it still "ran" perfectly
happily.  ``model/tb_rx_cdr.sv`` is self-checking and exits non-zero on failure;
these tests run it and additionally pin the physically meaningful numbers.

Requires iverilog.  Skips (does not fail) when it is unavailable, so the suite
still runs on a machine without it.
"""

import os
import re
import shutil
import subprocess
import tempfile
import unittest

from ttcheck import REPO

MODEL = os.path.join(REPO, "model")
SOURCES = ["rx_cdr_rnm.sv", "tb_rx_cdr.sv"]

# The data rate the whole project is built around: UI = 1.665 ns.
DATA_RATE_HZ = 1.0 / 1.665e-9

IVERILOG = shutil.which("iverilog")
VVP = shutil.which("vvp")


@unittest.skipUnless(IVERILOG and VVP, "iverilog/vvp not installed")
class RnmModelTest(unittest.TestCase):
    """Compile and run the model once; assert on the captured output."""

    output = None

    @classmethod
    def setUpClass(cls):
        for src in SOURCES:
            path = os.path.join(MODEL, src)
            if not os.path.exists(path):
                raise unittest.SkipTest(f"missing {path}")
        with tempfile.TemporaryDirectory() as tmp:
            vvp_out = os.path.join(tmp, "tb.vvp")
            compile_ = subprocess.run(
                [IVERILOG, "-g2012", "-o", vvp_out] + SOURCES,
                cwd=MODEL, capture_output=True, text=True, timeout=300,
            )
            if compile_.returncode != 0:
                raise AssertionError(
                    "iverilog failed to compile the model:\n" + compile_.stderr
                )
            run = subprocess.run(
                [VVP, vvp_out], cwd=MODEL,
                capture_output=True, text=True, timeout=900,
            )
        cls.output = run.stdout
        cls.returncode = run.returncode

    def value(self, pattern):
        """Pull one float out of the testbench transcript."""
        m = re.search(pattern, self.output)
        self.assertIsNotNone(
            m, f"pattern {pattern!r} not in transcript:\n{self.output}"
        )
        return float(m.group(1))

    def test_testbench_reports_pass(self):
        """The self-checking testbench must report PASS."""
        self.assertIn("RESULT: PASS", self.output,
                      f"model testbench did not pass:\n{self.output}")

    def test_frequency_locks_to_the_data_rate(self):
        """Recovered clock must land on the data rate, not merely somewhere."""
        freq = self.value(r"recovered clock frequency\s*:\s*([0-9.]+) MHz") * 1e6
        self.assertAlmostEqual(
            freq / DATA_RATE_HZ, 1.0, delta=0.005,
            msg=f"recovered {freq/1e6:.2f} MHz vs {DATA_RATE_HZ/1e6:.2f} MHz data rate",
        )

    def test_control_voltage_settles(self):
        """Two separated late windows must agree -- i.e. acquisition finished.

        This is exactly the check §C26's SPICE run omitted, which is why its
        phase-error number measured convergence rather than jitter.
        """
        drift = self.value(r"drift\s+([0-9.]+) mV")
        self.assertLess(drift, 10.0, "vctrl still moving between late windows")

    def test_control_voltage_matches_the_measured_lock_point(self):
        """The model must settle near the vctrl SPICE actually measured.

        §C26 measured vctrl ~0.80 V at lock.  Nothing in the model is fitted to
        that: it falls out of the measured VCO slope (357 MHz/V, NOTES_CTLE.md
        :973) and the measured charge-pump currents (§C25-E).  If a change to
        the model breaks this agreement, the model has stopped corresponding to
        the silicon and its other numbers should not be trusted either.
        """
        v1 = self.value(r"vctrl [0-9.]+-[0-9.]+us / [0-9.]+-[0-9.]+us\s*:\s*([0-9.]+) V")
        self.assertAlmostEqual(
            v1, 0.80, delta=0.05,
            msg=f"model settles at {v1:.4f} V, SPICE measured ~0.80 V (§C26)",
        )

    def test_data_is_recovered_without_errors(self):
        """Zero bit errors against the transmitted PRBS7 in the settled window."""
        errs = self.value(r"bit errors \(best latency = -?\d+\)\s*:\s*([0-9]+) over")
        self.assertEqual(errs, 0.0, "recovered data does not match transmitted PRBS7")

    def test_exit_status_is_success(self):
        self.assertEqual(self.returncode, 0,
                         f"vvp exited {self.returncode}:\n{self.output}")


class RnmModelHonestyTest(unittest.TestCase):
    """The model must keep saying what it is not.

    An RNM that loses its limitations section starts getting quoted as if it
    were silicon.  The ring is a phase accumulator with no phase noise, so the
    model understates jitter and must never be the source of a jitter number.
    """

    def test_model_documents_its_limits(self):
        text = open(os.path.join(MODEL, "rx_cdr_rnm.sv")).read()
        for phrase in ("LIMITS", "UNDERSTATES", "no noise"):
            self.assertIn(phrase, text,
                          f"model no longer documents its limits ({phrase!r})")

    def test_fitted_parameters_are_labelled_as_fitted(self):
        """RLF/CLF are chosen to reproduce measured behaviour, not extracted."""
        text = open(os.path.join(MODEL, "rx_cdr_rnm.sv")).read()
        self.assertIn("FITTED, NOT MEASURED", text)


if __name__ == "__main__":
    unittest.main()
