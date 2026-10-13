Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Set-FindingState {
    param(
        [Parameter(Mandatory)] [hashtable] $Finding,
        [Parameter(Mandatory)] [ValidateSet('Assigned','Remediated','Closed')] [string] $State,
        [hashtable] $Verification
    )

    if ($State -eq 'Assigned' -and [string]::IsNullOrWhiteSpace($Finding.owner)) {
        throw 'Owner is required before assignment.'
    }

    if ($State -eq 'Remediated' -and [string]::IsNullOrWhiteSpace($Finding.action)) {
        throw 'Remediation action is required.'
    }

    if ($State -eq 'Closed') {
        if ($null -eq $Verification -or
            $Verification.target -ne $Finding.target -or
            $Verification.evidence -ne $Finding.evidence) {
            throw 'Verification does not match the finding.'
        }
        if ($Verification.resolved -ne $true) {
            throw 'Finding is not resolved.'
        }
        $Finding.verification_result = $Verification.result
    }

    $Finding.status = $State
    $Finding
}

$finding = [ordered]@{
    finding_id   = 'F-104'
    target       = 'AZ801Lab-FS-01'
    evidence     = 'Protection configuration requires review'
    owner        = 'Windows platform team'
    action       = 'Apply the approved server protection baseline'
    verification = 'Fresh assessment shows the recommendation is resolved'
    status       = 'Open'
}

$finding = Set-FindingState -Finding $finding -State Assigned
$finding = Set-FindingState -Finding $finding -State Remediated

$verification = @{
    target    = 'AZ801Lab-FS-01'
    evidence  = 'Protection configuration requires review'
    resolved  = $true
    result    = 'Fresh assessment: F-104 resolved on AZ801Lab-FS-01'
}

if ($verification.resolved) {
    $finding = Set-FindingState -Finding $finding -State Closed -Verification $verification
}

[pscustomobject]$finding | ConvertTo-Json -Depth 3
