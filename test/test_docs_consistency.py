"""Documentation checks: no template residue, no stale references.

The design logs under ``xschem/tuning/`` are the substance of this project and
the front-page documentation cites them heavily.  Citations rot: sections get
renumbered, files get moved to ``xschem/attic/``, and a README that points at
something that no longer exists is worse than one that says nothing.  These
tests keep the prose honest against the repository it describes.
"""

import re
import unittest

import yaml

from ttcheck import (
    CDR_NOTES,
    CTLE_NOTES,
    DOCS,
    REPO,
    CDR_HEADING_RE,
    CTLE_HEADING_RE,
    cited_sections,
    notes_sections,
    read,
)

#: Prose files that are read by a human landing on the repository.
PROSE_FILES = ["README.md", "docs/info.md", "docs/DESIGN.md"]

#: Template text that Tiny Tapeout ships in docs/info.md.  Any of it left in
#: place means the datasheet was never actually written.
TEMPLATE_MARKERS = [
    "Please fill in the information below",
    "delete any unused sections",
    "Explain how your project works",
    "Explain how to use your project",
    "TODO",
    "FIXME",
    "Add a description of your project here",
    "List external hardware used in your project",
]

#: Paths that are deliberately absent from a fresh clone: build products and
#: gitignored simulation outputs.  Referencing them in prose is fine; asserting
#: they exist is not.
GENERATED_PATH_PREFIXES = (
    "gds/",
    "lef/",
    "xschem/simulation/",
    "xschem/tuning/pvt/decks/",
    "xschem/tuning/pvt/results/",
    "xschem/tuning/pvt/.netlists/",
)

PATH_EXTENSIONS = (
    ".md", ".sch", ".sym", ".v", ".py", ".sh", ".yaml", ".yml", ".spice",
    ".inc", ".mag", ".tcl", ".txt", ".def", ".gds", ".lef",
)

_CODE_SPAN_RE = re.compile(r"`([^`\n]+)`")


def code_spans(text):
    return _CODE_SPAN_RE.findall(text)


def looks_like_repo_path(span):
    if "/" not in span or "*" in span or " " in span:
        return False
    if span.startswith(("http", "#", "~", "$")):
        return False
    if span.endswith("/"):
        return True
    return span.endswith(PATH_EXTENSIONS)


class DatasheetTemplate(unittest.TestCase):
    """docs/info.md is the project datasheet, not the template it came from."""

    @classmethod
    def setUpClass(cls):
        cls.text = read(DOCS / "info.md")

    def test_no_template_comment_block(self):
        self.assertNotIn(
            "<!---", self.text,
            "docs/info.md still carries the Tiny Tapeout template comment block",
        )

    def test_no_template_placeholders(self):
        for marker in TEMPLATE_MARKERS:
            self.assertNotIn(
                marker.lower(), self.text.lower(),
                f"docs/info.md still contains template text: {marker!r}",
            )

    def test_required_datasheet_sections(self):
        for heading in ("## How it works", "## How to test", "## External hardware"):
            self.assertIn(heading, self.text, f"docs/info.md is missing {heading!r}")

    def test_title_and_description_are_not_repeated_verbatim(self):
        # A datasheet whose body is just info.yaml's description pasted back in
        # tells a reader nothing new.
        info = yaml.safe_load(read(REPO / "info.yaml"))
        self.assertNotIn(info["project"]["description"], self.text)


class Citations(unittest.TestCase):
    """Every section cited in the prose exists in the design logs."""

    @classmethod
    def setUpClass(cls):
        cls.cdr_sections = notes_sections(CDR_NOTES, CDR_HEADING_RE)
        cls.ctle_sections = notes_sections(CTLE_NOTES, CTLE_HEADING_RE)

    def test_the_logs_still_have_sections(self):
        # Guards the parser itself: if these ever come back empty the citation
        # tests below would pass vacuously.
        self.assertGreater(len(self.cdr_sections), 10)
        self.assertGreater(len(self.ctle_sections), 10)

    def test_cited_sections_exist(self):
        for name in PROSE_FILES:
            path = REPO / name
            if not path.is_file():
                continue
            cdr, ctle = cited_sections(read(path))
            missing_cdr = sorted(cdr - self.cdr_sections)
            missing_ctle = sorted(ctle - self.ctle_sections)
            self.assertEqual(
                missing_cdr, [],
                f"{name} cites NOTES.md sections that do not exist: {missing_cdr}",
            )
            self.assertEqual(
                missing_ctle, [],
                f"{name} cites NOTES_CTLE.md sections that do not exist: "
                f"{missing_ctle}",
            )

    def test_readme_range_claims_are_current(self):
        # The README advertises how far each log runs; that claim goes stale
        # every time a session appends a section.
        readme = read(REPO / "README.md")
        for pattern, sections, label in (
            (r"NOTES\.md[^\n]*?§1-§?(\d+)", self.cdr_sections, "NOTES.md"),
            (r"NOTES_CTLE\.md[^\n]*?§C1-§?C(\d+)", self.ctle_sections,
             "NOTES_CTLE.md"),
        ):
            for m in re.finditer(pattern, readme):
                self.assertEqual(
                    int(m.group(1)), max(sections),
                    f"README claims {label} ends at section {m.group(1)}, but "
                    f"its last section is {max(sections)}",
                )


class ReferencedPaths(unittest.TestCase):
    def test_paths_named_in_prose_exist(self):
        problems = []
        for name in PROSE_FILES:
            path = REPO / name
            if not path.is_file():
                continue
            for span in code_spans(read(path)):
                span = span.strip()
                if not looks_like_repo_path(span):
                    continue
                if span.startswith(GENERATED_PATH_PREFIXES):
                    continue
                if not (REPO / span.rstrip("/")).exists():
                    problems.append(f"{name}: {span}")
        self.assertEqual(problems, [], f"documentation names paths that do not exist: {problems}")


class MeasuredResults(unittest.TestCase):
    """Every number on the front page is traceable to a simulation log."""

    HEADING = "## Measured results"

    @classmethod
    def setUpClass(cls):
        cls.readme = read(REPO / "README.md")

    def _results_table_rows(self):
        after = self.readme.split(self.HEADING, 1)
        self.assertEqual(len(after), 2, "README.md has no 'Measured results' section")
        rows = []
        started = False
        for line in after[1].splitlines():
            stripped = line.strip()
            if stripped.startswith("|"):
                started = True
                rows.append(stripped)
            elif started and not stripped.startswith("|"):
                break
        return rows

    def test_table_exists(self):
        self.assertGreater(len(self._results_table_rows()), 4)

    def test_every_row_cites_its_source(self):
        rows = self._results_table_rows()
        for row in rows[2:]:  # skip the header and the |---| separator
            cells = [c.strip() for c in row.strip("|").split("|")]
            if not any(cells):
                continue
            source = cells[-1]
            self.assertTrue(
                "§" in source or re.search(r"\.(md|txt)\b", source),
                "every measured-results row must name the design-log section "
                f"or file the number came from: {row!r}",
            )


class BadgeHonesty(unittest.TestCase):
    def test_no_gds_badge_until_a_gds_exists(self):
        info = yaml.safe_load(read(REPO / "info.yaml"))
        top = info["project"]["top_module"]
        gds_built = (REPO / "gds" / f"{top}.gds").is_file()
        readme = read(REPO / "README.md")
        shows_gds_badge = "workflows/gds/badge.svg" in readme
        if not gds_built:
            self.assertFalse(
                shows_gds_badge,
                "README shows the gds workflow badge, but no GDS has been built "
                "yet -- the badge would advertise a state the project is not in",
            )


if __name__ == "__main__":
    unittest.main()
