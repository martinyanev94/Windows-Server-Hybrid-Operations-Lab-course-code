# New-forest migration preflight

This illustrative plan records prerequisites and acceptance boundaries for moving selected AD objects into a separate forest. It does not connect to Active Directory or perform a migration.

Run the validator with Python:

python validate_plan.py sample-plan.json

The supplied sample is expected to print READY. Change trust_validated to false or remove a required test to verify that the validator prints BLOCKED followed by each recorded error. Replace the illustrative names, support-policy decision, password-migration decision, SID-filtering decision, service-account evidence, ACL evidence, and tests with environment-specific values before operational use.
