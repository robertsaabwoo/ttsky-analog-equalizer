#!/usr/bin/env python3
"""A very small pure-stdlib SVG plotting helper.

numpy and matplotlib are not installed on this VM and must not be (see
../../CLAUDE.md), so the figures in ../img/ are emitted as SVG text directly.
This module is deliberately minimal: a canvas, linear/log axes, polylines,
markers and text. It is enough for a Bode plot, an eye diagram and a histogram.

Every figure paints an explicit light background and uses explicitly coloured
strokes, because GitHub renders README images on both light and dark page
backgrounds and does not put a card behind them: an SVG that relies on the
default black-on-transparent disappears in dark mode.
"""

from math import log10

FONT = "ui-sans-serif, -apple-system, 'Segoe UI', Helvetica, Arial, sans-serif"
MONO = "ui-monospace, 'SF Mono', Menlo, Consolas, monospace"

# A palette that stays legible on the light card below, in both GitHub themes.
BG = "#ffffff"
CARD_EDGE = "#d0d7de"
INK = "#1b1f24"
MUTED = "#57606a"
GRID = "#e4e8ec"
AXIS = "#8c959f"

RED = "#c0392b"      # the channel / loss
BLUE = "#1f6feb"     # the equalizer
GREEN = "#1a7f37"    # the corrected result
PURPLE = "#8250df"   # the as-drawn (pre-retune) circuit
ORANGE = "#bc4c00"
SLATE = "#6e7781"


def _n(v):
    """Compact fixed-point number for SVG path data."""
    s = f"{v:.1f}"
    return s[:-2] if s.endswith(".0") else s


def esc(s):
    return (str(s).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;"))


class Canvas:
    def __init__(self, w, h, title="", desc=""):
        self.w, self.h = w, h
        self.parts = []
        self.title, self.desc = title, desc

    def add(self, s):
        self.parts.append(s)

    def rect(self, x, y, w, h, fill="none", stroke=None, sw=1, rx=0, opacity=None):
        st = f' stroke="{stroke}" stroke-width="{sw}"' if stroke else ""
        op = f' opacity="{opacity}"' if opacity is not None else ""
        self.add(f'<rect x="{_n(x)}" y="{_n(y)}" width="{_n(w)}" height="{_n(h)}"'
                 f' rx="{rx}" fill="{fill}"{st}{op}/>')

    def line(self, x1, y1, x2, y2, stroke=INK, sw=1, dash=None, opacity=None, cap="butt"):
        d = f' stroke-dasharray="{dash}"' if dash else ""
        op = f' opacity="{opacity}"' if opacity is not None else ""
        self.add(f'<line x1="{_n(x1)}" y1="{_n(y1)}" x2="{_n(x2)}" y2="{_n(y2)}"'
                 f' stroke="{stroke}" stroke-width="{sw}" stroke-linecap="{cap}"{d}{op}/>')

    def polyline(self, pts, stroke=INK, sw=1.2, dash=None, opacity=None, fill="none"):
        if len(pts) < 2:
            return
        d = f' stroke-dasharray="{dash}"' if dash else ""
        op = f' opacity="{opacity}"' if opacity is not None else ""
        s = " ".join(f"{_n(x)},{_n(y)}" for x, y in pts)
        self.add(f'<polyline points="{s}" fill="{fill}" stroke="{stroke}"'
                 f' stroke-width="{sw}" stroke-linejoin="round" stroke-linecap="round"{d}{op}/>')

    def circle(self, cx, cy, r, fill=INK, stroke=None, sw=1):
        st = f' stroke="{stroke}" stroke-width="{sw}"' if stroke else ""
        self.add(f'<circle cx="{_n(cx)}" cy="{_n(cy)}" r="{_n(r)}" fill="{fill}"{st}/>')

    def text(self, x, y, s, size=12, fill=INK, anchor="start", weight="400",
             family=FONT, opacity=None, rotate=None):
        op = f' opacity="{opacity}"' if opacity is not None else ""
        tr = f' transform="rotate({rotate} {_n(x)} {_n(y)})"' if rotate else ""
        self.add(f'<text x="{_n(x)}" y="{_n(y)}" font-family="{family}"'
                 f' font-size="{size}" font-weight="{weight}" fill="{fill}"'
                 f' text-anchor="{anchor}"{op}{tr}>{esc(s)}</text>')

    def card(self):
        """Opaque background so the figure is readable in dark mode too."""
        self.rect(0, 0, self.w, self.h, fill=BG, stroke=CARD_EDGE, sw=1, rx=8)

    def render(self):
        head = (f'<svg xmlns="http://www.w3.org/2000/svg" width="{self.w}"'
                f' height="{self.h}" viewBox="0 0 {self.w} {self.h}" role="img">')
        meta = ""
        if self.title:
            meta += f"<title>{esc(self.title)}</title>"
        if self.desc:
            meta += f"<desc>{esc(self.desc)}</desc>"
        return head + meta + "".join(self.parts) + "</svg>\n"

    def save(self, path):
        with open(path, "w", encoding="utf-8") as f:
            f.write(self.render())
        return path


class Axes:
    """A rectangular plot region with linear or log-x mapping."""

    def __init__(self, cv, x, y, w, h, xr, yr, xlog=False):
        self.cv, self.x, self.y, self.w, self.h = cv, x, y, w, h
        self.x0, self.x1 = xr
        self.y0, self.y1 = yr
        self.xlog = xlog

    def px(self, v):
        if self.xlog:
            t = (log10(v) - log10(self.x0)) / (log10(self.x1) - log10(self.x0))
        else:
            t = (v - self.x0) / (self.x1 - self.x0)
        return self.x + t * self.w

    def py(self, v):
        t = (v - self.y0) / (self.y1 - self.y0)
        return self.y + self.h - t * self.h

    def frame(self, fill="#fcfcfd"):
        self.cv.rect(self.x, self.y, self.w, self.h, fill=fill, stroke=AXIS, sw=1)

    def gridx(self, vals):
        for v in vals:
            self.cv.line(self.px(v), self.y, self.px(v), self.y + self.h, GRID, 1)

    def gridy(self, vals):
        for v in vals:
            self.cv.line(self.x, self.py(v), self.x + self.w, self.py(v), GRID, 1)

    def xticks(self, vals, labels=None, size=11):
        labels = labels or [str(v) for v in vals]
        for v, lab in zip(vals, labels):
            px = self.px(v)
            self.cv.line(px, self.y + self.h, px, self.y + self.h + 4, AXIS, 1)
            self.cv.text(px, self.y + self.h + 17, lab, size, MUTED, "middle")

    def yticks(self, vals, labels=None, size=11):
        labels = labels or [str(v) for v in vals]
        for v, lab in zip(vals, labels):
            py = self.py(v)
            self.cv.line(self.x - 4, py, self.x, py, AXIS, 1)
            self.cv.text(self.x - 8, py + 4, lab, size, MUTED, "end")

    def plot(self, xs, ys, stroke=INK, sw=1.6, dash=None, opacity=None):
        self.cv.polyline([(self.px(a), self.py(b)) for a, b in zip(xs, ys)],
                         stroke, sw, dash, opacity)

    def clipped_plot(self, xs, ys, **kw):
        """Drop points outside the y range instead of drawing off-frame."""
        run = []
        for a, b in zip(xs, ys):
            if self.y0 <= b <= self.y1 and self.x0 <= a <= self.x1:
                run.append((a, b))
            elif run:
                self.plot([p[0] for p in run], [p[1] for p in run], **kw)
                run = []
        if run:
            self.plot([p[0] for p in run], [p[1] for p in run], **kw)

    def marker(self, x, y, color=INK, r=4.5, label=None, dx=9, dy=4, size=11,
               anchor="start", weight="600"):
        self.cv.circle(self.px(x), self.py(y), r, fill=color, stroke="#ffffff", sw=1.6)
        if label:
            self.cv.text(self.px(x) + dx, self.py(y) + dy, label, size, color,
                         anchor, weight)

    def errbar(self, x, lo, hi, color=INK, cap=5, sw=2):
        px = self.px(x)
        self.cv.line(px, self.py(lo), px, self.py(hi), color, sw)
        for v in (lo, hi):
            self.cv.line(px - cap, self.py(v), px + cap, self.py(v), color, sw)

    def vline(self, x, color=SLATE, dash="5 4", sw=1.4):
        self.cv.line(self.px(x), self.y, self.px(x), self.y + self.h, color, sw, dash)

    def hline(self, y, color=SLATE, dash="5 4", sw=1.4):
        self.cv.line(self.x, self.py(y), self.x + self.w, self.py(y), color, sw, dash)


def legend(cv, x, y, entries, size=11.5, gap=17, swatch=16):
    """entries: [(label, color, dash|None), ...]"""
    for i, (lab, color, dash) in enumerate(entries):
        yy = y + i * gap
        cv.line(x, yy, x + swatch, yy, color, 2.4, dash)
        cv.text(x + swatch + 7, yy + 4, lab, size, INK)
