# Windows Autopilot Hardware Hash Extraction Automation

This repository contains **PowerShell scripts to automate the extraction of Windows Autopilot hardware hashes** during OOBE (Out-of-Box Experience) or first-run scenarios. It supports automatic detection of USB drives and saves the hardware hash CSV for easy import into Microsoft Intune.

## Features

- Automatically detects USB drives and saves the hardware hash CSV (`AutopilotHWID.csv`) on the USB if available.  
- Fallback to `C:\HWID` if no USB is present.  
- Downloads and executes the latest `Get-HWID.ps1` script from GitHub.  
- Runs fully in **OOBE / SYSTEM context**, ensuring all required privileges.  
- Easy deployment via GitHub Pages.

## Prerequisites

- Windows device with internet access during OOBE or first-run.  
- PowerShell (default on Windows 10/11).  
- Optional: USB drive for direct export of hardware hash CSV.

## Usage

### During OOBE (Recommended)

1. Boot the device into OOBE.  
2. Press **Shift + F10** to open a Command Prompt.  
3. type: powershell, Enter following command 

```powershell
irm https://autopilot.bikrambhujel.com.np/Launcher.ps1 | iex
