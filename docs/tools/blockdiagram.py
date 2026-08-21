#!/usr/bin/env python3
"""Hand-authored block diagram of the receiver signal path.

This figure contains no simulated waveforms; the only numbers on it are
measured values quoted from the design log, each labelled with its section.
"""

import os

from svgplot import (BLUE, GREEN, INK, MONO, MUTED, ORANGE, PURPLE, RED, SLATE,
                     Canvas)

EDGE = "#c8d1da"
FILL = "#f6f8fa"


def box(cv, x, y, w, h, title, lines=(), accent=INK, fill=FILL, tsize=13):
    cv.rect(x, y, w, h, fill=fill, stroke=accent, sw=1.6, rx=7)
    cv.rect(x, y, 4, h, fill=accent, rx=2)
    cv.text(x + w / 2, y + 21, title, tsize, INK, "middle", "700")
    for i, ln in enumerate(lines):
        cv.text(x + w / 2, y + 39 + i * 14, ln, 10.5, MUTED, "middle")


def arrow(cv, x1, y1, x2, y2, color=SLATE, sw=1.8, head=7, dash=None):
    import math
    ang = math.atan2(y2 - y1, x2 - x1)
    bx, by = x2 - head * math.cos(ang), y2 - head * math.sin(ang)
    cv.line(x1, y1, bx, by, color, sw, dash, cap="round")
    p = [(x2, y2),
         (x2 - head * math.cos(ang - 0.42), y2 - head * math.sin(ang - 0.42)),
         (x2 - head * math.cos(ang + 0.42), y2 - head * math.sin(ang + 0.42))]
    pts = " ".join(f"{a:.1f},{b:.1f}" for a, b in p)
    cv.add(f'<polygon points="{pts}" fill="{color}"/>')


def build(imgdir):
    W, H = 1000, 545
    cv = Canvas(W, H, "CTLE + CDR receiver signal path",
                "Block diagram of the analog receiver front end")
    cv.card()
    cv.text(28, 34, "600 Mb/s analog receiver front end", 17, INK, weight="700")
    cv.text(28, 55, "The channel is the chip's own analog pin. There is no reference "
                    "clock anywhere on the die — the output clock is recovered from the data.",
            11.5, MUTED)

    # ---------------- tier 1: the chain -----------------------------------
    ytop, bh = 92, 66
    cv.text(26, ytop + 24, "ua[0]", 12, INK, "start", "700", MONO)
    cv.text(26, ytop + 42, "ua[1]", 12, INK, "start", "700", MONO)
    cv.text(26, ytop + 60, "ua[2]", 12, MUTED, "start", "400", MONO)
    cv.text(26, ytop + 76, "vbias", 9.5, MUTED)
    arrow(cv, 76, ytop + 20, 96, ytop + 26)
    arrow(cv, 76, ytop + 38, 96, ytop + 36)

    box(cv, 96, ytop, 148, bh, "analog pin path",
        ("500 Ω / 5 pF (TT spec bound)", "pole 63.7 MHz · −13.7 dB @ Nyquist"), RED)
    arrow(cv, 244, ytop + bh / 2, 288, ytop + bh / 2)
    cv.text(266, ytop + bh / 2 - 12, "64 mV", 10.5, RED, "middle", "700")
    cv.text(266, ytop + bh / 2 + 26, "eye shut", 10, RED, "middle")

    box(cv, 288, ytop, 138, bh, "CTLE",
        ("degenerated diff pair", "+13.3 dB @ Nyquist"), BLUE)
    arrow(cv, 426, ytop + bh / 2, 470, ytop + bh / 2)
    cv.text(448, ytop + bh / 2 - 12, "299 mV", 10.5, BLUE, "middle", "700")
    cv.text(448, ytop + bh / 2 + 26, "eye open", 10, BLUE, "middle")

    box(cv, 470, ytop, 148, bh, "CDR",
        ("bang-bang, reference-less", "locks at 600.64 MHz"), GREEN)
    arrow(cv, 618, ytop + bh / 2, 662, ytop + bh / 2)

    box(cv, 662, ytop, 128, bh, "output buffers",
        ("2 × tapered", "inverter chain"), SLATE)
    arrow(cv, 790, ytop + 24, 822, ytop + 24)
    arrow(cv, 790, ytop + 44, 822, ytop + 44)
    cv.text(828, ytop + 22, "uo[0]", 11.5, INK, "start", "700", MONO)
    cv.text(872, ytop + 22, "recovered clock", 10.5, MUTED)
    cv.text(828, ytop + 42, "uo[1]", 11.5, INK, "start", "700", MONO)
    cv.text(872, ytop + 42, "inverted phase", 10.5, MUTED)
    cv.text(828, ytop + 60, "600.64 MHz, full rate", 9.5, MUTED)

    # vbias reaches the CTLE and the phase-detector latches; route it clear of
    # the signal boxes rather than implying it goes through the pin path.
    cv.line(72, ytop + 56, 72, ytop + 98, PURPLE, 1.2, dash="4 3")
    cv.line(72, ytop + 98, 357, ytop + 98, PURPLE, 1.2, dash="4 3")
    arrow(cv, 357, ytop + 98, 357, ytop + bh + 2, PURPLE, 1.2, dash="4 3")

    # ---------------- tier 2: inside the CDR ------------------------------
    py = 216
    cv.rect(26, py, W - 52, 250, fill="#fbfcfd", stroke=EDGE, sw=1.2, rx=8)
    cv.text(42, py + 24, "inside the CDR", 13, INK, weight="700")
    cv.text(150, py + 24, "— the phase detector reports only early/late, never "
                          "frequency, and everything awkward about the loop follows from that",
            10.5, MUTED)

    by, bh2 = py + 44, 64
    box(cv, 112, by, 190, bh2, "Alexander phase detector",
        ("4 × D flip-flop + 2 × XOR", "samples on both clock edges"), GREEN,
        "#ffffff", 12)
    box(cv, 346, by, 142, bh2, "charge pump",
        ("1.26 µA up / 1.28 µA dn", "1.6 % mismatch, measured"), GREEN, "#ffffff", 12)
    box(cv, 524, by, 142, bh2, "loop filter",
        ("~10× smaller than the", "PLL it came from"), GREEN, "#ffffff", 12)
    box(cv, 702, by, 168, bh2, "5-stage ring VCO",
        ("differential", "514–621 MHz at tt / 27 °C"), GREEN, "#ffffff", 12)

    arrow(cv, 302, by + bh2 / 2, 346, by + bh2 / 2)
    cv.text(324, by + bh2 / 2 - 9, "up / dn", 9.5, MUTED, "middle")
    arrow(cv, 488, by + bh2 / 2, 524, by + bh2 / 2)
    arrow(cv, 666, by + bh2 / 2, 702, by + bh2 / 2)
    cv.text(684, by + bh2 / 2 - 9, "vctrl", 9.5, INK, "middle", "700", MONO)
    cv.text(684, by + bh2 / 2 + 20, "0.791 V", 9.5, MUTED, "middle")

    # equalized data into the detector
    arrow(cv, 88, by + bh2 / 2, 112, by + bh2 / 2, BLUE)
    cv.text(60, by + bh2 / 2 - 6, "equalized", 9.5, BLUE, "middle")
    cv.text(60, by + bh2 / 2 + 8, "data", 9.5, BLUE, "middle")

    # recovered clock out of the loop
    arrow(cv, 870, by + bh2 / 2, 900, by + bh2 / 2, SLATE)
    cv.text(936, by + bh2 / 2 + 4, "to buffers", 10, MUTED, "middle")

    # startup precharge hangs off the vctrl node, above the feedback path
    px, pw, pyy = 613, 142, by + bh2 + 18
    box(cv, px, pyy, pw, 52, "startup precharge",
        ("seeds vctrl ~130 ns,", "then removes itself"), PURPLE, "#ffffff", 12)
    arrow(cv, px + pw / 2, pyy, px + pw / 2, by + bh2 + 2, PURPLE, 1.6, dash="4 3")
    cv.text(px + pw / 2, pyy + 66, "45/45 PVT corners, cold start", 9.5, PURPLE,
            "middle")

    # feedback: the recovered clock is the sampling clock
    fy = by + bh2 + 108
    cv.line(786, by + bh2, 786, fy, SLATE, 1.8)
    cv.line(786, fy, 207, fy, SLATE, 1.8)
    arrow(cv, 207, fy, 207, by + bh2 + 2, SLATE)
    cv.text(497, fy - 8, "the recovered clock is the sampling clock", 10.5,
            SLATE, "middle")

    cv.text(28, H - 16,
            "measured values: §C16 (channel) · §C18/§C20 (CTLE) · §C23 (end-to-end "
            "lock) · §C25-E (charge pump) · §20a/§20b (precharge, VCO) — see "
            "docs/DESIGN.md",
            10, MUTED)

    out = os.path.join(imgdir, "block-diagram.svg")
    cv.save(out)
    return out


if __name__ == "__main__":
    import sys
    here = os.path.dirname(os.path.abspath(__file__))
    sys.path.insert(0, here)
    print(build(os.path.join(os.path.dirname(here), "img")))
