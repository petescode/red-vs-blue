<#
Author: Pete Wood
- Developed in PowerShell 5.1
#>
########################################################################################
# Housekeeping

Import-Module ActiveDirectory
Clear-Host
[string]$datestamp = (Get-Date).ToString('yyyy-MM-dd')
[string]$timestamp = (Get-Date).ToString('HHmm')
[string]$computers_file = "ad_computers_baseline_$datestamp@$($timestamp).txt"
[string]$users_file = "ad_users_baseline_$datestamp@$($timestamp).txt"
[string]$groups_file = "ad_groups_baseline_$datestamp@$($timestamp).txt"
[string]$pw_policy_file = "ad_domain_password_policy_$datestamp@$($timestamp)"

# directory to store reports in; if not exist, create
$path_test = Test-Path "$env:USERPROFILE\Desktop\$((Get-Date).ToString('yyyy-MM-dd'))_powershell_queries"
if($path_test -ne $TRUE){ $directory = New-Item -ItemType Directory -Path "$env:USERPROFILE\Desktop\$((Get-Date).ToString('yyyy-MM-dd'))_powershell_queries" }
else{ $directory = "$env:USERPROFILE\Desktop\$((Get-Date).ToString('yyyy-MM-dd'))_powershell_queries" }

# sub-directory for computers
$path_test = Test-Path "$directory\ad_computer_baselines"
if($path_test -ne $TRUE){ $computers_subdir = New-Item -ItemType Directory -Path "$directory\ad_computer_baselines" }
else{ $computers_subdir = "$directory\ad_computer_baselines" }

# sub-directory for users
$path_test = Test-Path "$directory\ad_user_baselines"
if($path_test -ne $TRUE){ $users_subdir = New-Item -ItemType Directory -Path "$directory\ad_user_baselines" }
else{ $users_subdir = "$directory\ad_user_baselines" }

# sub-directory for groups
$path_test = Test-Path "$directory\ad_group_baselines"
if($path_test -ne $TRUE){ $groups_subdir = New-Item -ItemType Directory -Path "$directory\ad_group_baselines" }
else{ $groups_subdir = "$directory\ad_group_baselines" }
########################################################################################

[ipaddress]$dc = Read-Host "Enter domain controller IP"
[string]$user = Read-Host "Enter domain username"
$password = Read-Host "Enter domain username password" -AsSecureString
$cred = New-Object System.Management.Automation.PSCredential($user,$password)

Write-Host "`nCollecting AD Computer objects..."
[array]$computers = Get-ADComputer -Filter * -Server $dc -Credential $cred `
    -Properties * | Sort-Object Name

$computers | Out-File -FilePath "$computers_subdir\$computers_file"
Add-Content -Path "$computers_subdir\$computers_file" -Value "Total: $($computers.Count)"

Write-Host "`nCollecting AD User objects..."
[array]$users = Get-ADUser -Filter * -Server $dc -Credential $cred `
    -Properties * | Sort-Object samAccountName

$users | Out-File -FilePath "$users_subdir\$users_file"
Add-Content -Path "$users_subdir\$users_file" -Value "Total: $($users.Count)"

Write-Host "`nCollecting AD Group objects..."
[array]$groups = Get-ADGroup -Filter * -Server $dc -Credential $cred `
    -Properties * | Sort-Object Name

$groups | Out-File -FilePath "$groups_subdir\$groups_file"
Add-Content -Path "$groups_subdir\$groups_file" -Value "Total: $($groups.Count)"

Write-Host "`nCollecting domain password policy..."
Get-ADDefaultDomainPasswordPolicy -Server $dc -Credential $cred | Out-File "$directory\$pw_policy_file"

# get OUs

# get DNS info
# have to do "winrm set winrm/config/client '@{TrustedHosts="$dc1,$dc2"}'" before these will work:
# Invoke-Command -ComputerName $dc1 -Credential $cred -ScriptBlock { Get-DNSServerZone | ForEach { $_ | Get-dnsserverresourcerecord } } `
#    | Out-File "filepath" 

# get DC info

# get GPO info
# $session = get-pssession -computername $dc -credential $cred
# copy-item -FromSession $session -Path "C:\users\on\the\remote\machine" -Destination "$env:USERPROFILE\Desktop\"
# remove-item -FromSession $session -Path "C:\path\to\file\on\remote\machine"

Explorer $directory