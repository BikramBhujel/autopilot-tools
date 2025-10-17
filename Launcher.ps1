<#
.SYNOPSIS
Autopilot Hardware Hash Launcher
Detects USB, installs Get-WindowsAutopilotInfo if missing, extracts hardware hash to CSV.
#>

# -----------------------------
# 1. Ensure TLS1.2 for downloads
# -----------------------------
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

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

# Create output folder if it doesn't exist
if (!(Test-Path $OutputFolder)) { New-Item -ItemType Directory -Path $OutputFolder -Force }

# -----------------------------
# 3. Set execution policy for this session
# -----------------------------
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force

# -----------------------------
# 4. Ensure Get-WindowsAutopilotInfo is installed locally
# -----------------------------
try {
    if (-not (Get-Command Get-WindowsAutopilotInfo -ErrorAction SilentlyContinue)) {
        Write-Host "Get-WindowsAutopilotInfo not found. Installing from PSGallery..."
        Install-Script -Name Get-WindowsAutopilotInfo -Force -Scope CurrentUser
    } else {
        Write-Host "Get-WindowsAutopilotInfo already installed."
    }
} catch {
    Write-Host "Error installing Get-WindowsAutopilotInfo: $_"
    $_ | Out-File (Join-Path $OutputFolder "ErrorLog.txt")
    exit
}

# -----------------------------
# 5. Extract Autopilot hardware hash
# -----------------------------
$csvPath = Join-Path $OutputFolder "AutopilotHWID.csv"
try {
    Write-Host "Extracting Autopilot hardware hash..."
    Get-WindowsAutopilotInfo -OutputFile $csvPath
    Write-Host "Hardware hash saved to $csvPath"
} catch {
    Write-Host "Failed to extract hardware hash: $_"
    $_ | Out-File (Join-Path $OutputFolder "ErrorLog.txt")
}

Write-Host "Launcher completed successfully."
