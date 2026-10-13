param(
    [string]$TopologyPath = "$PSScriptRoot/topology.json"
)

$topology = Get-Content -Raw -Path $TopologyPath | ConvertFrom-Json
$os = Get-CimInstance Win32_OperatingSystem
$cs = Get-CimInstance Win32_ComputerSystem
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1

$report = [pscustomobject]@{
    HostName = $env:COMPUTERNAME
    ExpectedHostName = $topology.host.name
    OperatingSystem = $os.Caption
    Architecture = $os.OSArchitecture
    LogicalProcessors = $cs.NumberOfLogicalProcessors
    MemoryGB = [math]::Round($cs.TotalPhysicalMemory / 1GB, 1)
    SLAT = [bool]$cpu.SecondLevelAddressTranslationExtensions
    VMMonitorModeExtensions = [bool]$cpu.VMMonitorModeExtensions
    PlannedVirtualMachines = ($topology.virtual_machines.name -join ', ')
    Networks = ($topology.networks.name -join ', ')
    AzureTenantStatus = $topology.azure_access.tenant
    AzureSubscriptionStatus = $topology.azure_access.subscription
}

$report | Format-List
