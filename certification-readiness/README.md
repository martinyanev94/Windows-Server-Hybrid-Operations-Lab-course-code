# Final operational handoff

Validate the portfolio from the repository root:

```text
python certification-readiness/validate_handoff.py certification-readiness/final-handoff.json
```

The validator checks that all six required evidence areas exist, use a recognized
state, name an artifact, and contain verification and limitation text. A `VALID`
result confirms portfolio completeness; it does not replace live infrastructure,
recovery, migration, or monitoring tests.
