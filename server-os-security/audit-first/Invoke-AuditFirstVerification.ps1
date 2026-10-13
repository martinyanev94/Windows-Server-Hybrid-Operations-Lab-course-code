[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Application = 'C:\LabWorkload\ServerApp.exe',
    [string]$Output = 'C:\BaselineReport\audit-first-verification.json'
)

$ErrorActionPreference = 'Stop'
$outputDirectory = Split-Path -Parent $Output
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null

$beforeCapturedAt = (Get-Date).ToUniversalTime()
$before = [ordered]@{
    capturedAt = $beforeCapturedAt.ToString('o')
    systemMitigation = Get-ProcessMitigation -System
    applicationMitigation = Get-ProcessMitigation -Name $Application
}

$restartBoundary = (Get-Date).ToUniversalTime()
Get-Process -Name ([IO.Path]::GetFileNameWithoutExtension($Application)) -ErrorAction SilentlyContinue |
    Stop-Process -Force
Start-Process -FilePath $Application
Start-Sleep -Seconds 3

$processName = [IO.Path]::GetFileNameWithoutExtension($Application)
$health = Get-Process -Name $processName -ErrorAction SilentlyContinue
$events = @(
    Get-WinEvent -LogName 'Microsoft-Windows-CodeIntegrity/Operational' -ErrorAction SilentlyContinue |
        Where-Object { $_.TimeCreated.ToUniversalTime() -ge $restartBoundary } |
        Select-Object TimeCreated, Id, ProviderName, LevelDisplayName, Message
)

$after = [ordered]@{
    capturedAt = (Get-Date).ToUniversalTime().ToString('o')
    healthyProcess = [bool]$health
    systemMitigation = Get-ProcessMitigation -System
    applicationMitigation = Get-ProcessMitigation -Name $Application
}

$report = [ordered]@{
    application = $Application
    restartBoundary = $restartBoundary.ToString('o')
    before = $before
    after = $after
    codeIntegrityEvents = $events
    interpretation = 'Audit evidence requires review before enforcement.'
}

$report |
    ConvertTo-Json -Depth 8 |
    Set-Content -Path $Output -Encoding UTF8

Write-Output "Verification report written to $Output"
