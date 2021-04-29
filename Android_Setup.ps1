# Things to note
# Script needs internet access to download files
# Script assumes WinGet is installed
# Script assumes winget's setting has this line in it: experimentalFeatures": { "import": true }, 

$mypath = $MyInvocation.MyCommand.Path
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Restarting as Admin
if (!$isAdmin) {
	Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$mypath' $Args;`"";
	exit;
}

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

# git clone https://github.com/microsoft/terminal
# git clone https://github.com/microsoft/powertoys
# git clone https://github.com/microsoft/winget-cli
git clone https://github.com/microsoft/surface-duo-compose-samples

# done
$Input = Read-Host -Prompt "Done!  Press enter to quit"