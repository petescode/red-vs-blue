# Author: Pete Wood
# developed in PowerShell 5.1
Clear-Host
Import-Module ActiveDirectory

[ipaddress]$dc = Read-Host "Enter domain controller IP"
[string]$user = Read-Host "Enter domain username"
$password = Read-Host "Enter username password" -AsSecureString

# avoiding interactive pop-up; keep all input at shell for non-GUI OS
$cred = New-Object System.Management.Automation.PSCredential($user,$password)

Get-ADGroup -Filter * -Server $dc -Credential $cred