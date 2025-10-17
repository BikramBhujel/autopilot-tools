<#
.SYNOPSIS
Autopilot Hardware Hash Launcher
Fully automated:
- Detect USB
- Install NuGet provider if missing
- Install PowerShellGet if needed
- Install/Get-WindowsAutopilotInfo script
- Export hardware hash CSV
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
# 4. Ensure NuGet provider is installed
# -----------------------------
try {
    if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
        Write-Host "NuGet provider not found. Installing..."
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser
    } else {
        Write-Host "NuGet provider already installed."
    }
    # Trust PSGallery repository
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
} catch {
    Write-Host "Error installing NuGet provider: $_"
    $_ | Out-File (Join-Path $OutputFolder "ErrorLog.txt")
    exit
}

# -----------------------------
# 5. Ensure PowerShellGet module is available
# -----------------------------
try {
    if (-not (Get-Module -ListAvailable -Name PowerShellGet)) {
        Write-Host "Installing/updating PowerShellGet module..."
        Install-Module -Name PowerShellGet -Force -Scope CurrentUser
    } else {
        Write-Host "PowerShellGet module already available."
    }
} catch {
    Write-Host "Error installing PowerShellGet: $_"
    $_ | Out-File (Join-Path $OutputFolder "ErrorLog.txt")
    exit
}

# -----------------------------
# 6. Ensure Get-WindowsAutopilotInfo script is installed
# -----------------------------
try {
    if (-not (Get-Command Get-WindowsAutopilotInfo -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Get-WindowsAutopilotInfo script..."
        Install-Script -Name Get-WindowsAutopilotInfo -Force -Scope CurrentUser
    } else {
        Write-Host "Get-WindowsAutopilotInfo script already installed."
    }
} catch {
    Write-Host "Error installing Get-WindowsAutopilotInfo: $_"
    $_ | Out-File (Join-Path $OutputFolder "ErrorLog.txt")
    exit
}

# -----------------------------
# 7. Extract Autopilot hardware hash
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
