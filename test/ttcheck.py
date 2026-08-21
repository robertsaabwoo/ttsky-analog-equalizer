"""Small pure-stdlib helpers shared by the repository-consistency tests.

Everything here is parsing of files that are already in the repository:
no PDK, no simulator, no network.  The only third-party import in the whole
test suite is PyYAML, in the tests that read ``info.yaml``.
"""

from __future__ import annotations

import re
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent

XSCHEM = REPO / "xschem"
ATTIC = XSCHEM / "attic"
MAG = REPO / "mag"
DOCS = REPO / "docs"

#: Symbol libraries that live outside this repository (the xschem stock library
#: and the sky130 PDK).  References to them are resolved by
#: ``XSCHEM_LIBRARY_PATH`` at netlist time and cannot be checked here.
EXTERNAL_SYMBOL_PREFIXES = ("devices/", "sky130_fd_pr/", "sky130_stdcells/")

#: The chip top level, per ``xschem/STATUS.md``.
TOP_SCH = XSCHEM / "ctle_cdr_rx.sch"

#: The one-instance wrapper that is netlisted to produce a ``.subckt`` for LVS.
LVS_WRAPPER_SCH = XSCHEM / "ctle_cdr_rx_lvs.sch"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


# --------------------------------------------------------------------------
# xschem file parsing
#
# An xschem .sch file places a symbol with a line of the form
#     C {some_symbol.sym} <x> <y> <rot> <flip> {name=x1 ...}
# and a .sym file declares a pin with
#     B 5 <coords> {name=vinp dir=in}
# --------------------------------------------------------------------------

_INSTANCE_RE = re.compile(r"^C\s*\{([^}]*)\}(.*)$")
_NAME_RE = re.compile(r"\bname=([^\s}]+)")
_LAB_RE = re.compile(r"\blab=([^\s}]+)")
_PIN_RE = re.compile(r"^B\s+5\s+\S+\s+\S+\s+\S+\s+\S+\s*\{([^}]*)\}")
_DIR_RE = re.compile(r"\bdir=([^\s}]+)")


def sch_instances(sch: Path) -> list[tuple[str, str]]:
    """Return ``[(symbol, instance_name), ...]`` for a schematic."""
    out = []
    for line in read(sch).splitlines():
        m = _INSTANCE_RE.match(line.strip())
        if not m:
            continue
        symbol = m.group(1).strip()
        name = _NAME_RE.search(m.group(2))
        out.append((symbol, name.group(1) if name else ""))
    return out


def sch_child_symbols(sch: Path) -> list[str]:
    """Symbols instantiated by ``sch``, excluding stock/PDK library symbols."""
    return [
        sym
        for sym, _ in sch_instances(sch)
        if not sym.startswith(EXTERNAL_SYMBOL_PREFIXES)
    ]


def sch_ports(sch: Path) -> list[tuple[str, str]]:
    """Return ``[(direction, label), ...]`` for the ipin/opin/iopin of a sheet."""
    kinds = {"devices/ipin.sym": "in", "devices/opin.sym": "out",
             "devices/iopin.sym": "inout"}
    out = []
    for line in read(sch).splitlines():
        m = _INSTANCE_RE.match(line.strip())
        if not m:
            continue
        kind = kinds.get(m.group(1).strip())
        if kind is None:
            continue
        lab = _LAB_RE.search(m.group(2))
        if lab:
            out.append((kind, lab.group(1)))
    return out


def sym_pins(sym: Path) -> list[tuple[str, str]]:
    """Return ``[(name, dir), ...]`` in declaration order for a symbol."""
    out = []
    for line in read(sym).splitlines():
        m = _PIN_RE.match(line.strip())
        if not m:
            continue
        attrs = m.group(1)
        name = _NAME_RE.search(attrs)
        direction = _DIR_RE.search(attrs)
        if name:
            out.append((name.group(1), direction.group(1) if direction else ""))
    return out


def resolve_symbol(symbol: str) -> Path | None:
    """Resolve a local symbol reference the way XSCHEM_LIBRARY_PATH does.

    ``xschem/xschemrc`` puts both ``xschem/`` and ``xschem/attic/`` on the
    library path, in that order.  A symbol that resolves in neither is a
    dangling reference: xschem netlists it *silently* as a missing subcircuit,
    which is exactly the failure this lets us catch cheaply.
    """
    for base in (XSCHEM, ATTIC):
        candidate = base / symbol
        if candidate.is_file():
            return candidate
    return None


def walk_hierarchy(top: Path) -> tuple[dict[str, Path], list[tuple[str, str]]]:
    """Depth-first walk of the design hierarchy below ``top``.

    Returns ``(resolved, dangling)`` where ``resolved`` maps every reachable
    local symbol name to its file, and ``dangling`` lists
    ``(parent_schematic, unresolved_symbol)`` pairs.
    """
    resolved: dict[str, Path] = {}
    dangling: list[tuple[str, str]] = []

    def visit(sch: Path) -> None:
        for symbol in sch_child_symbols(sch):
            if symbol in resolved:
                continue
            path = resolve_symbol(symbol)
            if path is None:
                dangling.append((sch.name, symbol))
                continue
            resolved[symbol] = path
            child_sch = path.with_suffix(".sch")
            if child_sch.is_file():
                visit(child_sch)

    visit(top)
    return resolved, dangling


# --------------------------------------------------------------------------
# Verilog parsing (structural blackbox only -- src/project.v has no logic)
# --------------------------------------------------------------------------

def verilog_modules(text: str) -> dict[str, list[str]]:
    """Return ``{module_name: [port, ...]}`` for every module in ``text``."""
    text = re.sub(r"//[^\n]*", "", text)
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    modules = {}
    for m in re.finditer(r"\bmodule\s+(\w+)\s*\((.*?)\)\s*;", text, flags=re.S):
        ports = []
        for chunk in m.group(2).split(","):
            words = re.findall(r"[\w$]+", chunk)
            if words:
                ports.append(words[-1])
        modules[m.group(1)] = ports
    return modules


def verilog_bits_used(text: str, bus: str) -> set[int]:
    """Indices of ``bus`` that appear anywhere in the (comment-stripped) source."""
    text = re.sub(r"//[^\n]*", "", text)
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    text = re.sub(r"\b(input|output|inout)\b[^;]*;", "", text)
    return {int(i) for i in re.findall(rf"\b{re.escape(bus)}\s*\[\s*(\d+)\s*\]", text)}


# --------------------------------------------------------------------------
# Design-log section indices, used by the documentation tests
# --------------------------------------------------------------------------

CDR_NOTES = XSCHEM / "tuning" / "NOTES.md"
CTLE_NOTES = XSCHEM / "tuning" / "ctle" / "NOTES_CTLE.md"

CDR_HEADING_RE = re.compile(r"^#+\s*§?(\d+)[a-z]?[.\s]")
CTLE_HEADING_RE = re.compile(r"^#+\s*§?C(\d+)\b")


def notes_sections(path: Path, pattern: re.Pattern) -> set[int]:
    return {
        int(m.group(1))
        for line in read(path).splitlines()
        if (m := pattern.match(line.strip()))
    }


def cited_sections(text: str) -> tuple[set[int], set[int]]:
    """Return ``(cdr_sections, ctle_sections)`` cited as §N / §CN in ``text``."""
    cdr, ctle = set(), set()
    for m in re.finditer(r"§\s*(C?)(\d+)", text):
        (ctle if m.group(1) else cdr).add(int(m.group(2)))
    return cdr, ctle
