#!/usr/bin/env python3
"""
l10n audit tool for ARB files.

Usage:
    python scripts/check_l10n.py

Reports:
  1. Keys missing from AR or FR (untranslated)
  2. Keys present in AR/FR but absent from EN (orphaned)
  3. Keys whose translated value is identical to EN (copy-paste placeholder)
  4. Keys where AR/FR have empty string values
  5. Keys where metadata (@key) coverage differs across files
"""

import json
import re
import sys
from pathlib import Path

L10N_DIR = Path(__file__).parent.parent / "lib" / "l10n"
LOCALES = {"en": "intl_en.arb", "ar": "intl_ar.arb", "fr": "intl_fr.arb"}
SECONDARY = ["ar", "fr"]


def load(path: Path) -> dict:
    with path.open(encoding="utf-8") as f:
        return json.load(f)


def is_meta(key: str) -> bool:
    return key.startswith("@")


def content_keys(data: dict) -> set:
    return {k for k in data if not is_meta(k)}


def separator(title: str) -> None:
    width = 72
    print(f"\n{'=' * width}")
    print(f"  {title}")
    print("=" * width)


def section(title: str) -> None:
    print(f"\n--- {title} ---")


def main() -> int:
    data = {}
    for locale, filename in LOCALES.items():
        path = L10N_DIR / filename
        if not path.exists():
            print(f"ERROR: {path} not found")
            return 1
        data[locale] = load(path)

    en_keys = content_keys(data["en"])

    separator("ARB l10n Audit Report")
    print(f"  EN keys: {len(en_keys)}")
    for loc in SECONDARY:
        loc_keys = content_keys(data[loc])
        print(f"  {loc.upper()} keys: {len(loc_keys)}")

    issues = 0

    # 1. Keys in EN missing from a secondary locale
    section("1. Keys in EN missing from AR / FR")
    found = False
    for loc in SECONDARY:
        loc_keys = content_keys(data[loc])
        missing = sorted(en_keys - loc_keys)
        if missing:
            found = True
            issues += len(missing)
            print(f"\n  [{loc.upper()} — {len(missing)} missing]")
            for k in missing:
                print(f"    {k}")
    if not found:
        print("  ✓ none")

    # 2. Orphaned keys (in AR/FR but not in EN)
    section("2. Orphaned keys (in AR / FR but absent from EN)")
    found = False
    for loc in SECONDARY:
        loc_keys = content_keys(data[loc])
        orphaned = sorted(loc_keys - en_keys)
        if orphaned:
            found = True
            issues += len(orphaned)
            print(f"\n  [{loc.upper()} — {len(orphaned)} orphaned]")
            for k in orphaned:
                print(f"    {k}")
    if not found:
        print("  ✓ none")

    # 3. Values identical to EN (likely untranslated copy-paste)
    section("3. Values identical to EN (possible untranslated placeholders)")
    found = False
    for loc in SECONDARY:
        identical = sorted(
            k for k in en_keys
            if k in data[loc] and data[loc][k] == data["en"][k]
        )
        if identical:
            found = True
            issues += len(identical)
            print(f"\n  [{loc.upper()} — {len(identical)} identical to EN]")
            for k in identical:
                print(f"    {k}  =  \"{data['en'][k][:60]}\"")
    if not found:
        print("  ✓ none")

    # 4. Empty string values
    section("4. Empty string values")
    found = False
    for loc in LOCALES:
        empty = sorted(
            k for k in content_keys(data[loc])
            if isinstance(data[loc][k], str) and data[loc][k].strip() == ""
        )
        if empty:
            found = True
            issues += len(empty)
            print(f"\n  [{loc.upper()} — {len(empty)} empty]")
            for k in empty:
                print(f"    {k}")
    if not found:
        print("  ✓ none")

    # 5. Missing @metadata entries (EN is the reference for metadata)
    section("5. @metadata entries in EN missing from AR / FR")
    en_meta = {k[1:] for k in data["en"] if is_meta(k) and k != "@@locale"}
    found = False
    for loc in SECONDARY:
        loc_meta = {k[1:] for k in data[loc] if is_meta(k) and k != "@@locale"}
        missing_meta = sorted(en_meta - loc_meta)
        if missing_meta:
            found = True
            # Metadata-only gap is informational, not an issue count
            print(f"\n  [{loc.upper()} — {len(missing_meta)} @metadata gaps]")
            for k in missing_meta:
                print(f"    @{k}")
    if not found:
        print("  ✓ none")

    # 6. Keys never referenced in Dart source
    section("6. Keys defined in ARB but never used in Dart source (lib/)")
    root = Path(__file__).parent.parent
    search_dirs = [root / "lib", root / "test", root / "integration_test"]
    dart_source = ""
    for search_dir in search_dirs:
        for dart_file in search_dir.rglob("*.dart"):
            # skip generated l10n files — they just re-declare the keys
            if "generated" in dart_file.parts:
                continue
            dart_source += dart_file.read_text(encoding="utf-8", errors="ignore")

    unused = sorted(k for k in en_keys if not re.search(r'\b' + re.escape(k) + r'\b', dart_source))
    if unused:
        issues += len(unused)
        print(f"\n  [{len(unused)} unused keys]")
        for k in unused:
            print(f"    {k}")
    else:
        print("  ✓ all keys referenced")

    separator("Summary")
    if issues == 0:
        print("  All files are consistent. No issues found.")
    else:
        print(f"  {issues} issue(s) found across sections 1–4 and 6.")
        print("  Fix missing keys, remove orphans, review identical values, and prune unused keys.")

    print()
    return 0 if issues == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
