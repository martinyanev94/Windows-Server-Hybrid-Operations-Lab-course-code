[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[A-Za-z]:$')]
    [string]$MountPoint,

    [Parameter(Mandatory)]
    [string]$VerificationFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$volume = Get-BitLockerVolume -MountPoint $MountPoint
$recoveryProtector = $volume.KeyProtector |
    Where-Object KeyProtectorType -eq 'RecoveryPassword' |
    Select-Object -First 1

if ($null -eq $recoveryProtector) {
    throw "No recovery-password protector was found for $MountPoint."
}

[pscustomobject]@{
    MountPoint = $volume.MountPoint
    VolumeStatus = $volume.VolumeStatus
    ProtectionStatus = $volume.ProtectionStatus
    RecoveryProtectorId = $recoveryProtector.KeyProtectorId
    VerificationFile = $VerificationFile
}

$recoveryPassword = Read-Host 'Enter the authorized BitLocker recovery password'
Unlock-BitLocker -MountPoint $MountPoint -RecoveryPassword $recoveryPassword

$after = Get-BitLockerVolume -MountPoint $MountPoint
if ($after.VolumeStatus -notin @('FullyEncrypted', 'EncryptionInProgress')) {
    throw "Unexpected volume status after recovery: $($after.VolumeStatus)"
}

if (-not (Test-Path -LiteralPath $VerificationFile -PathType Leaf)) {
    throw "Recovery completed, but the verification file was not readable: $VerificationFile"
}

[pscustomobject]@{
    MountPoint = $after.MountPoint
    VolumeStatus = $after.VolumeStatus
    ProtectionStatus = $after.ProtectionStatus
    Verification = 'Readable verification file confirmed'
}
