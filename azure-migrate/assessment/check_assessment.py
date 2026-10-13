from __future__ import annotations

import json
import sys
from pathlib import Path


def validate(record: dict) -> list[str]:
    required = ["workload", "dependencies", "sizing_basis", "wave"]
    missing = [name for name in required if not record.get(name)]
    if missing:
        return [f"missing: {name}" for name in missing]
    if not isinstance(record["dependencies"], list) or not record["dependencies"]:
        return ["dependencies must be a nonempty list"]
    if not isinstance(record.get("assumptions"), list) or not record["assumptions"]:
        return ["assumptions must be a nonempty list"]
    if not isinstance(record.get("dependencies_included"), bool):
        return ["dependencies_included must be explicit"]
    if record["wave"] == "wave-1" and not record["dependencies_included"]:
        return ["wave-1 is blocked until dependencies are included"]
    return []


def main() -> int:
    path = Path(sys.argv[1] if len(sys.argv) > 1 else "assessment.json")
    record = json.loads(path.read_text(encoding="utf-8"))
    errors = validate(record)
    if errors:
        for error in errors:
            print(error)
        return 1
    print("assessment assumptions are complete")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
