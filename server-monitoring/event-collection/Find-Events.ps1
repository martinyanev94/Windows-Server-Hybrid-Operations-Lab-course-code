[CmdletBinding()]
param(
    [string]$LogName = 'Security',
    [datetime]$StartTime = (Get-Date).AddHours(-1),
    [datetime]$EndTime = (Get-Date),
    [string]$OutputPath
)

if ($EndTime -le $StartTime) {
    throw 'EndTime must be later than StartTime.'
}

$filter = @{
    LogName   = $LogName
    StartTime = $StartTime
    EndTime   = $EndTime
}

$events = @(Get-WinEvent -FilterHashtable $filter -ErrorAction Stop |
    Select-Object TimeCreated, Id, ProviderName, LevelDisplayName, Message)

if ($OutputPath) {
    $events | Export-Csv -Path $OutputPath -NoTypeInformation
}

$events
