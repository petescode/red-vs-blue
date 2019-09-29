# Author: Pete Wood
# developed in PowerShell 5.1
Import-Module ActiveDirectory
Clear-Host
[int]$count=0
[string]$datestamp = (Get-Date).ToString('yyyy-MM-dd')
[string]$timestamp = (Get-Date).ToString('HHmm')
[string]$report_name = "ad_groups_with_members_$datestamp@$($timestamp).txt"

# directory to store reports in; if not exist, create
$path_test = Test-Path "$env:USERPROFILE\Desktop\$((Get-Date).ToString('yyyy-MM-dd'))_powershell_queries"
if($path_test -ne $TRUE){ $directory = New-Item -ItemType Directory -Path "$env:USERPROFILE\Desktop\$((Get-Date).ToString('yyyy-MM-dd'))_powershell_queries" }
else{ $directory = "$env:USERPROFILE\Desktop\$((Get-Date).ToString('yyyy-MM-dd'))_powershell_queries" }

# sub-directory for organization
$path_test = Test-Path "$directory\ad_group_baselines"
if($path_test -ne $TRUE){ $subdir = New-Item -ItemType Directory -Path "$directory\ad_group_baselines" }
else{ $subdir = "$directory\ad_group_baselines" }


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
}
#$array | Format-List | Tee-Object "$subdir\$report_name"

Start-Transcript -Path "$subdir\$report_name"
$array | ForEach{
    
    Write-Host "`nName: " $_.Name
    Write-Host "Members: " 
    # if a group has no members, $object.Members becomes type string
    if($_.Members -Is [System.Object]){ $_ | Select -Expand Members }
    
}
Stop-Transcript


# report on the count at some point