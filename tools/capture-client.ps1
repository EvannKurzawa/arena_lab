param([Parameter(Mandatory=$true)][int]$ClientPid, [switch]$Click)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class ArenaWindow {
  [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
  [StructLayout(LayoutKind.Sequential)] public struct Rect { public int Left, Top, Right, Bottom; }
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out Rect r);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr h, uint m, IntPtr w, IntPtr l);
  [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
  [DllImport("user32.dll")] public static extern void mouse_event(uint f, uint x, uint y, uint d, UIntPtr e);
}
'@
$client = Get-Process -Id $ClientPid
[ArenaWindow]::SetProcessDPIAware() | Out-Null
$rect = New-Object ArenaWindow+Rect
[ArenaWindow]::GetWindowRect($client.MainWindowHandle, [ref]$rect) | Out-Null
if ($rect.Right -le $rect.Left -or $rect.Bottom -le $rect.Top) { throw 'No visible game window found.' }
[ArenaWindow]::SetForegroundWindow($client.MainWindowHandle) | Out-Null
if ($Click) {
    [ArenaWindow]::PostMessage($client.MainWindowHandle, 6, [IntPtr]1, [IntPtr]::Zero) | Out-Null
    [ArenaWindow]::PostMessage($client.MainWindowHandle, 7, [IntPtr]::Zero, [IntPtr]::Zero) | Out-Null
    [ArenaWindow]::PostMessage($client.MainWindowHandle, 0x201, [IntPtr]1, [IntPtr](60 + (60 -shl 16))) | Out-Null
    Start-Sleep -Milliseconds 200
    [ArenaWindow]::PostMessage($client.MainWindowHandle, 0x202, [IntPtr]::Zero, [IntPtr](60 + (60 -shl 16))) | Out-Null
    [ArenaWindow]::SetCursorPos($rect.Left + 60, $rect.Top + 80) | Out-Null
    [ArenaWindow]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
    Start-Sleep -Milliseconds 200
    [ArenaWindow]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
    Start-Sleep -Seconds 2
    $client.Refresh()
    if ($client.HasExited) { Write-Host 'Game closed after click.'; exit 1 }
}
$bitmap = New-Object Drawing.Bitmap ($rect.Right-$rect.Left), ($rect.Bottom-$rect.Top)
$graphics = [Drawing.Graphics]::FromImage($bitmap)
try {
    $graphics.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bitmap.Size)
    $path = Join-Path $PSScriptRoot 'runtime/client-window.png'
    $bitmap.Save($path, [Drawing.Imaging.ImageFormat]::Png)
    Write-Host $path
} finally { $graphics.Dispose(); $bitmap.Dispose() }
