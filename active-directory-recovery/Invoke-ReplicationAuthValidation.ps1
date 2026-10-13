[CmdletBinding()]
param(
    [string]$DomainController = 'DC01',
    [string]$EvidenceDirectory = '.\evidence',
    [switch]$SkipLiveCommands
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Path $EvidenceDirectory -Force | Out-Null

function Save-CommandEvidence {
    param(
        [string]$Name,
        [scriptblock]$Command
    )

    $path = Join-Path $EvidenceDirectory $Name
    if ($SkipLiveCommands) {
        "SKIPPED: live command execution was disabled." | Set-Content -Path $path
        return [pscustomobject]@{ Name = $Name; Status = 'skipped'; Path = $path }
    }

    $output = @(& $Command 2>&1 | ForEach-Object { $_.ToString() })
    $output | Set-Content -Path $path
    $failed = $output -match 'error|failed|failure|fatal'
    [pscustomobject]@{
        Name = $Name
        Status = if ($failed) { 'review' } else { 'captured' }
        Path = $path
    }
}

$results = @(
    (Save-CommandEvidence -Name 'repadmin-replsummary.txt' -Command {
        & repadmin.exe /replsummary
    }),
    (Save-CommandEvidence -Name 'repadmin-showrepl.txt' -Command {
        & repadmin.exe /showrepl $DomainController
    }),
    (Save-CommandEvidence -Name 'dcdiag-targeted.txt' -Command {
        & dcdiag.exe /s:$DomainController /test:replications /test:sysvolcheck /test:advertising /test:dns
    })
)

$report = [pscustomobject]@{
    generated_utc = [DateTime]::UtcNow.ToString('o')
    domain_controller = $DomainController
    live_commands_executed = -not $SkipLiveCommands
    evidence = $results
    interpretation = 'Review command evidence and correlate it with synchronization and cloud sign-in records before declaring recovery complete.'
}
$report | ConvertTo-Json -Depth 5 | Set-Content -Path (Join-Path $EvidenceDirectory 'replication-auth-validation.json')
$report | ConvertTo-Json -Depth 5
