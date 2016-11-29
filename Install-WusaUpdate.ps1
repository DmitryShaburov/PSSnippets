# Usage:
# 1. Unpack *.msu file of update you want to install
# 2. Set the following variables:
#   $source - Local path to unpacked *.cab files of update
#   $packages - Array of desired packages, without .cab extension, 
#                   order matters (usually set on PkgInstallOrder.txt)
#   $computers - Array of computers to install update
#
#   Example (installation of Windows Managment Framework 4.0):
#   $source = "C:\Work\Distr"
#   $packages = @(
#       "Windows6.1-KB2809215-x64", 
#       "Windows6.1-KB2872035-x64", 
#       "Windows6.1-KB2872047-x64", 
#       "Windows6.1-KB2819745-x64")
#   $computers = @(
#       "vm-test1",
#       "vm-test2",
#       "vm-test3",
#       "vm-test4")
# 3. Run script

$source = ""
$packages = @()
$computers = @()

foreach ($computer in $computers)
{
    if (!(Test-Path "\\$computer\C$\PSRemoting" -pathType container))
    {
        $null = New-Item "\\$computer\C$\PSRemoting" -Type Directory
    }
    foreach ($package in $packages)
    {
        Write-Output "Copying $package to $computer"
        Copy-Item "$source\$package.cab" "\\$computer\C$\PSRemoting\$package.cab"
    }
}

Write-Output "Copying completed!"

$sbDism={
    param(
        $packages
    )
    $packages | Out-File "C:\PSRemoting\packages.txt"
    foreach ($package in $packages)
    {
        Start-Process -FilePath 'dism.exe' -ArgumentList "/online /quiet /add-package /PackagePath:C:\PSRemoting\$package.cab /LogPath:C:\PSRemoting\$package.log" -Wait -NoNewWindow;
    }
}

Invoke-Command -ComputerName $computers -ScriptBlock $sbDism -ArgumentList (,$packages)