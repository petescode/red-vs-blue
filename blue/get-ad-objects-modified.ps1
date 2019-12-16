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
[string]$computers_file = "ad_computers_modified_$datestamp@$($timestamp).txt"
[string]$users_file = "ad_users_modified_$datestamp@$($timestamp).txt"
[string]$groups_file = "ad_groups_modified_$datestamp@$($timestamp).txt"

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

# Get AD Computers
Write-Host "`nGetting AD Computers..."
Get-ADComputer -Server $dc -Credential $cred -Filter * -Properties Created,Modified `
    | Select-Object Name,Enabled,Created,Modified | Sort-Object Modified `
    | Out-File "$computers_subdir\$computers_file"

# Get AD Users
Write-Host "`nGetting AD Users..."
Get-ADUser -Server $dc -Credential $cred -Filter * -Properties Created,Modified `
    | Select-Object Name,Enabled,Created,Modified | Sort-Object Modified `
    | Out-File "$users_subdir\$users_file"

# Get AD Groups
Write-Host "`nGetting AD Groups...`n"
Get-ADGroup -Server $dc -Credential $cred -Filter * -Properties Created,Modified `
    | Select-Object Name,Enabled,Created,Modified | Sort-Object Modified `
    | Out-File "$groups_subdir\$groups_file"

Explorer $directory