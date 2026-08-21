#!/usr/bin/env python3
"""Sanity-check a generated SVG without a renderer.

    python3 docs/tools/check_svg.py docs/img/*.svg

There is no rasteriser on this VM, so the figures are validated structurally
instead: the file must be well-formed XML, declare a viewBox, carry an opaque
background rect (so it stays readable on GitHub's dark theme) and keep every
drawn coordinate inside the canvas. Overflowing text is the failure mode this
actually catches.
"""

import sys
import xml.etree.ElementTree as ET

NS = "{http://www.w3.org/2000/svg}"


def numbers(el):
    """Yield (x, y) pairs a renderer would place ink at, for one element."""
    tag = el.tag[len(NS):] if el.tag.startswith(NS) else el.tag
    g = lambda k, d=0.0: float(el.get(k, d))
    if tag == "rect":
        yield g("x"), g("y")
        yield g("x") + g("width"), g("y") + g("height")
    elif tag == "line":
        yield g("x1"), g("y1")
        yield g("x2"), g("y2")
    elif tag == "circle":
        yield g("cx") - g("r"), g("cy") - g("r")
        yield g("cx") + g("r"), g("cy") + g("r")
    elif tag == "text":
        # approximate the drawn extent so a label that runs off the card is
        # caught; 0.52 em per character is conservative for this sans stack.
        size = float(el.get("font-size", 12))
        w = 0.52 * size * len(el.text or "")
        anchor = el.get("text-anchor", "start")
        x = g("x") - (w if anchor == "end" else w / 2 if anchor == "middle" else 0)
        yield x, g("y")
        yield x + w, g("y")
    elif tag == "polyline":
        for pair in el.get("points", "").split():
            x, _, y = pair.partition(",")
            if y:
                yield float(x), float(y)


def check(path, slack=1.0):
    problems = []
    try:
        root = ET.parse(path).getroot()
    except ET.ParseError as e:
        return [f"not well-formed XML: {e}"], {}
    if not root.get("viewBox"):
        problems.append("no viewBox")
    w, h = float(root.get("width")), float(root.get("height"))

    kinds = {}
    opaque_bg = False
    outside = 0
    worst = None
    for el in root.iter():
        tag = el.tag[len(NS):] if el.tag.startswith(NS) else el.tag
        kinds[tag] = kinds.get(tag, 0) + 1
        if tag == "rect" and el.get("fill", "none") not in ("none",) \
                and float(el.get("width", 0)) >= w - 2 \
                and float(el.get("height", 0)) >= h - 2:
            opaque_bg = True
        if el.get("transform"):          # rotated labels: bounds do not apply
            continue
        for x, y in numbers(el):
            if x != x or y != y:
                problems.append(f"NaN coordinate in <{tag}>")
                break
            if x < -slack or y < -slack or x > w + slack or y > h + slack:
                outside += 1
                d = max(-x, -y, x - w, y - h)
                if worst is None or d > worst[0]:
                    worst = (d, tag, x, y, el.get("fill") or el.get("stroke"))
    if not opaque_bg:
        problems.append("no full-size opaque background rect (unreadable in dark mode)")
    if outside:
        d, tag, x, y, col = worst
        problems.append(f"{outside} coordinate(s) outside the {w:.0f}x{h:.0f} canvas; "
                        f"worst <{tag}> at ({x:.1f},{y:.1f}), {d:.1f} px over")
    return problems, kinds


def main():
    bad = 0
    for path in sys.argv[1:]:
        problems, kinds = check(path)
        size = __import__("os").path.getsize(path) / 1024
        summary = " ".join(f"{k}={v}" for k, v in sorted(kinds.items()) if k != "svg")
        if problems:
            bad += 1
            print(f"FAIL {path}  ({size:.0f} KB)")
            for p in problems:
                print(f"       - {p}")
        else:
            print(f"ok   {path}  ({size:.0f} KB)  {summary}")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
