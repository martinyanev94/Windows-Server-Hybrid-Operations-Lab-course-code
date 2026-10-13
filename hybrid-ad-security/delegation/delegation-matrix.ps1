[CmdletBinding()]
param(
    [string]$RoleGroup = 'Helpdesk-PasswordReset',
    [string]$TargetOU = 'OU=Helpdesk Users,DC=corp,DC=example'
)

$matrix = [pscustomobject]@{
    RoleGroup = $RoleGroup
    Scope = $TargetOU
    AllowedOperations = @(
        'Reset password'
        'Force password change'
        'Unlock account'
    )
    DeniedOperations = @(
        'Create user'
        'Modify group membership'
        'Write permissions'
        'Administer domain controllers'
    )
    ReviewQuestions = @(
        'Is the role group outside Domain Admins and Enterprise Admins?'
        'Does delegation apply only to the target OU?'
        'Does the allowed task succeed for a test user?'
        'Does a forbidden privileged-group change fail?'
    )
}

$matrix | ConvertTo-Json -Depth 4
