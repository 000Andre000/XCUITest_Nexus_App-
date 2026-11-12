#!/usr/bin/env python3
"""Find test locators that no longer exist in a new build of the app.

Usage:
    check_locators.py --tests Nexus-app/Nexus-appUITests --sources dumps/ [--json report.json]

--tests    folder with the XCUITest .swift files
--sources  folder of page-source dumps (XML or the text tree from the exploration
           session), one file per screen. Any file in the folder is read as text.

How it works:
  1. Collects every string literal the tests pass to button()/text()/field()/
     labelBeginsWith()/app.<type>[...] and the Domain / StandaloneFeature enums.
  2. Collects every label/name/value/identifier/placeholder in the dumps.
  3. Reports exact misses and, for each, the closest labels in the new build.

Prefix selectors (labelBeginsWith) match if any label starts with the prefix.
Dynamic text is skipped when it looks like a pattern (contains %@ or \\( ).
Exit code 1 when anything is missing, so it can gate CI.
"""
import argparse
import difflib
import json
import re
import sys
from pathlib import Path

LITERAL = r'"((?:[^"\\]|\\.)*)"'

EXACT_PATTERNS = [
    re.compile(r'\b(?:button|text|field)\(' + LITERAL + r'\)'),
    re.compile(r'\bapp\.(?:buttons|staticTexts|textFields|secureTextFields|switches|'
               r'navigationBars|alerts|otherElements|tabBars\.buttons|keyboards\.buttons)'
               r'\[' + LITERAL + r'\]'),
    re.compile(r'\.(?:buttons|staticTexts)\[' + LITERAL + r'\]'),
    re.compile(r'\bassertVisible\(\[([^\]]*)\]'),
    re.compile(r'\btapTab\(' + LITERAL + r'\)'),
    re.compile(r'\bselectAccount\(picker: ' + LITERAL),
    re.compile(r'\bcase \w+ = ' + LITERAL),
]
PREFIX_PATTERN = re.compile(r'\blabelBeginsWith\(\.\w+, ' + LITERAL + r'\)')
ARRAY_ITEM = re.compile(LITERAL)

ATTRS = ("label", "name", "value", "identifier", "accessibility-id", "placeholderValue", "placeholder")
DUMP_ATTR = re.compile(r'\b(?:' + "|".join(ATTRS) + r')\s*[=:]\s*"([^"]+)"')


def is_dynamic(s):
    return "%@" in s or "\\(" in s


def collect_tests(root):
    exact, prefixes = {}, {}
    for f in sorted(Path(root).rglob("*.swift")):
        text = f.read_text(encoding="utf-8", errors="replace")
        for lineno, line in enumerate(text.splitlines(), 1):
            for pat in EXACT_PATTERNS:
                for m in pat.finditer(line):
                    raw = m.group(1)
                    vals = ARRAY_ITEM.findall(raw) if pat.pattern.startswith(r'\bassertVisible') else [raw]
                    for v in vals:
                        if v and not is_dynamic(v):
                            exact.setdefault(v, []).append(f"{f}:{lineno}")
            for m in PREFIX_PATTERN.finditer(line):
                v = m.group(1)
                if v and not is_dynamic(v):
                    prefixes.setdefault(v, []).append(f"{f}:{lineno}")
    return exact, prefixes


def collect_labels(root):
    labels = set()
    for f in Path(root).rglob("*"):
        if f.is_file():
            text = f.read_text(encoding="utf-8", errors="replace")
            labels.update(m.group(1) for m in DUMP_ATTR.finditer(text))
    return labels


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--tests", required=True)
    ap.add_argument("--sources", required=True)
    ap.add_argument("--json")
    a = ap.parse_args()

    exact, prefixes = collect_tests(a.tests)
    labels = collect_labels(a.sources)
    if not labels:
        sys.exit("No labels found in --sources. Check the dump folder and format.")

    report = {"missing_exact": [], "missing_prefix": [], "checked": len(exact) + len(prefixes)}
    for value, where in sorted(exact.items()):
        if value not in labels:
            near = difflib.get_close_matches(value, labels, n=3, cutoff=0.5)
            report["missing_exact"].append({"locator": value, "used_at": where[:5], "closest": near})
    for value, where in sorted(prefixes.items()):
        if not any(l.startswith(value) for l in labels):
            near = [l for l in difflib.get_close_matches(value, labels, n=3, cutoff=0.5)]
            report["missing_prefix"].append({"locator": value, "used_at": where[:5], "closest": near})

    miss = report["missing_exact"] + report["missing_prefix"]
    print(f"Checked {report['checked']} locators against {len(labels)} labels from the new build.")
    if not miss:
        print("All locators still resolve.")
    for kind, items in (("EXACT", report["missing_exact"]), ("PREFIX", report["missing_prefix"])):
        for it in items:
            print(f"\n[{kind}] {it['locator']!r}")
            for w in it["used_at"]:
                print(f"    used at {w}")
            print(f"    closest in new build: {it['closest'] or 'none'}")
    if a.json:
        Path(a.json).write_text(json.dumps(report, indent=2))
    sys.exit(1 if miss else 0)


if __name__ == "__main__":
    main()
