import json, sys, yaml
from pathlib import Path


def matches(rule, event):
    """True if the event satisfies every selection block in the rule."""
    detection = rule["detection"]
    for name, block in detection.items():
        if name == "condition":
            continue
        for field, expected in block.items():
            parts = field.split("|")
            fname = parts[0]
            modifier = parts[1] if len(parts) > 1 else None
            actual = str(event.get(fname, ""))
            if modifier == "contains":
                if expected not in actual:
                    return False
            else:
                if actual.lower() != str(expected).lower():
                    return False
    return True


def main():
    failures = 0
    for rule_path in sorted(Path("detections").glob("*.yml")):
        if rule_path.name == "TEMPLATE.yml":
            continue

        rule = yaml.safe_load(rule_path.read_text())
        test_dir = Path("tests") / rule_path.stem

        if not test_dir.exists():
            print(f"FAIL {rule_path.stem}: no tests")
            failures += 1
            continue

        pos = json.loads((test_dir / "positive.json").read_text())
        neg = json.loads((test_dir / "near-miss.json").read_text())

        ok = matches(rule, pos) and not matches(rule, neg)
        print(f"{'PASS' if ok else 'FAIL'} {rule_path.stem}")
        if not ok:
            failures += 1

    print(f"\n{failures} failure(s)")
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()