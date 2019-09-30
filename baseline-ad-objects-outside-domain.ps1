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

# directory to store reports in; if not exist, create
$path_test = Test-Path "$env:USERPROFILE\Desktop\$((Get-Date).ToString('yyyy-MM-dd'))_powershell_queries"
if($path_test -ne $TRUE){ $directory = New-Item -ItemType Directory -Path "$env:USERPROFILE\Desktop\$((Get-Date).ToString('yyyy-MM-dd'))_powershell_queries" }
else{ $directory = "$env:USERPROFILE\Desktop\$((Get-Date).ToString('yyyy-MM-dd'))_powershell_queries" }

# sub-directory for computers
$path_test = Test-Path "$directory\ad_computer_baselines"
if($path_test -ne $TRUE){ $subdir_comps = New-Item -ItemType Directory -Path "$directory\ad_computer_baselines" }
else{ $subdir_comps = "$directory\ad_computer_baselines" }

# sub-directory for users
$path_test = Test-Path "$directory\ad_user_baselines"
if($path_test -ne $TRUE){ $subdir_users = New-Item -ItemType Directory -Path "$directory\ad_user_baselines" }
else{ $subdir_users = "$directory\ad_user_baselines" }

# sub-directory for groups
$path_test = Test-Path "$directory\ad_group_baselines"
if($path_test -ne $TRUE){ $subdir_groups = New-Item -ItemType Directory -Path "$directory\ad_group_baselines" }
else{ $subdir_groups = "$directory\ad_group_baselines" }
########################################################################################

[ipaddress]$dc = Read-Host "Enter domain controller IP"
[string]$user = Read-Host "Enter domain username"
$password = Read-Host "Enter domain username password" -AsSecureString
$cred = New-Object System.Management.Automation.PSCredential($user,$password)

[array]$computers = Get-ADComputer -Filter * -Server $dc -Credential $cred `
    -Properties Name,samAccountName,Enabled,Created,Modified,lastLogonDate,OperatingSystem,OperatingSystemVersion,PasswordNotRequired `
    | Select Name,samAccountName,Enabled,Created,Modified,lastLogonDate,OperatingSystem,OperatingSystemVersion,PasswordNotRequired `
    | Sort Name
$computers | Out-File -FilePath "$subdir_comps\$computers_file"

[array]$users = Get-ADUser -Filter * -Server $dc -Credential $cred `
    -Properties Name,samAccountName,Enabled,Created,Modified,lastLogonDate,PasswordLastSet `
    | Select Name,samAccountName,Enabled,Created,Modified,lastLogonDate,PasswordLastSet `
    | Sort samAccountName
$users | Out-File -FilePath "$subdir_users\$users_file"

[array]$groups = Get-ADGroup -Filter * -Server $dc -Credential $cred `
    -Properties Name,samAccountName,objectClass,Created,Modified,Description,Members `
    | Select Name,samAccountName,objectClass,Created,Modified,Description,Members `
    | Sort Name
$groups | Out-File -FilePath "$subdir_groups\$groups_file"

Explorer $directory