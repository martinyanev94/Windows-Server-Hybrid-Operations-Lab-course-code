[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$TargetName,

    [Parameter(Mandatory)]
    [string]$ExpectedAddress,

    [int]$Port = 443,

    [string]$OutputPath = '.\connectivity-incident.json'
)

$ErrorActionPreference = 'Stop'
$started = Get-Date

$dnsAnswers = Resolve-DnsName -Name $TargetName -Type A
$resolvedAddresses = @(
    $dnsAnswers |
        Where-Object Type -eq 'A' |
        Select-Object -ExpandProperty IPAddress
)
$dnsPassed = $resolvedAddresses -contains $ExpectedAddress
$targetAddress = $resolvedAddresses | Select-Object -First 1

$route = $null
if ($targetAddress) {
    $route = Get-NetRoute -AddressFamily IPv4 |
        Where-Object {
            $_.DestinationPrefix -in @('0.0.0.0/0', "$targetAddress/32")
        } |
        Sort-Object RouteMetric |
        Select-Object -First 1
}
$routePassed = $null -ne $route

$transport = $null
if ($targetAddress) {
    $transport = Test-NetConnection `
        -ComputerName $targetAddress `
        -Port $Port `
        -WarningAction SilentlyContinue
}
$transportPassed = [bool]($transport -and $transport.TcpTestSucceeded)

$firewallProfiles = Get-NetFirewallProfile |
    Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction

$incident = [ordered]@{
    startedUtc = $started.ToUniversalTime().ToString('o')
    completedUtc = (Get-Date).ToUniversalTime().ToString('o')
    targetName = $TargetName
    expectedAddress = $ExpectedAddress
    port = $Port
    layers = [ordered]@{
        nameResolution = [ordered]@{
            resolvedAddresses = $resolvedAddresses
            passed = $dnsPassed
        }
        routing = [ordered]@{
            destination = $targetAddress
            nextHop = if ($route) { $route.NextHop } else { $null }
            interfaceIndex = if ($route) { $route.InterfaceIndex } else { $null }
            passed = $routePassed
        }
        tcpTransport = [ordered]@{
            target = if ($targetAddress) { "$targetAddress`:$Port" } else { $null }
            remoteAddress = if ($transport) { $transport.RemoteAddress } else { $null }
            passed = $transportPassed
        }
        localPolicyEvidence = [ordered]@{
            status = 'review-required'
            note = 'Local profiles do not prove Azure NSG or VPN policy results.'
            firewallProfiles = $firewallProfiles
        }
    }
    conclusion = if (-not $dnsPassed) {
        'Name resolution does not match the expected address.'
    } elseif (-not $routePassed) {
        'No usable local route was observed for the resolved address.'
    } elseif (-not $transportPassed) {
        'The route exists, but TCP transport did not succeed.'
    } else {
        'Name, route, and TCP transport passed; review application and policy evidence.'
    }
}

$incident | ConvertTo-Json -Depth 8 | Set-Content -Path $OutputPath -Encoding UTF8
$incident | ConvertTo-Json -Depth 8
