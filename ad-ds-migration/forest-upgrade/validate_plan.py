import json
import sys
from pathlib import Path

REQUIRED_GATES = {
    "inventory-baseline",
    "sysvol-replication",
    "promotion-prerequisite",
    "compatibility-rollback",
}
REQUIRED_POST_CHECKS = {"authentication", "DNS", "SYSVOL", "Group Policy", "monitoring"}


def validate(plan):
    errors = []
    if plan.get("forest") != "ad.az801.com":
        errors.append("forest must be ad.az801.com")

    controller = plan.get("new_controller", {})
    if controller.get("os") != "Windows Server 2022":
        errors.append("new controller OS must be Windows Server 2022")
    if controller.get("site") != "SecondADSite":
        errors.append("new controller site must be SecondADSite")
    if controller.get("replication_source") != "AZ801PacktLab-DC-01.az801.com":
        errors.append("replication source does not match the approved plan")

    modes = plan.get("target_modes", {})
    if modes.get("domain") != "WinThreshold":
        errors.append("domain mode must be WinThreshold")
    if modes.get("forest") != "Windows2016Forest":
        errors.append("forest mode must be Windows2016Forest")

    gates = plan.get("gates", [])
    gate_names = [gate.get("name") for gate in gates]
    if set(gate_names) != REQUIRED_GATES:
        errors.append("all four readiness gates are required")
    if gate_names != [
        "inventory-baseline",
        "sysvol-replication",
        "promotion-prerequisite",
        "compatibility-rollback",
    ]:
        errors.append("readiness gates are not in the required order")
    for gate in gates:
        if not gate.get("evidence") or not gate.get("on_failure"):
            errors.append(f"gate {gate.get('name')} needs evidence and on_failure")

    if set(plan.get("post_change_checks", [])) != REQUIRED_POST_CHECKS:
        errors.append("all required post-change checks must be listed")
    return errors


def main():
    path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("sample-plan.json")
    try:
        plan = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        print(f"INVALID: {exc}")
        return 2
    errors = validate(plan)
    if errors:
        print("NOT READY")
        for error in errors:
            print(f"- {error}")
        return 1
    print("READY: forest-upgrade plan passed structural validation")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
