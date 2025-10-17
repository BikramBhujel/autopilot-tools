# Windows Autopilot Hardware Hash Extraction

Run the following during OOBE or first-run PowerShell:

```powershell
irm https://autopilot.bikrambhujel.com.np/Launcher.ps1 | iex
```

This will extract the hardware hash and save it to USB or C:\HWID.
