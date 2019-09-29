# developed in PowerShell 5.1
Clear-Host
[int]$count=0

Get-ChildItem -Path "$env:USERPROFILE\Desktop" -Recurse -File | Select -Expand Name | ForEach{

    $count++
    $object = New-Object System.Object
    $object | Add-Member -Type NoteProperty -Name 'Num' -Value $count
    $object | Add-Member -Type NoteProperty -Name 'Name' -Value $_
    [array]$list += $object
}

Write-Host "Select 1st file for comparison"

$list | Out-Host
Do{
    Try{ $select = Read-Host "Select 1st file" }
    Catch {} # do nothing, including with error messages
} Until(($select -gt 0) -and ($select -le $list.Length))

$file1_name = $list[$select-1].Name
$file1 = Get-ChildItem -Path "$env:USERPROFILE\Desktop" -Recurse -File `
    | Where {$_.Name -eq $file1_name} | Select -Expand FullName


Clear-Host
Write-Host "File 1 is: " -NoNewline; Write-Host $file1_name -ForegroundColor Cyan
Write-Host "`nSelect 2nd file for comparison"

$list | Out-Host
Do{
    Try{ $select = Read-Host "Select 2nd file" }
    Catch {} # do nothing, including with error messages
} Until(($select -gt 0) -and ($select -le $list.Length))

$file2_name = $list[$select-1].Name
$file2 = Get-ChildItem -Path "$env:USERPROFILE\Desktop" -Recurse -File `
    | Where {$_.Name -eq $file2_name} | Select -Expand FullName

$results = Compare-Object -ReferenceObject $(Get-Content $file1) -DifferenceObject $(Get-Content $file2)

if($NULL -eq $results){ Write-Host "`nThere are no results because nothing is different!" }