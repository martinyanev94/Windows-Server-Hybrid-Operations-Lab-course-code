# Assessment evidence companion

This Python utility validates the local assumptions record used alongside an Azure Migrate assessment. It does not call Azure APIs and does not replace portal assessment results.

Run it with:

```text
python3 check_assessment.py assessment.json
```

The sample intentionally returns a blocking error because `dependencies_included` is false for `wave-1`. Change it only after the dependency decision has been verified and recorded. The recommended size and observation window remain pending until Azure Migrate produces those results.
