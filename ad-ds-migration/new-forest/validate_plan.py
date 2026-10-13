import json
import sys
from pathlib import Path


def validate_preflight(plan):
    errors = []
    if plan.get("migration_type") == "new_forest":
        if not plan.get("trust_validated"):
            errors.append("Validate the two-way forest trust")
        forwarding = plan.get("dns_forwarding", {})
        if not forwarding.get("source_to_target") or not forwarding.get("target_to_source"):
            errors.append("Configure forwarding in both directions")
    policy = plan.get("policy_plan", {})
    if policy.get("translation_required") and not policy.get("migration_table"):
        errors.append("Provide a Group Policy migration table")
    if not plan.get("authentication_tests"):
        errors.append("Define authentication and client-path tests")
    if not plan.get("rollback_criteria"):
        errors.append("Define observable rollback criteria")
    return errors


def main():
    path = Path(sys.argv[1] if len(sys.argv) > 1 else "sample-plan.json")
    plan = json.loads(path.read_text(encoding="utf-8"))
    errors = validate_preflight(plan)
    if errors:
        print("BLOCKED")
        for error in errors:
            print(f"- {error}")
        return 1
    print("READY")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
