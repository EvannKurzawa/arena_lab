param([Parameter(Mandatory=$true)][string]$SourceRoot)
$ErrorActionPreference = 'Stop'
$files=@('exec-55815a59-7af0-4809-9512-ea2f4dc6795c.png','exec-6766b2ad-6de8-4852-a436-bb441faab20c.png','exec-dac9577f-85bc-4122-b169-a592096b1272.png','exec-641b1ab1-b4a4-4f4e-a356-b64f62d2442f.png')
$sources=$files | ForEach-Object { Join-Path $SourceRoot $_ }
& "$PSScriptRoot/../game-mod/tools/build_device_sprites.ps1" -Sources $sources -Names @('coil-R','coil-L','coil-U','coil-D')
Add-Type -AssemblyName System.Drawing
$canvas=New-Object Drawing.Bitmap 256,128
$g=[Drawing.Graphics]::FromImage($canvas)
$g.Clear([Drawing.Color]::FromArgb(165,224,203))
$g.InterpolationMode=[Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode=[Drawing.Drawing2D.PixelOffsetMode]::Half
$i=0
foreach ($direction in @('R','L','U','D')) {
  $src=[Drawing.Bitmap]::FromFile((Join-Path $PSScriptRoot "../game-mod/Graphics/ArenaDevices/coil-$direction.png"))
  $g.DrawImage($src,[Drawing.Rectangle]::new($i*64,0,64,128),0,0,32,64,[Drawing.GraphicsUnit]::Pixel)
  $src.Dispose(); $i++
}
$g.Dispose()
$canvas.Save((Join-Path $PSScriptRoot 'runtime/tesla-body-preview.png'),[Drawing.Imaging.ImageFormat]::Png)
$canvas.Dispose()
