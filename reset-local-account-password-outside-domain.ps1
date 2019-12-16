# Author: Pete Wood
# developed in PowerShell 5.1
# operating from outside domain, but assuming we have domain credentials
Import-Module ActiveDirectory
Clear-Host

[ipaddress]$dc = Read-Host "Enter domain controller IP"
[string]$user = Read-Host "Enter domain username to authenticate to hosts with"
$password = Read-Host "Enter domain username password" -AsSecureString
$cred = New-Object System.Management.Automation.PSCredential($user,$password)

# needs to be IP addresses
[string]$file = Read-Host "Enter path to computer list file"
$computer_list = Get-Content $file 

$password_policy = Get-ADDefaultDomainPasswordPolicy -Server $dc -Credential $cred `
    | Select ComplexityEnabled,MinPasswordLength,MaxPasswordAge,MinPasswordAge

Clear-Host
Write-Host "`n===== DOMAIN PASSWORD POLICY =====" -BackgroundColor DarkGray
$password_policy | Format-List

Write-Host "Complexity requirements (pick 3 categories):"
Write-Host "   - Uppercase"
Write-Host "   - Lowercase"
Write-Host "   - Numbers"
Write-Host "   - Special characters"

$new_password = Read-Host "`n`nEnter new password" -AsSecureString

while($new_password.Length -lt $password_policy.MinPasswordLength){
    Write-Host "Password length requirement not met. Try again."
    $new_password = Read-Host "`n`nEnter new password" -AsSecureString 
}

$offline_list=@()
[int]$online_count=0
[int]$bar_count=0
[int]$total = $computer_list.Count

$computer_list | ForEach-Object{
    $bar_count++
    Write-Progress -Activity "Trying $_" -Status "$bar_count of $total complete" -PercentComplete ($barcount / $total*100)

    # computer did not respond to ping; mark as offline and move on
    if(-not (Test-Connection -ComputerName $_ -Count 2 -Quiet)){ $offline_list += $_ }
    else{
        # computer responded, attempt ADSI connection to check for local account name
        $online_count++

    }

}
