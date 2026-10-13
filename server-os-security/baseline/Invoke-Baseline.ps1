[CmdletBinding()]
param(
    [string]$Root = 'C:\BaselineReport'
)

# Run this script from an elevated PowerShell session.
New-Item -ItemType Directory -Path $Root -Force | Out-Null
secedit /export /cfg "$Root\before.inf" /quiet

@"
[Unicode]
Unicode=yes
[System Access]
MinimumPasswordLength = 14
PasswordComplexity = 1
LockoutBadAttempts = 5
"@ | Set-Content "$Root\baseline.inf" -Encoding Unicode

secedit /configure /db "$Root\baseline.sdb" /cfg "$Root\baseline.inf" /areas SECURITYPOLICY /quiet

$ScriptPolicy = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'
New-Item $ScriptPolicy -Force | Out-Null
New-ItemProperty $ScriptPolicy -Name EnableScriptBlockLogging -Value 1 -PropertyType DWord -Force | Out-Null

$EventPolicy = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security'
New-Item $EventPolicy -Force | Out-Null
New-ItemProperty $EventPolicy -Name MaxSize -Value 196608 -PropertyType DWord -Force | Out-Null

gpupdate /target:computer /force | Out-Null
secedit /export /cfg "$Root\effective.inf" /quiet

$Checks = [ordered]@{
    MinimumPasswordLength = (Select-String 'MinimumPasswordLength' "$Root\effective.inf").Line
    PasswordComplexity = (Select-String 'PasswordComplexity' "$Root\effective.inf").Line
    LockoutBadAttempts = (Select-String 'LockoutBadAttempts' "$Root\effective.inf").Line
    EnableScriptBlockLogging = (Get-ItemProperty $ScriptPolicy).EnableScriptBlockLogging
    SecurityLogMaxSize = (Get-ItemProperty $EventPolicy).MaxSize
}
$Checks | ConvertTo-Json | Set-Content "$Root\verification.json"
$Checks
