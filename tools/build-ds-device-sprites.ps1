param([Parameter(Mandatory=$true)][string]$CoilSheet, [Parameter(Mandatory=$true)][string]$AntennaSheet)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$project = Split-Path $PSScriptRoot -Parent
$assets = Join-Path $project 'game-mod/Graphics/ArenaDevices'
$sources = Join-Path $project 'game-mod/AssetSources'
$previous = Join-Path $sources 'DeviceArt-previous'
$current = Join-Path $sources 'DeviceArt-DS'
New-Item -ItemType Directory -Path $previous,$current -Force | Out-Null
foreach ($name in @('coil','antenna','coil-R','coil-L','coil-U','coil-D','antenna-R','antenna-L','antenna-U','antenna-D')) {
    $backup = Join-Path $previous "$name.png"
    if (!(Test-Path -LiteralPath $backup)) { Copy-Item -LiteralPath (Join-Path $assets "$name.png") -Destination $backup }
}
$directions = @('R','L','U','D')
foreach ($kind in @('coil','antenna')) {
    $path = if ($kind -eq 'coil') { $CoilSheet } else { $AntennaSheet }
    Copy-Item -LiteralPath $path -Destination (Join-Path $sources "device-$kind-ds.png") -Force
    $sheet = [Drawing.Bitmap]::FromFile($path)
    $cells = @()
    for ($i=0; $i -lt 4; $i++) {
        $cell = $sheet.Clone([Drawing.Rectangle]::new($i * ($sheet.Width/4),0,$sheet.Width/4,$sheet.Height),[Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $left=$cell.Width; $top=$cell.Height; $right=-1; $bottom=-1
        for ($y=0; $y -lt $cell.Height; $y++) {
            for ($x=0; $x -lt $cell.Width; $x++) {
                if ($cell.GetPixel($x,$y).A -ge 128) {
                    $left=[Math]::Min($left,$x); $right=[Math]::Max($right,$x)
                    $top=[Math]::Min($top,$y); $bottom=[Math]::Max($bottom,$y)
                }
            }
        }
        if ($right -lt $left) { throw "Empty $kind view $i" }
        $cells += [pscustomobject]@{ Image=$cell; Left=$left; Top=$top; Width=$right-$left+1; Height=$bottom-$top+1 }
    }
    $maxWidth = ($cells | Measure-Object -Property Width -Maximum).Maximum
    $maxHeight = ($cells | Measure-Object -Property Height -Maximum).Maximum
    $scale = [Math]::Min(28.0/$maxWidth,40.0/$maxHeight)
    for ($i=0; $i -lt 4; $i++) {
        $cell=$cells[$i]; $width=[int][Math]::Round($cell.Width*$scale); $height=[int][Math]::Round($cell.Height*$scale)
        $tile=[Drawing.Bitmap]::new(32,64)
        $g=[Drawing.Graphics]::FromImage($tile)
        $g.InterpolationMode=[Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
        $g.PixelOffsetMode=[Drawing.Drawing2D.PixelOffsetMode]::Half
        $g.DrawImage($cell.Image,[Drawing.Rectangle]::new([int]((32-$width)/2),63-$height,$width,$height),$cell.Left,$cell.Top,$cell.Width,$cell.Height,[Drawing.GraphicsUnit]::Pixel)
        $g.Dispose(); $cell.Image.Dispose()
        # Native sprites use hard alpha and crisp nearest-neighbour pixels.
        for ($y=0; $y -lt 64; $y++) { for ($x=0; $x -lt 32; $x++) {
            $pixel=$tile.GetPixel($x,$y)
            $tile.SetPixel($x,$y, $(if ($pixel.A -ge 128) { [Drawing.Color]::FromArgb(255,$pixel.R,$pixel.G,$pixel.B) } else { [Drawing.Color]::Transparent }))
        } }
        $tile.Save((Join-Path $current "$kind-$($directions[$i]).png"),[Drawing.Imaging.ImageFormat]::Png)
        $tile.Dispose()
    }
    $sheet.Dispose()
    Copy-Item -LiteralPath (Join-Path $current "$kind-R.png") -Destination (Join-Path $current "$kind.png") -Force
}
& "$PSScriptRoot/select-device-art.ps1" -Style DS
