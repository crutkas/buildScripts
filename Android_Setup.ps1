# Things to note
# Single script, will survive reboot
# Script needs to be run under admin (will auto correct if not)
# Script needs internet access to download files
# Script assumes WinGet is installed
# 
# Why aren't we using wsl --install -d Ubuntu
# Well, we want to WSL.exe install a bunch of stuff
# Ubuntu2004 install --root can't be done above so it requires user interaction
# if you don't need to install items on linux without setting root, this script becomes much simplier 
# as we don't need to recreate wsl --install

$mypath = $MyInvocation.MyCommand.Path
Write-Output "Path of the script : $mypath"
Write-Output "IsReboot: $Args"
$isReboot = $Args[0]
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Restarting as Admin
if (!$isAdmin) {
	Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$mypath' $Args;`"";
	exit;
}

if(!$isReboot)
{
	Write-Output "First time run"

	Write-Output "Enabling needed Android emulator features"	
	dism.exe /online /enable-feature /featurename:Microsoft-Hyper-V /all /norestart
	dism.exe /online /enable-feature /featurename:HypervisorPlatform /all /norestart
}
else
{
	# Copy JSON fragments to Terminal folder
	$termFragPath = $env:LOCALAPPDATA + "\Microsoft\Windows Terminal\Fragments\"
	mkdir $termFragPath

	move-item -Path .\build-extension -Destination $termFragPath

	# installing what I like 😊
	winget import Android_WinGet.json

	# since env won't reset right now, directly adding git to path
	$env:Path += ";" + $Env:Programfiles + "\git\cmd"

	# Getting terminal source code cloned
	mkdir $env:USERPROFILE/source/repo
	cd $env:USERPROFILE/source/repo

	git clone https://github.com/microsoft/terminal
	git clone https://github.com/microsoft/powertoys
	git clone https://github.com/microsoft/winget-cli
	git clone https://github.com/microsoft/surface-duo-compose-samples
}

if(!$isReboot)
{
	# RESTART COMPUTER
	$RunOnceKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
	set-itemproperty $RunOnceKey "NextRun" ('C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe -executionPolicy Unrestricted -File ' + $mypath + ' -reboot')
	
	Write-Output "Need to restart"
	$Input = Read-Host -Prompt "Press to restart"
	Restart-Computer
}