from pathlib import Path
import json
import sys

VALID_STATES = {"demonstrated", "designed", "open"}
REQUIRED = {
    "topology",
    "security_baseline",
    "recovery_test",
    "migration_plan",
    "monitoring",
    "readiness_gaps",
}


def validate(path):
    data = json.loads(Path(path).read_text(encoding="utf-8"))
    areas = data.get("evidence", {})
    errors = [f"missing area: {name}" for name in sorted(REQUIRED - areas.keys())]

    for name, area in areas.items():
        if area.get("state") not in VALID_STATES:
            errors.append(f"{name}: invalid evidence state")
        if not area.get("artifact", "").strip():
            errors.append(f"{name}: missing artifact")
        if not area.get("verification", "").strip():
            errors.append(f"{name}: missing verification")
        if not area.get("limitations", "").strip():
            errors.append(f"{name}: missing limitations")

    return errors


def main():
    if len(sys.argv) != 2:
        print("usage: python validate_handoff.py final-handoff.json")
        return 2

    errors = validate(sys.argv[1])
    print("VALID" if not errors else "INVALID")
    for error in errors:
        print(error)
    return 0 if not errors else 1


if __name__ == "__main__":
    raise SystemExit(main())
