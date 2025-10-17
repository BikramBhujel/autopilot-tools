# Detect USB drive
$usb = Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 } | Select-Object -First 1

if ($usb) {
    $OutputFolder = Join-Path $usb.DeviceID "HWID"
    Write-Host "USB detected at $($usb.DeviceID). Saving to $OutputFolder"
} else {
    $OutputFolder = "C:\HWID"
    Write-Host "No USB detected. Saving to $OutputFolder"
}

# Create folder if it doesn't exist
if (!(Test-Path $OutputFolder)) { New-Item -ItemType Directory -Path $OutputFolder -Force }

# Download & run Get-HWID.ps1
$scriptContent = Invoke-RestMethod -Uri "https://autopilot.bikrambhujel.com.np/Get-HWID.ps1" -UseBasicParsing
Invoke-Expression $scriptContent

# Extract hardware hash
Get-WindowsAutopilotInfo -OutputFile (Join-Path $OutputFolder "AutopilotHWID.csv")
Write-Host "Hardware hash saved to $OutputFolder\AutopilotHWID.csv"
