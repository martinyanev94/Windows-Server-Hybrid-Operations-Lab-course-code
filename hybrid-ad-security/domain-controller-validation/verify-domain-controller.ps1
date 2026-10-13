[CmdletBinding()]
param(
    [string]$DomainController = 'DC01',
    [string]$ApprovedAdminWorkstation = 'SAW01',
    [ValidateSet('Healthy','Unknown','Unhealthy')]
    [string]$IdentitySensorState = 'Healthy',
    [bool]$SuspiciousIdentitySignal = $true,
    [bool]$AlertOwnerAssigned = $true
)

$os = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $DomainController
$managementReachable = [bool](Test-WSMan -ComputerName $DomainController -ErrorAction SilentlyContinue)
$controllerState = if ($managementReachable -and $IdentitySensorState -eq 'Healthy') { 'Review' } else { 'Investigate' }
$responseDecision = if ($controllerState -eq 'Review' -and
    $IdentitySensorState -eq 'Healthy' -and
    $SuspiciousIdentitySignal -and
    $AlertOwnerAssigned) {
    'Review'
} else {
    'Investigate'
}

[ordered]@{
    domain_controller = $DomainController
    approved_admin_workstation = $ApprovedAdminWorkstation
    os_caption = $os.Caption
    management_endpoint_reachable = $managementReachable
    controller_state = $controllerState
    identity_sensor_state = $IdentitySensorState
    suspicious_identity_signal = $SuspiciousIdentitySignal
    alert_owner_assigned = $AlertOwnerAssigned
    response_decision = $responseDecision
    collected_utc = [DateTime]::UtcNow.ToString('o')
} | ConvertTo-Json -Depth 3
