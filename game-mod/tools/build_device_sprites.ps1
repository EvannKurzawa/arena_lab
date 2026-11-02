param([string[]]$Sources, [string[]]$Names = @('conveyor','teleporter','rune','antenna','web'))
# Packs imagegen originals into native transparent 32px sprites.
Add-Type -AssemblyName System.Drawing
$destination = Join-Path $PSScriptRoot '../Graphics/ArenaDevices'
for ($index = 0; $index -lt $Names.Length; $index++) {
  if ($Names[$index] -eq 'conveyor') {
    # A period of 16 and four 4px steps close the loop exactly. Draw the
    # entire belt analytically: never wrap a cropped, nonperiodic picture.
    $sheet=New-Object Drawing.Bitmap 128,256
    for ($phase=0; $phase -lt 4; $phase++) {
      $frame=New-Object Drawing.Bitmap 32,32
      for ($y=0; $y -lt 32; $y++) {
        for ($x=0; $x -lt 32; $x++) {
          $ink=[Drawing.Color]::FromArgb(24,25,27)
          if ($x -eq 0 -or $y -eq 0 -or $x -eq 31 -or $y -eq 31) { $ink=[Drawing.Color]::FromArgb(40,43,45) }
          elseif ($x -eq 1 -or $y -eq 1) { $ink=[Drawing.Color]::FromArgb(139,146,145) }
          elseif ($x -eq 30 -or $y -eq 30) { $ink=[Drawing.Color]::FromArgb(75,81,80) }
          elseif ((($x+[int][Math]::Floor([Math]::Abs($y-15.5)*0.65)-$phase*4+64)%16) -lt 4) { $ink=[Drawing.Color]::FromArgb(245,202,45) }
          $frame.SetPixel($x,$y,$ink)
        }
      }
      foreach ($pair in @(@(0,0),@(2,2),@(4,3),@(6,1))) {
        $rotated=$frame.Clone(); $rotated.RotateFlip([Drawing.RotateFlipType]$pair[1])
        $g=[Drawing.Graphics]::FromImage($sheet); $g.DrawImageUnscaled($rotated,$phase*32,$pair[0]*32)
        $g.Dispose(); $rotated.Dispose()
      }
      $frame.Dispose()
    }
    $sheet.Save((Join-Path $destination 'conveyor-sheet.png'),[Drawing.Imaging.ImageFormat]::Png); $sheet.Dispose()
    continue
  }
  $source = [Drawing.Bitmap]::FromFile($Sources[$index])
  $left=$source.Width; $top=$source.Height; $right=0; $bottom=0
  for ($y=0; $y -lt $source.Height; $y++) {
    for ($x=0; $x -lt $source.Width; $x++) {
      if ($source.GetPixel($x,$y).A -gt 100) {
        $left=[Math]::Min($left,$x); $right=[Math]::Max($right,$x)
        $top=[Math]::Min($top,$y); $bottom=[Math]::Max($bottom,$y)
      }
    }
  }
  $heightLimit = if ($Names[$index] -like 'antenna*') {46} elseif ($Names[$index] -like 'coil-*') {40} else {30}
  $scale=[Math]::Min(30.0/($right-$left+1),$heightLimit/($bottom-$top+1))
  $width=[int](($right-$left+1)*$scale); $height=[int](($bottom-$top+1)*$scale)
  $tile=New-Object Drawing.Bitmap 32,64
  $graphics=[Drawing.Graphics]::FromImage($tile)
  $graphics.InterpolationMode=[Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
  if ($Names[$index] -eq 'web') {
    # Preserve subpixel thread coverage when reducing the generated source;
    # point sampling punches random holes in the fine white strands.
    $graphics.InterpolationMode=[Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  }
  $graphics.PixelOffsetMode=[Drawing.Drawing2D.PixelOffsetMode]::Half
  $graphics.DrawImage($source,[Drawing.Rectangle]::new([int]((32-$width)/2),63-$height,$width,$height),$left,$top,$right-$left+1,$bottom-$top+1,[Drawing.GraphicsUnit]::Pixel)
  $graphics.Dispose(); $source.Dispose()
  if ($Names[$index] -eq 'web') {
    for ($y=32; $y -lt 64; $y++) {
      for ($x=0; $x -lt 32; $x++) {
        $ink = if ($tile.GetPixel($x,$y).A -ge 30) { [Drawing.Color]::FromArgb(235,242,246) } else { [Drawing.Color]::Transparent }
        $tile.SetPixel($x,$y,$ink)
      }
    }
  }
  $tile.Save((Join-Path $destination ($Names[$index]+'.png')),[Drawing.Imaging.ImageFormat]::Png)
  $tile.Dispose()
}
