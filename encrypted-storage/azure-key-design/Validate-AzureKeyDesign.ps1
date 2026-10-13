[CmdletBinding()]
param([string]$Path = (Join-Path $PSScriptRoot 'design.json'))
$design = Get-Content -Raw -Path $Path | ConvertFrom-Json
$errors = [System.Collections.Generic.List[string]]::new()
if ($design.encryption -ne 'ADE') { $errors.Add('Encryption must be ADE.') }
if ($design.subscription -ne $design.key_vault_subscription) { $errors.Add('VM and Key Vault subscriptions must match.') }
if ($design.region -ne $design.key_vault_region) { $errors.Add('VM and Key Vault regions must match.') }
if ($design.generation -eq 2) { $errors.Add('ADE is not available for Generation 2.') }
if ([int]$design.memory_gb -lt 2) { $errors.Add('ADE requires at least 2 GB of memory.') }
if ($design.key_algorithm -ne 'RSA') { $errors.Add('Key algorithm must be RSA.') }
if ([int]$design.key_size_bits -notin @(3072,4096)) { $errors.Add('Use RSA 3072 or RSA 4096.') }
$preflight = $design.preflight.psobject.Properties
foreach ($name in @('identity_endpoint_reachable','key_vault_endpoint_reachable','managed_identity_can_write_vault','ade_volume_encryption_policy_enabled')) { if (-not [bool]$design.preflight.$name) { $errors.Add("Preflight failed: $name") } }
if ($design.preflight.domain_joined -and ($design.preflight.gpo_tpm_protectors_pushed -or -not $design.preflight.gpo_allows_256_bit_recovery_key -or -not $design.preflight.gpo_allows_aes_cbc)) { $errors.Add('Domain-joined Group Policy does not meet ADE requirements.') }
$principals = @($design.workload_principal,$design.managed_identity_principal,$design.administrator_principal)
if (($principals | Sort-Object -Unique).Count -ne 3) { $errors.Add('Workload, managed-identity, and administrator principals must be distinct.') }
$operator = @($design.access_roles.workload_operator)
$identity = @($design.access_roles.managed_identity)
$administrator = @($design.access_roles.key_administrator)
if ($operator -contains 'key.rotate' -or $operator -contains 'vault.policy.manage') { $errors.Add('Workload operators must not administer keys or vault policy.') }
if ($identity -notcontains 'key.use' -or $identity -notcontains 'secret.use' -or $identity -notcontains 'vault.write') { $errors.Add('Managed identity lacks required workflow access.') }
if ($administrator -notcontains 'key.rotate' -or $administrator -notcontains 'vault.policy.manage') { $errors.Add('Key administrator lacks lifecycle authority.') }
if ([string]::IsNullOrWhiteSpace($design.rotation_procedure)) { $errors.Add('Rotation procedure is required.') }
if ([string]::IsNullOrWhiteSpace($design.recovery_evidence) -or $design.secrets_recorded) { $errors.Add('Use non-secret recovery evidence and record no secrets.') }
if ($errors.Count) { $errors | ForEach-Object { "FAIL: $_" }; exit 1 }
'PASS: ADE prerequisites, key choice, principal separation, access boundary, and rotation evidence are recorded.'
