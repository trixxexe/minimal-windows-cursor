<#
.SYNOPSIS
    1-Click Live Installer for the Minimal Cursor Theme by ritam.
    Compatible with Windows 10, 11 (Windows PowerShell 5.1 & PowerShell 7+).

.PARAMETER Variant
    'authentic' (Default - Dark obsidian body, silver stroke, #339cff cyan glow)
    'vibrant'   (Full neon cyber-blue body, silver stroke, cyan glow)
    'neon'      (Deep cyan glow core)

.PARAMETER OpenSettings
    Opens Windows Mouse Properties (Pointers) dialog.

.EXAMPLE
    .\Install_Live_by_ritam.ps1
    .\Install_Live_by_ritam.ps1 -Variant vibrant
    .\Install_Live_by_ritam.ps1 -OpenSettings
#>
[CmdletBinding()]
param(
    [ValidateSet('authentic', 'vibrant', 'neon')]
    [string]$Variant = 'authentic',
    [switch]$OpenSettings = $false
)

$CursorDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$ArrowFile = switch ($Variant) {
    'vibrant' { Join-Path $CursorDir 'minimal_vibrant_ritam.cur' }
    'neon'    { Join-Path $CursorDir 'minimal_neon_ritam.cur' }
    default   { Join-Path $CursorDir 'minimal_arrow_ritam.cur' }
}

$LinkFile    = Join-Path $CursorDir 'minimal_link_ritam.cur'
$BeamFile    = Join-Path $CursorDir 'minimal_beam_ritam.cur'
$WorkingFile = Join-Path $CursorDir 'minimal_working_ritam.cur'
$BusyFile    = Join-Path $CursorDir 'minimal_busy_ritam.cur'
$CrossFile   = Join-Path $CursorDir 'minimal_cross_ritam.cur'
$HelpFile    = Join-Path $CursorDir 'minimal_help_ritam.cur'
$UnavailFile = Join-Path $CursorDir 'minimal_unavail_ritam.cur'
$SizeNSFile  = Join-Path $CursorDir 'minimal_size_ns_ritam.cur'
$SizeWEFile  = Join-Path $CursorDir 'minimal_size_we_ritam.cur'
$SizeNWSE    = Join-Path $CursorDir 'minimal_size_nwse_ritam.cur'
$SizeNESW    = Join-Path $CursorDir 'minimal_size_nesw_ritam.cur'
$MoveFile    = Join-Path $CursorDir 'minimal_move_ritam.cur'

# 1. Register scheme in Windows Registry
$SchemeKey = "HKCU:\Control Panel\Cursors\Schemes"
if (-not (Test-Path $SchemeKey)) {
    New-Item -Path $SchemeKey -Force | Out-Null
}

$SchemeString = "$ArrowFile,$HelpFile,$WorkingFile,$BusyFile,$CrossFile,$BeamFile,,,$UnavailFile,$SizeNSFile,$SizeWEFile,$SizeNWSE,$SizeNESW,$MoveFile,,$LinkFile"
Set-ItemProperty -Path $SchemeKey -Name "Minimal (by ritam)" -Value $SchemeString -Type String
Write-Host "[+] Registered cursor scheme 'Minimal (by ritam)' in Windows Registry." -ForegroundColor Cyan

# 2. Apply to active Windows cursor session
$CursorKey = "HKCU:\Control Panel\Cursors"
[Microsoft.Win32.Registry]::SetValue('HKEY_CURRENT_USER\Control Panel\Cursors', '', 'Minimal (by ritam)')
Set-ItemProperty -Path $CursorKey -Name "Arrow" -Value $ArrowFile -Type String
Set-ItemProperty -Path $CursorKey -Name "Help" -Value $HelpFile -Type String
Set-ItemProperty -Path $CursorKey -Name "AppStarting" -Value $WorkingFile -Type String
Set-ItemProperty -Path $CursorKey -Name "Wait" -Value $BusyFile -Type String
Set-ItemProperty -Path $CursorKey -Name "Crosshair" -Value $CrossFile -Type String
Set-ItemProperty -Path $CursorKey -Name "IBeam" -Value $BeamFile -Type String
Set-ItemProperty -Path $CursorKey -Name "No" -Value $UnavailFile -Type String
Set-ItemProperty -Path $CursorKey -Name "SizeNS" -Value $SizeNSFile -Type String
Set-ItemProperty -Path $CursorKey -Name "SizeWE" -Value $SizeWEFile -Type String
Set-ItemProperty -Path $CursorKey -Name "SizeNWSE" -Value $SizeNWSE -Type String
Set-ItemProperty -Path $CursorKey -Name "SizeNESW" -Value $SizeNESW -Type String
Set-ItemProperty -Path $CursorKey -Name "SizeAll" -Value $MoveFile -Type String
Set-ItemProperty -Path $CursorKey -Name "Hand" -Value $LinkFile -Type String

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class User32MinimalRitam {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, IntPtr pvParam, uint fWinIni);
    public const uint SPI_SETCURSORS = 0x0057;
    public const uint SPIF_UPDATEINIFILE = 0x01;
    public const uint SPIF_SENDCHANGE = 0x02;
}
"@ -ErrorAction SilentlyContinue

[User32MinimalRitam]::SystemParametersInfo([User32MinimalRitam]::SPI_SETCURSORS, 0, [IntPtr]::Zero, [User32MinimalRitam]::SPIF_UPDATEINIFILE -bor [User32MinimalRitam]::SPIF_SENDCHANGE) | Out-Null

Write-Host "[+] Applied Minimal theme by ritam to live desktop session!" -ForegroundColor Green
Write-Host "    (0% CPU and 0% GPU overhead - 100% native Windows cursor)" -ForegroundColor Gray

if ($OpenSettings) {
    Start-Process -FilePath "control.exe" -ArgumentList "main.cpl,,1"
}

Write-Host "`nEnjoy your cursor theme! (Created by ritam)" -ForegroundColor Yellow
