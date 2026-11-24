<#
.SYNOPSIS
    Restores default Windows cursor theme.
    Compatible with Windows PowerShell 5.1 and modern PowerShell 7 (pwsh).
#>
[CmdletBinding()]
param()

$CursorKey = "HKCU:\Control Panel\Cursors"
[Microsoft.Win32.Registry]::SetValue('HKEY_CURRENT_USER\Control Panel\Cursors', '', 'Windows Default')
$cursorNames = @("Arrow", "Help", "AppStarting", "Wait", "Crosshair", "IBeam", "NWPen", "No", "SizeNS", "SizeWE", "SizeNWSE", "SizeNESW", "SizeAll", "UpArrow", "Hand")
foreach ($name in $cursorNames) {
    Set-ItemProperty -Path $CursorKey -Name $name -Value "" -Type String
}

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class User32RestoreMinimal {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, IntPtr pvParam, uint fWinIni);
    public const uint SPI_SETCURSORS = 0x0057;
    public const uint SPIF_UPDATEINIFILE = 0x01;
    public const uint SPIF_SENDCHANGE = 0x02;
}
"@ -ErrorAction SilentlyContinue

[User32RestoreMinimal]::SystemParametersInfo([User32RestoreMinimal]::SPI_SETCURSORS, 0, [IntPtr]::Zero, [User32RestoreMinimal]::SPIF_UPDATEINIFILE -bor [User32RestoreMinimal]::SPIF_SENDCHANGE) | Out-Null

Write-Host "[+] Restored default Windows cursor scheme." -ForegroundColor Green
