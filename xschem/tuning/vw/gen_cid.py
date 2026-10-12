#!/usr/bin/env python3
"""CID stress for the CML chain with the scaled loop filter.

    gen_cid.py       # writes cid_stim.inc, cid_layout.txt and decks/CID_scaled.spice

PRBS7 with runs of consecutive identical digits inserted: 300 bits of PRBS to
settle (the deck starts near lock, like S1), then runs of 5, 10, 15, 20 and 30
identical bits, each followed by 100 bits of PRBS to recover. During a run the
bang-bang PD gets no information and the VCO coasts on C1's voltage, so this
is where the scaled filter (smaller R, bigger C1) could differ from the old
one. Same Vdata/dsrc format as ../e2e_prbs6u.inc. cid_analyze.py reads the
layout file to find the runs. Pure stdlib (../../../CLAUDE.md).
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "cml"))
from gen_cml import prbs7, UI  # noqa: E402

RUNS = [5, 10, 15, 20, 30]
TR = 100e-12


def bits_and_layout():
    src = prbs7(2000)
    pos = 0
    bits = src[pos:pos + 300]
    pos += 300
    layout = []
    for r in RUNS:
        v = 1 - bits[-1]                 # start the run with a transition
        layout.append((len(bits), r))
        bits += [v] * r
        nxt = src[pos:pos + 100]
        pos += 100
        if nxt[0] == v:                  # end the run with a transition
            nxt[0] = 1 - v
        bits += nxt
    bits += src[pos:pos + 50]
    return bits, layout


def main(base="S1_scaled", out="CID_scaled"):
    bits, layout = bits_and_layout()
    pts = [(0.0, bits[0])]
    for n in range(1, len(bits)):
        if bits[n] != bits[n - 1]:
            pts += [(n * UI, bits[n - 1]), (n * UI + TR, bits[n])]
    pts.append((len(bits) * UI, bits[-1]))
    with open(os.path.join(HERE, "cid_stim.inc"), "w") as fh:
        fh.write(f"* CID stress: PRBS7 + runs {RUNS}, {len(bits)} bits, UI={UI*1e9:.4f} ns, tr={TR*1e12:.0f} ps\n")
        fh.write(f".param ui={UI:.4e} tsim={len(bits) * UI:.4e}\n")
        fh.write("Vdata dsrc 0 PWL(\n")
        fh.writelines(f"+ {t:.6e} {float(v):.1f}\n" for t, v in pts)
        fh.write("+ )\n")
    with open(os.path.join(HERE, "cid_layout.txt"), "w") as fh:
        fh.writelines(f"{start} {length}\n" for start, length in layout)
    deck = open(os.path.join(HERE, "decks", f"{base}.spice")).read()
    prbs = os.path.join(os.path.dirname(HERE), "e2e_prbs6u.inc")
    assert prbs in deck and "tran 20p 1500n" in deck
    deck = deck.replace(prbs, os.path.join(HERE, "cid_stim.inc"))
    deck = deck.replace("tran 20p 1500n", f"tran 20p {len(bits) * UI * 1e9:.0f}n")
    deck = deck.replace(f"{base}_chain.raw", f"{out}_chain.raw").replace(f"{base}.dat", f"{out}.dat")
    deck = "* CID stress (gen_cid.py) on " + base + "\n" + deck
    assert f"{out}.dat" in deck
    with open(os.path.join(HERE, "decks", f"{out}.spice"), "w") as fh:
        fh.write(deck)
    print(f"{len(bits)} bits = {len(bits) * UI * 1e9:.0f} ns; runs at bit {layout}")


if __name__ == "__main__":
    # the final designs: python3 gen_cid.py S3_full CID_full ; python3 gen_cid.py S3_buf CID_buf
    main(*sys.argv[1:3]) if len(sys.argv) > 2 else main()
