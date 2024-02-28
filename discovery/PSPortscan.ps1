
# Loops through list of IPs in a file to run external network/port scanning PS tool to enumerate network devices 
# https://github.com/BornToBeRoot/PowerShell_IPv4PortScanner/tree/main

# Use this to generate IP list wih powershell: https://github.com/BornToBeRoot/PowerShell_IPv4NetworkScanner


# Set the execution policy to Bypass
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Prompt the user for the file path
$filePath = Read-Host "Enter path to the file containing IP addresses:"

# Read the content of the text file
$fileContent = Get-Content -Path $filePath

# Extract IP addresses
$ipAddresses = $fileContent | ForEach-Object { ($_ -split '\s+')[0] } | Where-Object { $_ -match '\b(?:\d{1,3}\.){3}\d{1,3}\b' }

Write-Host "File exists. Starting port scans"

$outputFileName = Read-Host "Enter the output file name with extension:"

# Loop through and run another PowerShell script for each IP address
foreach ($ip in $ipAddresses) {
    
    $ip | Out-File -FilePath $outputFileName -Append

    $scriptPath = "J:\Tools\discovery\PowerShell_IPv4PortScanner-main\Scripts\Ipv4PortScan.ps1" 

    if (Test-Path $scriptPath) {
        & $scriptPath -StartPort 20 -EndPort 1000 $ip | Out-File $outputFileName -Append
    } else {
        Write-Host "Script not found at $scriptPath"
    }
}
