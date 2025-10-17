<#
.SYNOPSIS
Windows Autopilot Hardware Hash Extraction - OOBE-ready web automation
This script downloads Get-HWID.ps1 from web, loads it, detects USB, and saves AutopilotHWID.csv.
#>

# -----------------------------
# 1. Set execution policy
# -----------------------------
Set-ExecutionPolicy Bypass -Scope Process -Force

# -----------------------------
# 2. Detect removable USB drive
# -----------------------------
$usb = Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 } | Select-Object -First 1

if ($usb) {
    $OutputFolder = Join-Path $usb.DeviceID "HWID"
    Write-Host "USB detected at $($usb.DeviceID). Saving CSV to $OutputFolder"
} else {
    $OutputFolder = "C:\HWID"
    Write-Host "No USB detected. Saving CSV to $OutputFolder"
}

# Ensure output folder exists
if (!(Test-Path $OutputFolder)) { New-Item -ItemType Directory -Path $OutputFolder -Force }

# -----------------------------
# 3. Download Get-HWID.ps1 dynamically from web
# -----------------------------
$scriptUrl = "https://autopilot.bikrambhujel.com.np/Get-HWID.ps1"
try {
    Write-Host "Downloading Get-HWID.ps1 from web..."
    $scriptContent = Invoke-RestMethod -Uri $scriptUrl -UseBasicParsing
} catch {
    Write-Host "Error downloading Get-HWID.ps1: $_"
    exit
}

# -----------------------------
# 4. Dot-source the downloaded script in memory
# -----------------------------
try {
    Invoke-Expression $scriptContent
    Write-Host "Get-WindowsAutopilotInfo loaded successfully from web."
} catch {
    Write-Host "Failed to load Get-WindowsAutopilotInfo: $_"
    exit
}

# -----------------------------
# 5. Extract the hardware hash
# -----------------------------
try {
    $csvPath = Join-Path $OutputFolder "AutopilotHWID.csv"
    Write-Host "Extracting Autopilot hardware hash..."
    Get-WindowsAutopilotInfo -OutputFile $csvPath
    Write-Host "Hardware hash saved to $csvPath"
} catch {
    Write-Host "Failed to extract hardware hash: $_"
    $_ | Out-File (Join-Path $OutputFolder "ErrorLog.txt")
}

# -----------------------------
# Done
# -----------------------------
Write-Host "Autopilot hardware hash extraction completed."
