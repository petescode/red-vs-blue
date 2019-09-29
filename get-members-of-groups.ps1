# Author: Pete Wood
# developed in PowerShell 5.1
Import-Module ActiveDirectory
Clear-Host
[int]$count=0

[ipaddress]$dc = Read-Host "Enter domain controller IP"
[string]$user = Read-Host "Enter domain username"
$password = Read-Host "Enter username password" -AsSecureString

# avoiding interactive pop-up; keep all input at shell for non-GUI OS
$cred = New-Object System.Management.Automation.PSCredential($user,$password)

Get-ADGroup -Filter * -Server $dc -Credential $cred -Properties Members | ForEach-Object {
    
    $count++
    $object = New-Object System.Object
    $object | Add-Member -Type NoteProperty -Name "Name" -Value $_.Name
    $object | Add-Member -Type NoteProperty -Name "Members" `
        -Value $(Get-ADGroupMember -Server $dc -Credential $cred -Identity $_.Name | Select -Expand Name)
    [array]$array += $object
    
    #Get-ADGroupMember -Server $dc -Credential $cred -Identity $_.Name | ForEach{
        #Write-Host $_.Name
        #$object | Add-Member -Type NoteProperty -Name "Members" -Value $_.Name
        #[array]$array += $object
    #}
}
$array | Out-Host

# report on the count at some point