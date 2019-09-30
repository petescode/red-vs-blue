# Author: Pete Wood
# developed in PowerShell 5.1

Import-Module ActiveDirectory
Clear-Host
[string]$datestamp = (Get-Date).ToString('yyyy-MM-dd')
[string]$timestamp = (Get-Date).ToString('HHmm')
[string]$report_name = "ad_computers_baseline_$datestamp@$($timestamp).txt"

# directory to store reports in; if not exist, create
$path_test = Test-Path "$env:USERPROFILE\Desktop\$((Get-Date).ToString('yyyy-MM-dd'))_powershell_queries"
if($path_test -ne $TRUE){ $directory = New-Item -ItemType Directory -Path "$env:USERPROFILE\Desktop\$((Get-Date).ToString('yyyy-MM-dd'))_powershell_queries" }
else{ $directory = "$env:USERPROFILE\Desktop\$((Get-Date).ToString('yyyy-MM-dd'))_powershell_queries" }

# sub-directory for organization
$path_test = Test-Path "$directory\ad_computer_baselines"
if($path_test -ne $TRUE){ $subdir = New-Item -ItemType Directory -Path "$directory\ad_computer_baselines" }
else{ $subdir = "$directory\ad_computer_baselines" }

[ipaddress]$dc = Read-Host "Enter domain controller IP"
[string]$user = Read-Host "Enter domain username"

[array]$report = Get-ADComputer -Filter * -Server $dc -Credential $user `
    -Properties Name,samAccountName,Enabled,Created,Modified,lastLogonDate,OperatingSystem,OperatingSystemVersion,PasswordNotRequired `
    | Select Name,samAccountName,Enabled,Created,Modified,lastLogonDate,OperatingSystem,OperatingSystemVersion,PasswordNotRequired `
    | Sort Name

$report | Tee-Object -FilePath "$subdir\$report_name"
#test