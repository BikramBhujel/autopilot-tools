<#
.SYNOPSIS
Windows Autopilot Hardware Hash Extraction - OOBE-ready Launcher
This script detects USB drives, downloads Get-HWID.ps1, dot-sources it, and saves AutopilotHWID.csv.
#>

# -----------------------------
# 1. Set execution policy to allow scripts
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

# Ensure folder exists
if (!(Test-Path $OutputFolder)) { New-Item -ItemType Directory -Path $OutputFolder -Force }

# -----------------------------
# 3. Download the Get-HWID.ps1 script locally
# -----------------------------
$scriptPath = Join-Path $OutputFolder "Get-WindowsAutopilotInfo.ps1"
try {
    Write-Host "Downloading Get-HWID.ps1..."
    Invoke-WebRequest -Uri "https://autopilot.bikrambhujel.com.np/Get-HWID.ps1" -OutFile $scriptPath -UseBasicParsing
} catch {
    Write-Host "Error downloading script: $_"
    exit
}

# -----------------------------
# 4. Dot-source the script to load functions into current session
# -----------------------------
try {
    . $scriptPath
    Write-Host "Get-WindowsAutopilotInfo function loaded successfully."
} catch {
    Write-Host "Failed to load Get-WindowsAutopilotInfo: $_"
    exit
}

# -----------------------------
# 5. Extract the hardware hash
# -----------------------------
try {
    Write-Host "Extracting Autopilot hardware hash..."
    Get-WindowsAutopilotInfo -OutputFile (Join-Path $OutputFolder "AutopilotHWID.csv")
    Write-Host "Hardware hash saved to $OutputFolder\AutopilotHWID.csv"
} catch {
    Write-Host "Failed to extract hardware hash: $_"
    $_ | Out-File (Join-Path $OutputFolder "ErrorLog.txt")
}

# -----------------------------
# Done
# -----------------------------
Write-Host "Autopilot hardware hash extraction completed."
