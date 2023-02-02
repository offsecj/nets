Set-ExecutionPolicy RemoteSigned

# Output file location
$filePath = "C:\Windows\Temp\hostsecurity.txt"

$mainheader = "Host Security Analysis" + [Environment]::NewLine + "-----------------------" + [Environment]::NewLine
Add-Content -Path $filePath -Value $mainheader -Encoding UTF8

#List hostname
$gethostname = Invoke-Expression 'hostname'
Add-Content -Path $filePath -Value "Hostname: $gethostname" -Encoding UTF8

#List current user
$getuser = Invoke-Expression 'whoami'
Add-Content -Path $filePath -Value "Current user: $getuser" -Encoding UTF8

# Check if current user is local admin
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)

if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Add-Content -Path $filePath -Value "$getuser is a Local Administrator." -Encoding UTF8
} else {
    Add-Content -Path $filePath -Value "$getuser is not a Local Administrator." -Encoding UTF8
}

#List local admins
$adminsheader = [Environment]::NewLine + "Local Administrators" + [Environment]::NewLine + "---------------------" + [Environment]::NewLine
Add-Content -Path $filePath -Value $adminsheader -Encoding UTF8
$getadmins = Invoke-Expression 'net localgroup administrators'
$getadmins | Out-File $filepath -Append -Encoding UTF8

#List local firewall info
$fwheader = [Environment]::NewLine + "Windows Firewall State" + [Environment]::NewLine + "-----------------------" + [Environment]::NewLine
Add-Content -Path $filePath -Value $fwheader -Encoding UTF8
$getfwinfo = Get-NetFirewallProfile | Select-Object Name, Enabled
$getfwinfo | Out-File $filepath -Append -Encoding UTF8

# Get Windows patch info
$patchheader = [Environment]::NewLine + "Windows Patch History" + [Environment]::NewLine + "----------------------" + [Environment]::NewLine
Add-Content -Path $filePath -Value $patchheader -Encoding UTF8
$getpatches = Get-WmiObject -Class Win32_QuickFixEngineering | Select-Object -Property Description, HotFixID, InstalledOn | Sort-Object -Property InstalledOn -Descending | Select-Object -First 10
$getpatches | Out-File $filePath -Append -Encoding UTF8

# Get info on listening local ports
$listenheader = [Environment]::NewLine + "Listening Services" + [Environment]::NewLine + "---------------------" + [Environment]::NewLine
Add-Content -Path $filePath -Value $listenheader -Encoding UTF8
Get-NetTCPConnection | Where-Object {$_.State -eq 'Listen'} | 
ForEach-Object {
    $process = Get-WmiObject Win32_Process -Filter "ProcessId = '$($_.OwningProcess)'"
    [PSCustomObject]@{
        LocalAddress = $_.LocalAddress
        LocalPort = $_.LocalPort
        ProcessName = $process.Name
        ProcessId = $process.ProcessId
        Path = $process.ExecutablePath
    }
} | Out-File $filePath -Append -Encoding UTF8

# List established TCP connections
$connectionheader = [Environment]::NewLine + "Established TCP Connections" + [Environment]::NewLine + "----------------------------" + [Environment]::NewLine
Add-Content -Path $filePath -Value $connectionheader -Encoding UTF8
$getconns = Get-NetTCPConnection | Select-Object LocalAddress,LocalPort,RemoteAddress,RemotePort,State | Where-Object {$_.State -eq 'Established'}
$getconns | Out-File $filePath -Append -Encoding UTF8

# List running processes
$processheader = [Environment]::NewLine + "Running Processes" + [Environment]::NewLine + "------------------" + [Environment]::NewLine
Add-Content -Path $filePath -Value $processheader -Encoding UTF8
$getprocesses = Get-Process | Select-Object -Property Name | Sort-Object -Property Name -Unique 
$getprocesses | Out-File $filePath -Append -Encoding UTF8

# Get BIOS info
$biosheader = [Environment]::NewLine + "BIOS Information" + [Environment]::NewLine + "-----------------" + [Environment]::NewLine
Add-Content -Path $filePath -Value $biosheader -Encoding UTF8
$BIOS = Get-WmiObject -Class Win32_BIOS | Select-Object -Property PSComputerName,Status,SMBIOSPresent,BIOSVersion
$BIOS | Out-File $filePath -Append -Encoding UTF8

# Get disk encryption info
$diskheader = [Environment]::NewLine + "Disk Encryption" + [Environment]::NewLine + "----------------" + [Environment]::NewLine
Add-Content -Path $filePath -Value $diskheader -Encoding UTF8
$getdiskinfo = Get-BitLockerVolume
$getdiskinfo | Out-File $filePath -Append -Encoding UTF8


$footer = [Environment]::NewLine + "Assessment Complete" + [Environment]::NewLine + "--------------------" + [Environment]::NewLine
Add-Content -Path $filePath -Value $footer -Encoding UTF8

$newfilename = $gethostname + "_security_analysis.txt"

Rename-Item -Path $filePath -NewName $newfilename
