Add-Type -AssemblyName System.Drawing
$canvas=New-Object Drawing.Bitmap 896,256
$g=[Drawing.Graphics]::FromImage($canvas)
$g.Clear([Drawing.Color]::FromArgb(160,220,200))
$g.InterpolationMode=[Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode=[Drawing.Drawing2D.PixelOffsetMode]::Half
$i=0
foreach ($name in @('antenna-R','antenna-L','antenna-U','antenna-D','rune','web','conveyor-sheet')) {
  $src=[Drawing.Bitmap]::FromFile((Join-Path $PSScriptRoot "../game-mod/Graphics/ArenaDevices/$name.png"))
  $g.DrawImage($src,[Drawing.Rectangle]::new($i*128,0,128,256),0,0,32,64,[Drawing.GraphicsUnit]::Pixel)
  $src.Dispose(); $i++
}
$g.Dispose()
$canvas.Save((Join-Path $PSScriptRoot 'runtime/device-revision-preview.png'),[Drawing.Imaging.ImageFormat]::Png)
$canvas.Dispose()
