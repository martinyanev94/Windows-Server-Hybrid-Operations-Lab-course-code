[CmdletBinding()]
param(
    [string]$OutputPath = '.\vm-app01-counters.csv',
    [int]$SampleIntervalSeconds = 15,
    [int]$SampleCount = 5
)

$paths = @(
    '\Processor(_Total)\% Processor Time',
    '\Memory\Available MBytes',
    '\LogicalDisk(_Total)\Avg. Disk sec/Transfer',
    '\Network Interface(*)\Bytes Total/sec'
)

$samples = Get-Counter -ComputerName 'vm-app01' -Counter $paths -SampleInterval $SampleIntervalSeconds -MaxSamples $SampleCount
$rows = foreach ($sample in $samples.CounterSamples) {
    [pscustomobject]@{
        Computer = 'vm-app01'
        TimeGenerated = $sample.Timestamp.ToUniversalTime().ToString('o')
        CounterPath = $sample.Path
        Value = [double]$sample.CookedValue
    }
}

$parent = Split-Path -Parent $OutputPath
if ($parent -and -not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
}

$rows | Export-Csv -LiteralPath $OutputPath -NoTypeInformation
Write-Output "Wrote $($rows.Count) counter samples to $OutputPath"
