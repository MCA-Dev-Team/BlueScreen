$logo = "
             ___
 ______     /  /
/_____/    /  /
/_____/   (  (
           \  \
            \__\"


$Passwords = "Zeus", "Athena", "Apollo", "Anubis", "Medusa", "Odin", "Hercules", "Aphrodite", "Poseidon", "Krishna",
             "Shiva", "Hades", "Freyja", "Persephone", "Loki", "Artemis", "Osiris", "Horus", "Ganesh",
             "Amaterasu", "Fenrir", "Hera", "Kali", "Baldur", "Quetzalcoatl", "Durga", "Thor", "Hestia", "Gaea",
             "Uranus", "Pontus", "Horus", "Atlas", "Oceanus", "Cronus", "Nyx", "Zephyrus", "Morpheus", "Pallas",
             "Pontus", "Tartarus", "Ares", "Castor", "Chaos", "Crios", "Dionysus", "Helios", "Hyperion", "Hypnos"

$characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*()_+"
$numbers = "0123456789"

$hostname = hostname
$user = whoami
$ipaddr = (Get-NetIPAddress | Where-Object { $_.AddressState -eq "Preferred" -and $_.AddressFamily -eq "IPv4" -and $_.IPAddress -NotContains "127.0.0.1"}).IPAddress
$subnet = (Get-NetIPAddress | Where-Object { $_.AddressState -eq "Preferred" -and $_.AddressFamily -eq "IPv4" -and $_.IPAddress -NotContains "127.0.0.1"}).PrefixLength

$combinedaddr = $ipaddr + "/" + $subnet

$wshell = New-Object -ComObject Wscript.Shell
$jsonPath = "$env:USERPROFILE\Desktop\script.json"
$jsonURL = "https://raw.githubusercontent.com/MCA-Dev-Team/BlueScreen/refs/heads/main/script.json"


function updatescript {
    del ~/Desktop/BlueScreenPS.ps1.temp
    Invoke-WebRequest https://raw.githubusercontent.com/MCA-Dev-Team/BlueScreen/refs/heads/main/BlueScreenPS.ps1 -OutFile ~/Desktop/BlueScreenPS.ps1.temp
    Invoke-WebRequest $jsonURL -OutFile ~/Desktop/script.json
    powershell -NoProfile -ExecutionPolicy Bypass -Command {mv -Force ~/Desktop/BlueScreenPS.ps1.temp ~/Desktop/BlueScreenPS.ps1}
    Write-Host "Script Updated!"
    Write-Host "Press any key to exit"
    [void][System.Console]::ReadKey($true)
}

function header {
    Clear-Host
    Write-Host $logo "`n`nWelcome to BlueScreen PWSH.`nCollecting Info, Please Wait..."
    Write-Host "Version:" $PSVersionTable.BuildVersion
    Write-Host "Hostname:" $hostname
    Write-Host "User:" $user
    Write-Host "IP Address:" $combinedaddr
}
function prereqs {
    Write-Host "Setting up Prerequisites"
    Write-Host "Checking for and Importing AD Module"
    if (Get-Module -ListAvailable -Name ActiveDirectory) {
        Import-Module ActiveDirectory
        Write-Host "AD Module is already installed"
    } else {
        Write-Host "AD Module is not installed"
        Write-Host "Installing AD Module"
        Install-WindowsFeature RSAT-AD-PowerShell
        Import-Module ActiveDirectory
    }
    Write-Host "Checking for Choco package manager"
    if (Test-Path 'C:\ProgramData\chocolatey\choco.exe') {
        Write-Host "Choco is already installed"
        choco feature enable -n allowGlobalConfirmation
        mainMenu
    } else {
        Write-Host "Choco is not installed"
        installChoco
    }
}

function installChoco {
    Write-Host "Setting up Choco package manager"
    Invoke-WebRequest https://github.com/MCA-Dev-Team/BlueScreen/releases/download/Prereqs/NDP48-x86-x64-AllOS-ENU.exe -OutFile NDP48-x86-x64-AllOS-ENU.exe
    Start-Process -Wait -FilePath NDP48-x86-x64-AllOS-ENU.exe -ArgumentList '/q'
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Host "Choco Installed!"
    Write-Host "Need to restart script for Choco to work"
    Write-Host "Press any key to exit"
    [void][System.Console]::ReadKey($true)
}

function ResetPasswords {
    del $env:USERPROFILE\Desktop\ADPasswordReset.txt
    del $env:USERPROFILE\Desktop\LocalPasswordReset.txt
    $randPassword = $Passwords | Get-Random -Count 1
    $randNum = Get-Random -Minimum 1 -Maximum 4
    $newPassword = $randPassword + $randNum
    $newPasswordSec = ConvertTo-SecureString -String $newPassword -AsPlainText -Force
    Get-ADUser -Filter * | ForEach-Object {
        $ADuser = $_.SamAccountName
        Set-ADAccountPassword $ADuser -NewPassword $newPasswordSec -Reset
        Write-Host "Password for $ADuser has been reset to $newPassword"
        echo "Password for $ADuser has been reset to $newPassword" >> $env:USERPROFILE\Desktop\ADPasswordReset.txt
    }
    Get-LocalUser -Name * | Where-Object { $_.Enabled -eq 'True' } | ForEach-Object {
        $LocalUser = $_.Name
        Set-LocalUser -Name $LocalUser -Password $newPasswordSec
        Write-Host "Password for $LocalUser has been reset to $newPassword"
        echo "Password for $LocalUser has been reset to $newPassword" >> $env:USERPROFILE\Desktop\LocalPasswordReset.txt
    }
}

function RunWinUtil {
    Invoke-WebRequest -Uri $jsonURL -OutFile $jsonPath
    iwr christitus.com/win -OutFile $env:USERPROFILE\Desktop\WinUtil.ps1
    powershell -NoProfile -ExecutionPolicy Bypass -File $env:USERPROFILE\Desktop\WinUtil.ps1 -Config $jsonPath
    Write-Host "Press any key to exit"
    [void][System.Console]::ReadKey($true)
}

function cleanup {
    del $env:USERPROFILE\Downloads\*
    $task = Get-ScheduledTask
    if($task -ne $null){
        Unregister-ScheduledTask $task.TaskName -Confirm:$false
    }
    else{
        Write-Host "No Scheduled Tasks Found"
    }
    Write-Host "Press any key to exit"
    [void][System.Console]::ReadKey($true)
}

function mainMenu {
    $mainMenu = 'X'
    while($mainMenu -ne ''){
        Clear-Host
        header

        Write-Host -ForegroundColor Cyan "Main Menu"
        Write-Host -ForegroundColor DarkCyan -NoNewline "`n["; Write-Host -NoNewline "1"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan " Programs"
        Write-Host -ForegroundColor DarkCyan -NoNewline "`n["; Write-Host -NoNewline "2"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan " Updates"
        Write-Host -ForegroundColor DarkCyan -NoNewline "`n["; Write-Host -NoNewline "3"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan " Lockdown"
        Write-Host -ForegroundColor DarkCyan -NoNewline "`n["; Write-Host -NoNewline "4"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan " Update Script"


        $mainMenu = Read-Host "`nSelection (leave blank to quit)"
        # Launch submenu1
        if($mainMenu -eq 1){
            subMenu1
        }
        # Launch submenu2
        if($mainMenu -eq 2){
            subMenu2
        }
        # Launch submenu3
        if($mainMenu -eq 3){
            subMenu3
        }
        #update script
        if($mainMenu -eq 4){
            updatescript
        }

    }
}

function subMenu1 {
    $subMenu1 = 'X'
    while($subMenu1 -ne ''){
        Clear-Host
        header

        Clear-Host
        Write-Host -ForegroundColor Cyan "Programs"
        Write-Host -ForegroundColor DarkCyan -NoNewline "`n["; Write-Host -NoNewline "1"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan " Nmap"
        Write-Host -ForegroundColor DarkCyan -NoNewline "`n["; Write-Host -NoNewline "2"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan " Chromium"
        $subMenu1 = Read-Host "`nSelection (leave blank to quit)"
        $timeStamp = Get-Date -Uformat %m%d%y%H%M
        # Option 1
        if($subMenu1 -eq 1){
            Write-Host 'Installing Nmap'
            choco install nmap
            # Pause and wait for input before going back to the menu
            Write-Host -ForegroundColor DarkCyan "`nScript execution complete."
            Write-Host "`nPress any key to return to the previous menu"
            [void][System.Console]::ReadKey($true)
        }
        # Option 2
        if($subMenu1 -eq 2){
            choco install chromium
            # Pause and wait for input before going back to the menu
            Write-Host -ForegroundColor DarkCyan "`nScript execution complete."
            Write-Host "`nPress any key to return to the previous menu"
            [void][System.Console]::ReadKey($true)
        }
    }
}

function subMenu2 {
    $subMenu2 = 'X'
    while($subMenu2 -ne ''){
        Clear-Host
        header
        Write-Host -ForegroundColor Cyan "Updates"
        Write-Host -ForegroundColor DarkCyan -NoNewline "`n["; Write-Host -NoNewline "1"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan " Show processes"
        Write-Host -ForegroundColor DarkCyan -NoNewline "`n["; Write-Host -NoNewline "2"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan " Show PS Version"
        $subMenu2 = Read-Host "`nSelection (leave blank to quit)"
        $timeStamp = Get-Date -Uformat %m%d%y%H%M
        # Option 1
        if($subMenu2 -eq 1){
            Get-Process
            # Pause and wait for input before going back to the menu
            Write-Host -ForegroundColor DarkCyan "`nScript execution complete."
            Write-Host "`nPress any key to return to the previous menu"
            [void][System.Console]::ReadKey($true)
        }
        # Option 2
        if($subMenu2 -eq 2){
            $PSVersionTable.PSVersion
            # Pause and wait for input before going back to the menu
            Write-Host -ForegroundColor DarkCyan "`nScript execution complete."
            Write-Host "`nPress any key to return to the previous menu"
            [void][System.Console]::ReadKey($true)
        }
    }
}

function subMenu3 {
    $subMenu3 = 'X'
    while($subMenu3 -ne ''){
        Clear-Host
        header
        Write-Host -ForegroundColor Cyan "Lockdown"
        Write-Host -ForegroundColor DarkCyan -NoNewline "`n["; Write-Host -NoNewline "1"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan " Show processes"
        Write-Host -ForegroundColor DarkCyan -NoNewline "`n["; Write-Host -NoNewline "2"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan " Scan Subnet"
        Write-Host -ForegroundColor DarkCyan -NoNewline "`n["; Write-Host -NoNewline "3"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan " Run CTT WinUtil"
        Write-Host -ForegroundColor DarkCyan -NoNewline "`n["; Write-Host -NoNewline "4"; Write-Host -ForegroundColor DarkCyan -NoNewline "]"; `
            Write-Host -ForegroundColor DarkCyan " Reset Passwords"
        $subMenu3 = Read-Host "`nSelection (leave blank to quit)"
        $timeStamp = Get-Date -Uformat %m%d%y%H%M
        # Option 1
        if($subMenu3 -eq 1){
            Get-CimInstance -Class Win32_Process | Select-Object -Property Name, HandleCount, ProcessId, ParentProcessId, Path, CommandLine, WriteTransferCount, ReadTransferCount, WorkingSetSize > $timeStamp-processes.txt
            # Pause and wait for input before going back to the menu
            Write-Host -ForegroundColor DarkCyan "`nScript execution complete."
            Write-Host "`nPress any key to return to the previous menu"
            [void][System.Console]::ReadKey($true)
        }
        # Option 2
        if($subMenu3 -eq 2){
            nmap -A $combinedaddr -oN $timeStamp-nmap.txt
            # Pause and wait for input before going back to the menu
            Write-Host -ForegroundColor DarkCyan "`nScript execution complete."
            Write-Host "`nPress any key to return to the previous menu"
            [void][System.Console]::ReadKey($true)
        }
        # Option 3
        if($subMenu3 -eq 3){
            $Output = $wshell.Popup("Just go to Tweaks and Hit 'Run Tweaks'")
            wget https://raw.githubusercontent.com/MCA-Dev-Team/BlueScreen/refs/heads/main/script.json > ~/Desktop/script.json
            RunWinUtil
            # Pause and wait for input before going back to the menu
            Write-Host -ForegroundColor DarkCyan "`nScript execution complete."
            Write-Host "`nPress any key to return to the previous menu"
            [void][System.Console]::ReadKey($true)
        }
        # Option 4
        # Reset Passwords
        if($subMenu3 -eq 4){
            ResetPasswords
            # Pause and wait for input before going back to the menu
            Write-Host -ForegroundColor DarkCyan "`nScript execution complete."
            Write-Host "`nPress any key to return to the previous menu"
            [void][System.Console]::ReadKey($true)
        }
        # Option 5
        # Cleanup
        if($subMenu3 -eq 5){
            cleanup
        }
    }
}
prereqs
mainMenu
