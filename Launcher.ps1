# OOBE-ready launcher script
$usb = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Free -gt 0 -and $_.Root -match '^[A-Z]:\\$' } | Select-Object -First 1
if ($usb) {
    $OutputFolder = Join-Path $usb.Root "HWID"
} else {
    $OutputFolder = "C:\HWID"
}
if (!(Test-Path $OutputFolder)) { New-Item -ItemType Directory -Path $OutputFolder -Force }
$scriptContent = Invoke-RestMethod -Uri "https://autopilot.bikrambhujel.com.np/Get-HWID.ps1" -UseBasicParsing
Invoke-Expression $scriptContent
Get-WindowsAutopilotInfo -OutputFile (Join-Path $OutputFolder "AutopilotHWID.csv")
