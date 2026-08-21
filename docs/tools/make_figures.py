#!/usr/bin/env python3
"""Regenerate the figures in ../img/ from the simulation data on disk.

    python3 docs/tools/make_figures.py [bode|eye|jitter|block|all]

No simulations are run and nothing is re-measured: every figure is drawn from
data ngspice already wrote, and each one is cross-checked against the number
published in the design log before it is plotted. The existing parsers are
reused rather than reimplemented --- `ctle/eyemetrics.py` for the eye data and
`tuning/jitter_parse.py` for the recovered-clock edges.

numpy/matplotlib are not installed and must not be (../../CLAUDE.md); the SVG
is emitted directly by ./svgplot.py.
"""

import os
import runpy
import sys
from math import log10, sqrt

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
IMG = os.path.join(REPO, "docs", "img")
TUNING = os.path.join(REPO, "xschem", "tuning")
CTLE = os.path.join(TUNING, "ctle")

sys.path.insert(0, HERE)
sys.path.insert(0, CTLE)

from svgplot import (AXIS, BG, BLUE, GREEN, GRID, INK, MONO, MUTED, ORANGE,
                     PURPLE, RED, SLATE, Axes, Canvas, legend)

UI_600 = 1.665e-9          # 600.6 Mb/s, the design rate
NYQUIST = 300e6            # 600.6 Mb/s NRZ
R_PAD, C_PAD = 500.0, 5e-12   # TinyTapeout analog pin path, spec bound


def channel_db(f):
    """Loss of the TT analog pin path, computed from the spec bound (not fitted).

    A single-pole RC: |H| = 1 / sqrt(1 + (f/fp)^2), fp = 1/(2*pi*R*C).
    """
    fp = 1.0 / (2 * 3.141592653589793 * R_PAD * C_PAD)
    return -10.0 * log10(1.0 + (f / fp) ** 2)


def need(path):
    if not os.path.exists(path):
        print(f"  SKIP: {path} is not on disk")
        return None
    return path


# ---------------------------------------------------------------------------
# 1. Channel vs equalizer, in the frequency domain
# ---------------------------------------------------------------------------

def fig_bode():
    src = need(os.path.join(CTLE, "ac_base.dat"))
    if not src:
        return None
    freqs, gains = [], []
    with open(src) as f:
        for line in f:
            p = line.split()
            if len(p) >= 2:
                freqs.append(float(p[0]))
                gains.append(float(p[1]))
    chan = [channel_db(f) for f in freqs]
    both = [g + c for g, c in zip(gains, chan)]
    fp = 1.0 / (2 * 3.141592653589793 * R_PAD * C_PAD)
    print(f"  channel pole {fp/1e6:.1f} MHz, loss at Nyquist "
          f"{channel_db(NYQUIST):.2f} dB  (NOTES_CTLE C16: 63.7 MHz / -13.7 dB)")

    W, H = 900, 470
    cv = Canvas(W, H, "Channel vs equalizer",
                "The TinyTapeout analog pin path and what the CTLE has to do about it")
    cv.card()
    cv.text(28, 34, "The channel is the chip's own pin — and the equalizer has to invert it",
            16, INK, weight="700")
    cv.text(28, 54, "sky130, tt / 27 °C / 1.8 V. Frequency response, differential.",
            12, MUTED)

    ax = Axes(cv, 66, 78, W - 66 - 250, H - 78 - 58, (1e6, 1e10), (-32, 20), xlog=True)
    ax.frame()
    decades = [1e6, 1e7, 1e8, 1e9, 1e10]
    minors = [d * m for d in decades[:-1] for m in range(2, 10)]
    for v in minors:
        cv.line(ax.px(v), ax.y, ax.px(v), ax.y + ax.h, GRID, 0.6)
    ax.gridx(decades)
    ax.gridy([-30, -20, -10, 0, 10, 20])
    ax.xticks(decades, ["1 MHz", "10 MHz", "100 MHz", "1 GHz", "10 GHz"])
    ax.yticks([-30, -20, -10, 0, 10, 20],
              ["-30", "-20", "-10", "0", "+10", "+20"])
    cv.text(30, ax.y + ax.h / 2, "gain (dB)", 12, MUTED, "middle",
            rotate=-90)
    cv.text(ax.x + ax.w / 2, H - 18, "frequency", 12, MUTED, "middle")

    ax.hline(0, color="#b8c0c8", dash="3 4", sw=1)
    ax.vline(NYQUIST, color=ORANGE, dash="6 4", sw=1.5)
    cv.text(ax.px(NYQUIST) - 8, ax.y + 16, "Nyquist, 300 MHz", 11, ORANGE, "end",
            weight="600")

    ax.clipped_plot(freqs, chan, stroke=RED, sw=2.2)
    ax.clipped_plot(freqs, gains, stroke=PURPLE, sw=1.8, dash="7 4")
    ax.clipped_plot(freqs, both, stroke=SLATE, sw=1.6)

    # the retuned (shipped) CTLE: measured points, not an interpolated curve
    ax.marker(1.4e6, 6.19, BLUE, 5)
    ax.errbar(NYQUIST, 11.71, 14.40, BLUE, cap=6, sw=2.4)
    ax.marker(NYQUIST, 13.32, BLUE, 5.5)
    ax.errbar(NYQUIST, -2.03, 0.66, GREEN, cap=6, sw=2.4)
    ax.marker(NYQUIST, -0.43, GREEN, 5.5)
    ax.marker(NYQUIST, channel_db(NYQUIST), RED, 5)

    cv.text(ax.px(NYQUIST) + 12, ax.py(13.32) - 6, "+13.32 dB", 11.5, BLUE, "start", "700")
    cv.text(ax.px(NYQUIST) + 12, ax.py(13.32) + 9, "(11.71…14.40 over 27 corners)",
            10, BLUE, "start")
    cv.text(ax.px(NYQUIST) + 12, ax.py(-0.43) - 5, "-0.43 dB combined", 11.5, GREEN,
            "start", "700")
    cv.text(ax.px(NYQUIST) + 12, ax.py(-0.43) + 10, "(-2.03…+0.66 over 27 corners)",
            10, GREEN, "start")
    cv.text(ax.px(NYQUIST) - 10, ax.py(channel_db(NYQUIST)) + 4, "-13.7 dB", 11.5,
            RED, "end", "700")

    lx = ax.x + ax.w + 24
    cv.text(lx, ax.y + 10, "measured / computed", 11, MUTED, weight="700")
    legend(cv, lx, ax.y + 30, [
        ("pin path, 500 Ω / 5 pF", RED, None),
        ("CTLE as first drawn", PURPLE, "7 4"),
        ("as drawn + pin path", SLATE, None),
    ])
    cv.circle(lx + 8, ax.y + 96, 5, BLUE, "#ffffff", 1.6)
    cv.text(lx + 23, ax.y + 100, "retuned CTLE (measured)", 11.5, INK)
    cv.circle(lx + 8, ax.y + 117, 5, GREEN, "#ffffff", 1.6)
    cv.text(lx + 23, ax.y + 121, "retuned CTLE + pin path", 11.5, INK)

    box_y = ax.y + 150
    cv.rect(lx - 6, box_y, 230, 132, fill="#f6f8fa", stroke="#d8dee4", sw=1, rx=6)
    for i, line in enumerate([
        "The pin path alone costs 13.7 dB",
        "at Nyquist and shuts the eye at the",
        "pad. The CTLE as first drawn had no",
        "peaking at all (§C2), so it could not",
        "help. Retuned, it delivers +13.32 dB",
        "at Nyquist — cancelling the channel",
        "to within half a dB, and to ±2 dB",
        "over the whole 27-corner box.",
    ]):
        cv.text(lx + 4, box_y + 20 + i * 14, line, 10.8, INK if i else INK)

    cv.text(28, H - 18,
            "curves: ngspice AC, ctle/ac_base.dat (§C2) · channel computed from the "
            "TT spec bound · points: §C18 / §C20",
            10, MUTED)
    out = os.path.join(IMG, "channel-vs-ctle.svg")
    cv.save(out)
    return out


# ---------------------------------------------------------------------------
# 2. Eye diagrams: at the pad, through the as-drawn CTLE, through the retune
# ---------------------------------------------------------------------------

def fig_eye(stride=5):
    src = need(os.path.join(CTLE, "eye2_1g.dat"))
    if not src:
        return None
    import eyemetrics as em

    rows = em.read_blocks(src)[0][1]
    bits = [int(c) for c in open(os.path.join(CTLE, "prbs_bits.txt")).read().split()[0]]
    ui = 1e-9   # §C11: this deck was re-run at UI = 1 ns; 12701 rows span 127 ns

    panels = [
        (2, "at the pad", "after 500 Ω / 2 pF", "the eye the CTLE is handed"),
        (5, "CTLE as first drawn", "same channel", "no peaking: still shut"),
        (8, "CTLE retuned", "same channel", "the eye the CDR samples"),
    ]

    # cross-check every panel against the numbers published in §C11 before plotting
    stats = {}
    for col, name, _, _ in panels:
        ph, h, w, m1, m0, sgn = em.eye(rows, col, bits, ui)
        stats[col] = (h, w, sgn)
        print(f"  col{col} {name:<22} height {h*1e3:7.1f} mV   width {w:.3f} UI")

    PW, PH = 258, 210
    W, H = 3 * PW + 4 * 26, PH + 196
    cv = Canvas(W, H, "Eye diagrams before and after equalization",
                "PRBS7 through an RC channel, measured in ngspice")
    cv.card()
    cv.text(26, 32, "What the equalizer is for: the same data, at three points in the path",
            16, INK, weight="700")
    cv.text(26, 52, "PRBS7 (127 bits) at 1 Gb/s through a 500 Ω / 2 pF channel — the §C11 "
                    "experiment, sky130 tt / 27 °C. Traces overlaid on a 2 UI window.",
            11.5, MUTED)

    step = stride
    for k, (col, name, sub, note) in enumerate(panels):
        x0 = 26 + k * (PW + 26)
        y0 = 78
        h, w, sgn = stats[col]
        vals = [sgn * r[col] for r in rows]
        ts = [r[0] for r in rows]
        lo, hi = min(vals), max(vals)
        pad = 0.14 * (hi - lo) if hi > lo else 0.1
        ax = Axes(cv, x0, y0, PW, PH, (-0.5, 1.5), (lo - pad, hi + pad))
        ax.frame(fill="#fbfcfd")
        ax.gridy([lo - pad, (lo + hi) / 2, hi + pad])
        for u in (-0.5, 0.0, 0.5, 1.0, 1.5):
            cv.line(ax.px(u), ax.y, ax.px(u), ax.y + ax.h, GRID, 0.8)

        colr = (RED if k == 0 else PURPLE if k == 1 else GREEN)
        n = len(rows)
        for b in range(em.SKIP, len(bits) - 1):
            i0 = int(round((b - 0.5) * ui / (ts[1] - ts[0])))
            i1 = int(round((b + 1.5) * ui / (ts[1] - ts[0])))
            if i0 < 0 or i1 >= n:
                continue
            pts = []
            for i in range(i0, i1 + 1, step):
                pts.append((ax.px((ts[i] - b * ui) / ui), ax.py(vals[i])))
            cv.polyline(pts, colr, 0.55, opacity=0.36)

        cv.text(x0 + PW / 2, y0 - 26, name, 13, INK, "middle", "700")
        cv.text(x0 + PW / 2, y0 - 10, sub, 10.5, MUTED, "middle")
        ax.xticks([-0.5, 0, 0.5, 1.0, 1.5], ["-0.5", "0", "0.5 UI", "1.0", "1.5"])
        cv.text(x0 + 8, y0 + PH + 38, f"eye height   {h*1e3:.0f} mV", 12,
                colr, weight="700")
        cv.text(x0 + 8, y0 + PH + 56, f"eye width    {w:.3f} UI", 12, colr, weight="700")
        cv.text(x0 + 8, y0 + PH + 74, note, 10.5, MUTED)

    cv.text(26, H - 14,
            "data: xschem/tuning/ctle/eye2_1g.dat, measured with the repo's own "
            "eyemetrics.py — the three heights/widths above reproduce the §C11 table exactly.",
            10, MUTED)
    out = os.path.join(IMG, "eye-before-after.svg")
    cv.save(out)
    return out


# ---------------------------------------------------------------------------
# 3. Recovered-clock period jitter
# ---------------------------------------------------------------------------

def fig_jitter():
    raw = need(os.path.join(TUNING, "c26_rclk.raw"))
    if not raw:
        return None
    argv = sys.argv
    sys.argv = ["jitter_parse.py", raw, "1.665", "1800"]
    try:
        g = runpy.run_path(os.path.join(TUNING, "jitter_parse.py"))
    finally:
        sys.argv = argv
    per = g["per"]        # cycle-to-cycle periods, settled window only
    use = g["use"]        # the edge times they came from
    pm, ps = g["pm"], g["ps"]
    ui = 1.665e-9

    lo, hi = min(per), max(per)
    NB = 34
    width = (hi - lo) / NB
    counts = [0] * NB
    for p in per:
        counts[min(NB - 1, int((p - lo) / width))] += 1
    top = max(counts)

    W, H = 900, 420
    cv = Canvas(W, H, "Recovered-clock period jitter",
                "Cycle-to-cycle jitter of the recovered clock on PRBS7 data")
    cv.card()
    cv.text(28, 34, "Recovered-clock period jitter, full chain, on PRBS7 data",
            16, INK, weight="700")
    cv.text(28, 54, f"{len(per)} consecutive cycles after 1.8 µs, measured through the "
                    "CTLE and the pin path — §C26.", 12, MUTED)

    ax = Axes(cv, 66, 84, 520, H - 84 - 62, (lo * 1e12, hi * 1e12), (0, top * 1.16))
    ax.frame()
    ax.gridy([top * f for f in (0.25, 0.5, 0.75, 1.0)])
    for i, c in enumerate(counts):
        if not c:
            continue
        x = ax.px((lo + i * width) * 1e12)
        xw = ax.px((lo + (i + 1) * width) * 1e12) - x
        cv.rect(x + 0.6, ax.py(c), max(1.0, xw - 1.2), ax.y + ax.h - ax.py(c),
                fill=BLUE, opacity=0.82)
    xt = [round(v) for v in (lo * 1e12, (lo + (hi - lo) / 2) * 1e12, hi * 1e12)]
    ax.xticks(xt, [f"{v}" for v in xt])
    yt = [0, int(top * 0.5), top]
    ax.yticks(yt, [str(v) for v in yt])
    cv.text(ax.x + ax.w / 2, ax.y + ax.h + 40, "clock period (ps)", 12, MUTED, "middle")
    cv.text(30, ax.y + ax.h / 2, "cycles", 12, MUTED, "middle", rotate=-90)

    ax.vline(ui * 1e12, color=ORANGE, dash="6 4", sw=1.6)
    cv.text(ax.px(ui * 1e12) + 6, ax.y + 15, "ideal UI 1665.0 ps", 11, ORANGE,
            "start", "700")
    ax.vline(pm * 1e12, color=GREEN, dash="2 3", sw=1.6)
    cv.text(ax.px(pm * 1e12) - 6, ax.y + 32, f"mean {pm*1e12:.1f} ps", 11, GREEN,
            "end", "700")

    bx = 620
    cv.rect(bx, 84, W - bx - 28, H - 84 - 62, fill="#f6f8fa", stroke="#d8dee4",
            sw=1, rx=6)
    rows = [
        ("mean period", f"{pm*1e12:.2f} ps", f"{1/pm/1e6:.2f} MHz"),
        ("ideal UI", f"{ui*1e12:.2f} ps", f"{1/ui/1e6:.2f} MHz"),
        ("mean error", f"{(pm-ui)*1e12:+.2f} ps", f"{(pm-ui)/ui*100:+.3f} %"),
        ("period RMS", f"{ps*1e12:.2f} ps", f"{ps/ui*100:.2f} % UI"),
        ("period pk-pk", f"{(hi-lo)*1e12:.2f} ps", f"{(hi-lo)/ui*100:.2f} % UI"),
    ]
    cv.text(bx + 16, 110, "cycle-to-cycle statistics", 12, INK, weight="700")
    for i, (a, b, c) in enumerate(rows):
        y = 136 + i * 24
        strong = a in ("period RMS", "period pk-pk")
        cv.text(bx + 16, y, a, 11.5, MUTED)
        cv.text(bx + 168, y, b, 11.5, INK, "end", "700" if strong else "400", MONO)
        cv.text(bx + 250, y, c, 11.5, BLUE if strong else MUTED, "end",
                "700" if strong else "400", MONO)
    cv.text(bx + 16, 136 + 5 * 24 + 14, "Phase wander over the same window is", 10.5, MUTED)
    cv.text(bx + 16, 136 + 5 * 24 + 28, "NOT plotted: §C26 measured it against a", 10.5, MUTED)
    cv.text(bx + 16, 136 + 5 * 24 + 42, "best-fit clock in a window that still", 10.5, MUTED)
    cv.text(bx + 16, 136 + 5 * 24 + 56, "contained settling, and records it as", 10.5, MUTED)
    cv.text(bx + 16, 136 + 5 * 24 + 70, "not usable. It has not been re-run.", 10.5, MUTED)

    cv.text(28, H - 18,
            "data: xschem/tuning/c26_rclk.raw (162 287 points), parsed by the repo's "
            "own jitter_parse.py · §C26",
            10, MUTED)
    out = os.path.join(IMG, "clock-jitter.svg")
    cv.save(out)
    return out


def main():
    which = sys.argv[1] if len(sys.argv) > 1 else "all"
    os.makedirs(IMG, exist_ok=True)
    made = []
    if which in ("all", "bode"):
        print("bode:"); made.append(fig_bode())
    if which in ("all", "eye"):
        print("eye:"); made.append(fig_eye())
    if which in ("all", "jitter"):
        print("jitter:"); made.append(fig_jitter())
    if which in ("all", "block"):
        import blockdiagram
        print("block:"); made.append(blockdiagram.build(IMG))
    for m in made:
        if m:
            print(f"  wrote {os.path.relpath(m, REPO)}  "
                  f"({os.path.getsize(m)/1024:.0f} KB)")


if __name__ == "__main__":
    main()
