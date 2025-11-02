:: Created by Sebastian Januchowski
:: polsoft.its@fastservice.com
:: https://github.com/seb07uk
@echo off
title GitKraken CLI WinGet Installer
echo   [2;3mCreated by Sebastian Januchowski                  polsoft.ITS                   e-mail: polsoft.its@fastservice.com[0m
echo.
echo [1;3;5;34m--- GitKraken CLI WinGet Installer ---[0m
echo.[1;3;5;33m
winget install gitkraken.cli
echo.[0m
powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $notify = New-Object System.Windows.Forms.NotifyIcon; $notify.Icon = [System.Drawing.SystemIcons]::Information; $notify.Visible = $true; $notify.ShowBalloonTip(0, 'App installation complete!', 'polsoft.ITS London', [System.Windows.Forms.ToolTipIcon]::None)}"
echo [32m--- GitKraken CLI installation complete! ---[0m
timeout /t 5 >nul
