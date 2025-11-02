:: Created by Sebastian Januchowski
:: polsoft.its@fastservice.com

@echo off 

powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $notify = New-Object System.Windows.Forms.NotifyIcon; $notify.Icon = [System.Drawing.SystemIcons]::Information; $notify.Visible = $true; $notify.ShowBalloonTip(0, 'Hello world', 'This is called from a batch script.', [System.Windows.Forms.ToolTipIcon]::None)}"