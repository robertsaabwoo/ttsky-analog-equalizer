#!/usr/bin/env python3
"""bbloop.py -- a seconds-long bang-bang CDR loop model with LOOP DELAY as a knob.

    bbloop.py [--delay UI ...] [--kvco MHz/mV] [--icp uA] [--r kohm] [--c1 fF] [--c2 fF]

Why: the 6 us SPICE closed loop costs 40+ minutes and answers one question at a
time. This reproduces the loop's large-signal behaviour (bang-bang decisions,
charge pump, R + C1 || C2 filter, linear VCO) on PRBS7, so a hypothesis such as
"the CML phase detector adds loop delay" can be checked against the measured
signatures (same-sign decision runs, vctrl RMS, period jitter) in seconds,
before spending SPICE time.

Model, per sub-step of UI/NSUB:
  * data: PRBS7 at 600.6 Mb/s. Clock phase phi is in UI relative to the ideal
    sampling instant; phi > 0 means the clock is late.
  * PD: at each data transition, a late clock (phi > 0) gives up (+1), which
    speeds the VCO so the clock moves earlier; an early clock gives down
    (matches CML.md C1: early clock gives down).
  * the decision becomes a WIDTH-UI charge-pump pulse (+-Icp) that starts DELAY UI
    after the transition was sampled. Back-to-back same-sign pulses merge, as
    in the SPICE waveforms.
  * filter: Icp into the vctrl node (C2); R from vctrl to C1.
  * VCO: f = f_data + Kvco * (vctrl - v_lock). Phase advances by (f/f_data - 1)
    UI per UI, i.e. a fast clock moves earlier (phi decreases).
It has no noise, no metastability and no nonlinearity, so absolute numbers are
indicative; the TREND with delay is what it is for.
Pure stdlib (../../../CLAUDE.md).
"""
import argparse
from statistics import mean, pstdev

UI = 1.665e-9
FDATA = 1 / UI


def prbs7(n, seed=0x7F):
    s, out = seed, []
    for _ in range(n):
        b = ((s >> 6) ^ (s >> 5)) & 1
        s = ((s << 1) | b) & 0x7F
        out.append(b)
    return out


def run(delay, kvco, icp, r, c1, c2, nui=20000, nsub=32, settle=6000, width=1.0, tpl=None):
    dt = UI / nsub
    bits = prbs7(nui + 1)
    vc1 = vctrl = 0.0            # deviations from the lock point
    phi = 0.05                   # start slightly late
    pending = []                 # (start_substep, sign)
    k_delay = int(round(delay * nsub))
    drive_until, drive_sign = -1, 0
    # template mode: each decision ADDS its measured pump current (spikes and
    # all) into a future-current buffer; overlapping decisions superpose
    future = [0.0] * (nui * nsub + 4 * nsub) if tpl else None
    VC, C1, PER, PHI, DEC = [], [], [], [], []
    for n in range(nui):
        # decision at this UI boundary (sampled with the current phase)
        if bits[n + 1] != bits[n]:
            d = 1 if phi > 0 else -1
            if tpl:
                w = tpl["up"] if d > 0 else tpl["down"]
                for s_, cur in enumerate(w):
                    future[n * nsub + s_] += cur
            else:
                pending.append((n * nsub + k_delay, d))
            if n >= settle:
                DEC.append(d)
        f_acc = 0.0
        for s in range(nsub):
            k = n * nsub + s
            while pending and pending[0][0] <= k:
                _, sg = pending.pop(0)
                drive_until, drive_sign = k + int(round(width * nsub)), sg
            if tpl:
                i = future[k]
            else:
                i = icp * drive_sign if k < drive_until else 0.0
            ir = (vctrl - vc1) / r
            vctrl += (i - ir) * dt / c2
            vc1 += ir * dt / c1
            f = FDATA + kvco * vctrl
            phi -= (f / FDATA - 1) / nsub
            f_acc += f
        if n >= settle:
            VC.append(vctrl); C1.append(vc1)
            PER.append(1 / (f_acc / nsub)); PHI.append(phi)
    runs, rl = [], 1
    for a, b in zip(DEC, DEC[1:]):
        if a == b:
            rl += 1
        else:
            runs.append(rl); rl = 1
    runs.append(rl)
    return dict(vctrl_rms=pstdev(VC) * 1e3, vctrl_pp=(max(VC) - min(VC)) * 1e3,
                c1_rms=pstdev(C1) * 1e3, per_rms=pstdev(PER) * 1e12,
                phi_rms=pstdev(PHI) * 100, run_mean=mean(runs), run_max=max(runs))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--delay", type=float, nargs="+", default=[0.25, 0.5, 1, 1.5, 2, 3, 4])
    ap.add_argument("--kvco", type=float, default=0.6, help="MHz per mV")
    ap.add_argument("--icp", type=float, default=1.26, help="uA")
    ap.add_argument("--r", type=float, default=80, help="kohm")
    ap.add_argument("--c1", type=float, default=121, help="fF")
    ap.add_argument("--c2", type=float, default=19, help="fF")
    ap.add_argument("--width", type=float, default=1.0, help="charge-pump pulse per decision, UI")
    ap.add_argument("--template", help="frozen|cml|...: use the measured U1 pump current "
                    "per decision from templates.json (u1_templates.py) instead of a pulse")
    a = ap.parse_args()
    kv = a.kvco * 1e6 / 1e-3
    tpl = None
    if a.template:
        import json
        tj = json.load(open("templates.json"))
        assert tj["nsub"] == 32
        tpl = tj["templates"][a.template]
    print(f"{'template ' + a.template if a.template else 'pulse ' + str(a.width) + ' UI'}  Kvco {a.kvco} MHz/mV  Icp {a.icp} uA  R {a.r} k  C1 {a.c1} fF  C2 {a.c2} fF")
    print("delay(UI)  vctrl RMS  vctrl pp   C1 RMS  period RMS  phase RMS  same-sign runs mean/max")
    for d in a.delay:
        m = run(d, kv, a.icp * 1e-6, a.r * 1e3, a.c1 * 1e-15, a.c2 * 1e-15, width=a.width, tpl=tpl)
        print(f"{d:8.2f}  {m['vctrl_rms']:7.1f} mV {m['vctrl_pp']:7.1f} mV {m['c1_rms']:6.1f} mV "
              f"{m['per_rms']:7.1f} ps  {m['phi_rms']:6.2f} %UI   {m['run_mean']:5.2f} / {m['run_max']}")


if __name__ == "__main__":
    main()
