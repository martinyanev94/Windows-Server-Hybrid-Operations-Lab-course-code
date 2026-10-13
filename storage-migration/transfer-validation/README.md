# Transfer validation

This PowerShell validator compares source and target inventories before a file-server cutover. It checks the share name, local path, relative file paths, recorded permission entries, and dependency paths. List values are sorted before comparison, so equivalent inventories do not fail because JSON ordering differs.

Run from PowerShell:

```powershell
./Invoke-TransferValidation.ps1 `
  -SourceInventory ./source-inventory.json `
  -TargetInventory ./target-inventory.json `
  -ReportPath ./transfer-validation-report.json
```

The script returns exit code 0 only when all inventory checks pass, and exit code 1 when a check fails. The sample inventories are illustrative validation inputs. A passing comparison does not replace destination permission inspection or client-path testing after cutover. Avoid decommissioning or further cleanup of the source until destination validation and rollback decisions are complete.
