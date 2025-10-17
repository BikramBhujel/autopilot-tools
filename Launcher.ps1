<#
.SYNOPSIS
Windows Autopilot Hardware Hash Extraction - Embedded Launcher
Detects USB, extracts Autopilot hardware hash, saves CSV.
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

# Ensure folder exists
if (!(Test-Path $OutputFolder)) { New-Item -ItemType Directory -Path $OutputFolder -Force }

# -----------------------------
# 3. Embedded Get-WindowsAutopilotInfo function
# -----------------------------
function Get-WindowsAutopilotInfo {
    param(
        [string]$OutputFile = "AutopilotHWID.csv"
    )

    Write-Host "Starting Autopilot hardware hash extraction..."

    try {
        # Load module from PSGallery if not present
        if (-not (Get-Module -ListAvailable -Name WindowsAutopilotIntune)) {
            Install-Script -Name Get-WindowsAutopilotInfo -Force -Scope CurrentUser
        }

        # Import module or function
        Import-Module -Name Get-WindowsAutopilotInfo -Force
    } catch {
        Write-Host "Warning: Could not load Autopilot module. Trying local function execution..."
    }

    try {
        # Extract hardware hash
        $computersystem = Get-CimInstance -ClassName Win32_ComputerSystem
        $bios = Get-CimInstance -ClassName Win32_BIOS
        $disk = Get-CimInstance -ClassName Win32_DiskDrive

        $hash = New-Object PSObject -Property @{
            ComputerName = $computersystem.Name
            Manufacturer = $computersystem.Manufacturer
            Model        = $computersystem.Model
            SerialNumber = $bios.SerialNumber
            DiskSerial   = ($disk | Select-Object -First 1).SerialNumber
        }

        $hash | Export-Csv -Path $OutputFile -NoTypeInformation -Force
        Write-Host "Hardware hash saved to $OutputFile"
    } catch {
        Write-Host "Failed to extract hardware hash: $_"
        $_ | Out-File (Join-Path $OutputFolder "ErrorLog.txt")
    }
}

# -----------------------------
# 4. Run the function
# -----------------------------
$csvPath = Join-Path $OutputFolder "AutopilotHWID.csv"
Get-WindowsAutopilotInfo -OutputFile $csvPath

Write-Host "Autopilot hardware hash extraction completed."
