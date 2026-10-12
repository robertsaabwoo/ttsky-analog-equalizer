#!/usr/bin/env python3
"""B4 table: per corner, old buffer (o) vs cml_clkbuf on cml_bias (n). Pure stdlib."""
import glob
import os
import re

print(f"{'corner':10s} | {'buf':3s} f(MHz)  ck pp   ck min..max   rclk pp  I_buf(uA)  I_pd(uA)")
for log in sorted(glob.glob(os.path.join(os.path.dirname(os.path.abspath(__file__)), "B4_*.log"))):
    tag = re.match(r".*B4_(.*)\.log", log).group(1)
    v = {}
    for line in open(log):
        m = re.match(r"([on])(f_mhz|ck_pp|ck_min|ck_max|rp_pp|i_buf|i_pd)\s+=\s+([-\d.e+]+)", line)
        if m:
            v[m.group(1) + m.group(2)] = float(m.group(3))
    for p, name in (("o", "old"), ("n", "new")):
        g = lambda k: v.get(p + k, float("nan"))
        print(f"{tag:10s} | {name:3s} {g('f_mhz'):6.1f}  {g('ck_pp'):.3f}  {g('ck_min'):.3f}..{g('ck_max'):.3f}  "
              f"{g('rp_pp'):.2f}    {-g('i_buf') * 1e6:6.1f}    {-g('i_pd') * 1e6:6.1f}")
