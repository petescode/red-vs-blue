# developed in PowerShell 5.1
[int]$count=0

Get-ChildItem -Path "$env:USERPROFILE\Desktop" -Recurse -File | Select -Expand Name | ForEach{

    $count++
    $object = New-Object System.Object
    $object | Add-Member -Type NoteProperty -Name '#' -Value $count
    $object | Add-Member -Type NoteProperty -Name 'Name' -Value $_
    [array]$list += $object
}
$list | Out-Host

# handle selection next

#$file1 = "thing"
#$file2 = "thing"

#Compare-Object -ReferenceObject $(Get-Content $file1) -DifferenceObject $(Get-Content $file2)