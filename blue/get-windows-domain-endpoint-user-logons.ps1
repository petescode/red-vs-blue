<#
Author: Pete Wood             
Date: original 2017.11.27                                                                      
Purpose: Get list of AD Computer objects, test for connectivity and if responsive,
          scan Security Event Logs for 4624 (user has logged on) and generate reports.

Links:
    https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4624
    - Explains Event ID 4624 codes

Notes:
    - Developed in PowerShell 5.1
    - Takes about 20-30 seconds on average per computer on the same subnet, assuming workstations and not servers
    - There is no code number 6
    - Cached login type (11) you will get a lot on your local machine when running PowerShell with your domain admin credentials
    - Uses Get-EventLog instead of Get-WinEvent because we are dealing with Security logs (Google it)
    - Servers appear to store more historical records of Event 4624 than clients
    - This was an adaptation of my other script and is not well rounded and edited but it is fully functional

DEVELOPMENT:
#>
# Housekeeping

# Self-elevate to admin
$my_windows_ID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$my_windows_principal=New-Object System.Security.Principal.WindowsPrincipal($my_windows_ID)
$admin_role=[System.Security.Principal.WindowsBuiltInRole]::Administrator

if ($my_windows_principal.IsInRole($admin_role)){
   $Host.UI.RawUI.WindowTitle = $MYINVOCATION.MyCommand.Definition + " (Elevated)"
   Clear-Host
}
else{
   $new_process = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
   $new_process.Arguments = $MYINVOCATION.MyCommand.Definition;
   $new_process.Verb = "RunAs";
   [System.Diagnostics.Process]::Start($new_process);
   Exit
}

$desktop_path = "$($env:USERPROFILE)\Desktop"
$test = Test-Path "$desktop_path\$((Get-Date).ToString('yyyy-MM-dd'))_PowerShell_Queries"
if ($test -ne $TRUE){ $folder = New-Item -ItemType Directory -Path "$desktop_path\$((Get-Date).ToString('yyyy-MM-dd'))_PowerShell_Queries" }
    else { $folder = "$desktop_path\$((Get-Date).ToString('yyyy-MM-dd'))_PowerShell_Queries" }
#########################################################################################################################################
Clear-Host
Import-Module ActiveDirectory

# These should be your AD OU structure, examples below
# OU=Windows,OU=Servers,OU=Australia,DC=FABRIKAM,DC=COM
# DC=Computers,DC=FABRIKAM,DC=COM
$searchbase = ''
$compbase = ''

# Get a list of all active Active Directory user accounts
[array]$user_list = Get-ADUser -Filter {(Enabled -eq $TRUE)} -SearchBase $searchbase `
    | Select SamAccountName `
    | Sort SamAccountName


# Get computer list
[array]$comp_list = Get-ADComputer -SearchBase $compbase -Filter * -Properties IPv4Address #| Select Name

$wait_time = $comp_list.Count * 2

Write-Host "`nTesting connection on $($comp_list.Count) AD computers..."
Write-Host "  Est wait time: $wait_time seconds"

# Send a quiet ping to see which ones are responsive
ForEach ($c in $comp_list){
  if(Test-Connection -ComputerName $c.Name -Count 1 -Quiet){
    [array]$computers += $c.Name
  }
}

Write-Host "`n$($computers.count) responded.`n"

# Pull the Security Event logs for each computer that responded, export to CSV
ForEach($c in $computers){
  Write-Host "Processing $c..."

  # Get and organize all Security event ID 4624 (user account logon) entries
  [array]$table = Get-EventLog -ComputerName $c -LogName Security -InstanceId 4624 -EntryType SuccessAudit `
      | Sort TimeGenerated -Descending `
      | Select @{Label="LogonTime"; Expression={$_.TimeGenerated}},
               @{Label="UserName"; Expression={$_.ReplacementStrings[5]}},
               @{Label="LogonType"; Expression={$_.ReplacementStrings[8]}},
               @{Label="Workstation"; Expression={$_.ReplacementStrings[11]}}

  # re-compile the array object to convert property value codes
  $array=@()

  ForEach ($t in $table){
    if($t.LogonType -eq "2"){
      $object = [PSCustomObject]@{
        LogonTime   = $t.LogonTime
        UserName    = $t.UserName
        LogonType   = " 02 - Local interactive"
        Workstation = $t.Workstation
      }
      $array += $object 
    }
    if($t.LogonType -eq "3"){
      $object = [PSCustomObject]@{
        LogonTime   = $t.LogonTime
        UserName    = $t.UserName
        LogonType   = " 03 - Network"
        Workstation = $t.Workstation
      }
      $array += $object
    }
    if($t.LogonType -eq "4"){
      $object = [PSCustomObject]@{
        LogonTime   = $t.LogonTime
        UserName    = $t.UserName
        LogonType   = " 04 - Batch"
        Workstation = $t.Workstation
      }
      $array += $object 
    }
    if($t.LogonType -eq "5"){
      $object = [PSCustomObject]@{
        LogonTime   = $t.LogonTime
        UserName    = $t.UserName
        LogonType   = " 05 - Service"
        Workstation = $t.Workstation
      }
      $array += $object  
    }
    if($t.LogonType -eq "7"){
      $object = [PSCustomObject]@{
        LogonTime   = $t.LogonTime
        UserName    = $t.UserName
        LogonType   = " 07 - Screen unlock"
        Workstation = $t.Workstation
      }
      $array += $object
    }
    if($t.LogonType -eq "8"){
      $object = [PSCustomObject]@{
        LogonTime   = $t.LogonTime
        UserName    = $t.UserName
        LogonType   = " 08 - Network cleartext"
        Workstation = $t.Workstation
      }
      $array += $object
    }
    if($t.LogonType -eq "9"){
      $object = [PSCustomObject]@{
        LogonTime   = $t.LogonTime
        UserName    = $t.UserName
        LogonType   = " 09 - New credentials"
        Workstation = $t.Workstation
      }
      $array += $object
    }
    if($t.LogonType -eq "10"){
      $object = [PSCustomObject]@{
        LogonTime   = $t.LogonTime
        UserName    = $t.UserName
        LogonType   = " 10 - Remote interactive (RDP)"
        Workstation = $t.Workstation
      }
      $array += $object 
    }
    if($t.LogonType -eq "11"){
      $object = [PSCustomObject]@{
        LogonTime   = $t.LogonTime
        UserName    = $t.UserName
        LogonType   = " 11 - Cached"
        Workstation = $t.Workstation
      }
      $array += $object
    } 
  }
  $array | Sort LogonTime -Descending | Export-CSV "$folder\UserLogonReport_$c.csv" -NoTypeInformation
  #Invoke-Item "$folder\UserLogonReport_$c.csv"
  Explorer $folder
}