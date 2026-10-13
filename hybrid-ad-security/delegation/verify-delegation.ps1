[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string]$RoleGroup,
    [Parameter(Mandatory)] [string]$TargetOU,
    [Parameter(Mandatory)] [string]$TestUser
)

Import-Module ActiveDirectory

$group = Get-ADGroup -Identity $RoleGroup -Properties MemberOf
$domainAdmins = Get-ADGroup -Identity 'Domain Admins'
$enterpriseAdmins = Get-ADGroup -Identity 'Enterprise Admins'
$membership = Get-ADGroupMember -Identity $RoleGroup -Recursive

[pscustomobject]@{
    RoleGroup = $group.Name
    TargetOU = $TargetOU
    RecursiveMemberCount = @($membership).Count
    IsDomainAdminGroup = $group.DistinguishedName -eq $domainAdmins.DistinguishedName
    IsEnterpriseAdminGroup = $group.DistinguishedName -eq $enterpriseAdmins.DistinguishedName
    TestUser = $TestUser
    NextStep = 'Use an approved test procedure to prove one allowed and one denied operation.'
} | ConvertTo-Json -Depth 4
