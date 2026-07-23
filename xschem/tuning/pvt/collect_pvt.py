#!/usr/bin/env python3
"""
collect_pvt.py -- parse pvt/results/*.log into a table with PASS/FAIL.

    ./collect_pvt.py T0        # VCO tuning range curves
    ./collect_pvt.py T1        # precharge cell
    ./collect_pvt.py T2        # full CDR loop
    ./collect_pvt.py ALL

Pure stdlib (numpy is not installed on this VM).

Pass criteria are stated in README.md; they are implemented in check_t0/1/2
below so the criterion and the code can never disagree.
"""
import glob
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
RESULTS = os.path.join(HERE, "results")

BAUD_MHZ = 600.600          # 1.665 ns UI
NOM_CLIFF = 0.65            # VCO dead-zone at tt/27C; T0 refines this per corner

MEAS = re.compile(r"^(\w+)\s*=\s*([-+0-9.eE]+)")


def parse(path):
    """Return (dict of measurements, rc, completed?)."""
    vals, rc, done = {}, None, False
    for line in open(path, errors="replace"):
        m = MEAS.match(line.strip())
        if m:
            try:
                vals[m.group(1)] = float(m.group(2))
            except ValueError:
                pass
        if "exit rc=" in line:
            rc = int(line.strip().split("exit rc=")[1]); done = True
        if "WATCHDOG" in line:
            vals["_watchdog"] = 1.0
    return vals, rc, done


def name_parts(name):
    """T1_ss_hh_-40C_1p80 -> dict(tier,mos,rc,temp,vdd)."""
    p = name.split("_")
    tier = p[0]
    off = 1
    pol = None
    if tier == "T2" and p[1] in ("bad", "good"):
        pol = p[1]; off = 2
    mos, rc = p[off], p[off + 1]
    temp = int(p[off + 2].rstrip("C"))
    vdd = float(p[off + 3].replace("p", "."))
    return dict(tier=tier, mos=mos, rc=rc, temp=temp, vdd=vdd, pol=pol)


# ------------------------------------------------------------------------ T0
try:
    from gen_pvt import T0_VCTRL
except Exception:                    # keep the collector usable standalone
    T0_VCTRL = [0.60, 0.65, 0.70, 0.75, 0.79, 0.85, 0.90, 1.00, 1.20, 1.40]


def t0_curve(vals):
    """-> sorted [(vctrl, freq_MHz or None)].

    A `meas` that finds no crossing prints an error and NO "name = value"
    line, so the point is absent from vals.  Seed the dict with every vctrl we
    asked for, otherwise a dead oscillator silently vanishes from the curve
    instead of showing up as '-'."""
    pts = {v: {} for v in T0_VCTRL}
    for k, v in vals.items():
        m = re.match(r"^v(\d+p\d+)_([ab])$", k)
        if m:
            vc = float(m.group(1).replace("p", "."))
            pts.setdefault(vc, {})[m.group(2)] = v
    out = []
    for vc in sorted(pts):
        d = pts[vc]
        if "a" in d and "b" in d and d["b"] > d["a"]:
            out.append((vc, 20.0 / (d["b"] - d["a"]) / 1e6))
        else:
            out.append((vc, None))          # never reached 40 crossings = dead
    return out


def check_t0(vals):
    c = t0_curve(vals)
    if not c:
        return "FAIL", "no crossings measured at all", {}
    live = [(v, f) for v, f in c if f]
    if not live:
        return "FAIL", "ring never oscillated at any vctrl", {}
    cliff = min(v for v, f in live)
    f079 = dict(c).get(0.79)
    fmin, fmax = min(f for _, f in live), max(f for _, f in live)
    info = dict(cliff=cliff, f079=f079, fmin=fmin, fmax=fmax)
    if f079 is None:
        return "FAIL", f"dead at the 0.79 V seed (cliff={cliff:.2f} V)", info
    if not (fmin <= BAUD_MHZ <= fmax):
        return "FAIL", f"{BAUD_MHZ:.1f} MHz outside range {fmin:.0f}-{fmax:.0f} MHz", info
    return "PASS", f"cliff {cliff:.2f} V, f(0.79)={f079:.0f} MHz", info


# ------------------------------------------------------------------------ T1
def check_t1(vals, vdd, cliff):
    nb, vc = vals.get("nb_h"), vals.get("vc_h")
    tr = vals.get("t_rel")
    if nb is None or vc is None:
        return "FAIL", "cell measurements missing (did the run finish?)"
    bad = []
    if not (cliff + 0.03 <= nb <= 1.10):
        bad.append(f"nbias {nb:.3f} outside [{cliff+0.03:.2f}, 1.10]")
    if vc <= cliff:
        bad.append(f"vctrl seed {vc:.3f} NOT above the {cliff:.2f} V cliff")
    if abs(vc - nb) > 0.05:
        bad.append(f"switch drop {abs(vc-nb)*1e3:.0f} mV > 50 mV")
    if tr is None:
        bad.append("one-shot never released (t_rel not found)")
    elif not (40e-9 <= tr <= 600e-9):
        bad.append(f"t_rel {tr*1e9:.0f} ns outside [40, 600] ns")
    if bad:
        return "FAIL", "; ".join(bad)
    return "PASS", f"nbias {nb:.3f}, seed {vc:.3f}, release {tr*1e9:.0f} ns"


# ------------------------------------------------------------------------ T2
def check_t2(vals, vdd):
    lv, pp = vals.get("l_vctrl"), vals.get("l_cp_pp")
    c600, c660 = vals.get("c600"), vals.get("c660")
    hv, tr = vals.get("h_vctrl"), vals.get("t_rel")
    cell = "cell OK" if (tr and hv and hv > NOM_CLIFF) else "CELL DID NOT SEED"
    if lv is None or pp is None:
        return "FAIL", f"loop measurements missing ({cell})", None
    if pp < 1.0:
        return "FAIL", f"clk+ pp only {pp:.3f} V -> VCO dead ({cell})", None
    if not (0.05 < lv < vdd - 0.05):
        return "FAIL", f"vctrl railed at {lv:.3f} -> VCO tuning range exhausted, " \
                       f"not a precharge failure ({cell})", None
    if c600 is None or c660 is None or c660 <= c600:
        return "FAIL", f"could not measure the clock period ({cell})", None
    f = 60.0 / (c660 - c600) / 1e6
    err = (f - BAUD_MHZ) / BAUD_MHZ * 100
    if abs(err) > 0.5:
        return "FAIL", f"{f:.3f} MHz ({err:+.3f} %) -- not locked ({cell})", f
    return "PASS", f"{f:.3f} MHz ({err:+.3f} %), vctrl {lv:.4f} ({cell})", f


# ----------------------------------------------------------------------- main
def main():
    tier = (sys.argv[1] if len(sys.argv) > 1 else "ALL").upper()
    pat = "*" if tier == "ALL" else tier + "_*"
    logs = sorted(glob.glob(os.path.join(RESULTS, pat + ".log")))
    if not logs:
        sys.exit(f"no logs in {RESULTS} matching {pat}.log -- run ./run_pvt.sh first")

    # T0 gives the true per-corner cliff, which T1 then judges its seed against.
    cliffs = {}
    for p in glob.glob(os.path.join(RESULTS, "T0_*.log")):
        v, _, done = parse(p)
        if done:
            _, _, info = check_t0(v)
            if info.get("cliff") is not None:
                q = name_parts(os.path.basename(p)[:-4])
                cliffs[(q["mos"], q["temp"], q["vdd"])] = info["cliff"]

    npass = nfail = nincomplete = 0
    print(f"{'run':<34} {'verdict':<7} detail")
    print("-" * 108)
    for p in logs:
        name = os.path.basename(p)[:-4]
        q = name_parts(name)
        vals, rc, done = parse(p)
        if not done:
            print(f"{name:<34} {'--':<7} INCOMPLETE (no exit rc; still running or killed)")
            nincomplete += 1
            continue
        if vals.get("_watchdog"):
            print(f"{name:<34} {'KILLED':<7} memory watchdog fired")
            nfail += 1
            continue
        if q["tier"] == "T0":
            verdict, detail, _ = check_t0(vals)
        elif q["tier"] == "T1":
            cliff = cliffs.get((q["mos"], q["temp"], q["vdd"]), NOM_CLIFF)
            verdict, detail = check_t1(vals, q["vdd"], cliff)
        else:
            verdict, detail, _ = check_t2(vals, q["vdd"])
        print(f"{name:<34} {verdict:<7} {detail}")
        npass += verdict == "PASS"
        nfail += verdict == "FAIL"

    print("-" * 108)
    print(f"{npass} pass, {nfail} fail, {nincomplete} incomplete")

    if tier in ("T0", "ALL"):
        print("\nT0 tuning curves (MHz vs vctrl; '-' = not oscillating):")
        for p in sorted(glob.glob(os.path.join(RESULTS, "T0_*.log"))):
            vals, _, done = parse(p)
            if not done:
                continue
            c = t0_curve(vals)
            row = "  ".join(f"{v:.2f}:{('%.0f' % f) if f else '-':>5}" for v, f in c)
            print(f"  {os.path.basename(p)[:-4]:<28} {row}")


if __name__ == "__main__":
    main()
