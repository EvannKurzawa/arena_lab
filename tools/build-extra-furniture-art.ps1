param([string]$SourceRoot = (Join-Path $PSScriptRoot 'runtime/furniture-sources'))
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$project=Split-Path $PSScriptRoot -Parent
$output=Join-Path $project 'game-mod/SharedAssets/Graphics/ArenaFurniture'
New-Item -ItemType Directory -Path $output -Force | Out-Null
$sources=Get-Content (Join-Path $SourceRoot 'sources.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$manifest=@()
foreach($entry in $sources){
  if($entry.name -eq 'hgss-blackthorn'){continue}
  $source=Join-Path $SourceRoot ($entry.name+'.png')
  if((Get-FileHash -LiteralPath $source).Hash.ToLowerInvariant() -ne $entry.sha256){throw "Changed source: $source"}
  $manifest += [pscustomobject]@{name=$entry.name;url=$entry.url;sha256=$entry.sha256;source=$source;rect=$null;mask='alpha'}
}
$outside=Join-Path $project 'tools/runtime/essentials-v21.1-base/Graphics/Tilesets/Outside.png'
$manifest += [pscustomobject]@{name='tree-leafy';url='local Essentials v21.1: Graphics/Tilesets/Outside.png';sha256=(Get-FileHash $outside).Hash.ToLowerInvariant();source=$outside;rect=@(0,1888,96,96);mask='alpha'}
$manifest += [pscustomobject]@{name='tree-pine';url='local Essentials v21.1: Graphics/Tilesets/Outside.png';sha256=(Get-FileHash $outside).Hash.ToLowerInvariant();source=$outside;rect=@(128,1664,64,96);mask='alpha'}
$gym=Join-Path $SourceRoot 'hgss-blackthorn.png'
$gymUrl=($sources | Where-Object name -eq 'hgss-blackthorn').url
$manifest += [pscustomobject]@{name='hgss-red-carpet';url=$gymUrl;sha256=(Get-FileHash $gym).Hash.ToLowerInvariant();source=$gym;rect=@(186,1118,28,18);mask='alpha'}
$manifest += [pscustomobject]@{name='hgss-spikes';url=$gymUrl;sha256=(Get-FileHash $gym).Hash.ToLowerInvariant();source=$gym;rect=@(96,1016,16,32);mask='cone'}
$snow=Join-Path $SourceRoot 'dppt-snowpoint.png'
$manifest += [pscustomobject]@{name='snowball';url='https://www.pokepedia.fr/images/1/1a/Ar%C3%A8ne_Frimapic_DP.png';sha256=(Get-FileHash $snow).Hash.ToLowerInvariant();source=$snow;rect=@(164,150,17,21);mask='snow'}
$floor=@('rse-stand','rse-solid-board','hgss-red-carpet')
foreach($entry in $manifest){
  $original=[Drawing.Bitmap]::FromFile($entry.source)
  $rect=if($entry.rect){[Drawing.Rectangle]::new($entry.rect[0],$entry.rect[1],$entry.rect[2],$entry.rect[3])}else{[Drawing.Rectangle]::new(0,0,$original.Width,$original.Height)}
  $crop=$original.Clone($rect,[Drawing.Imaging.PixelFormat]::Format32bppArgb);$original.Dispose()
  if($entry.mask -ne 'alpha'){
    for($y=0;$y -lt $crop.Height;$y++){for($x=0;$x -lt $crop.Width;$x++){
      $pixel=$crop.GetPixel($x,$y)
      $keep=if($entry.mask -eq 'snow'){(([Math]::Pow(($x-8)/8.5,2)+[Math]::Pow(($y-10)/10.5,2)) -le 1) -and ($pixel.B-$pixel.R -le 75)}else{
        ($y -ge 1 -and $y -le 29 -and [Math]::Abs($x-7.5) -le [Math]::Min(7.5,1+$y*0.28))
      }
      if(!$keep){$crop.SetPixel($x,$y,[Drawing.Color]::Transparent)}
    }}
  }
  $tile=[Drawing.Bitmap]::new(32,64);$g=[Drawing.Graphics]::FromImage($tile)
  $g.InterpolationMode=[Drawing.Drawing2D.InterpolationMode]::NearestNeighbor;$g.PixelOffsetMode=[Drawing.Drawing2D.PixelOffsetMode]::Half
  $height=if($entry.name -in $floor){32}else{64}
  $scale=[Math]::Min(32.0/$crop.Width,$height/[double]$crop.Height)
  $width=[int][Math]::Round($crop.Width*$scale);$height=[int][Math]::Round($crop.Height*$scale)
  $g.DrawImage($crop,[Drawing.Rectangle]::new([int]((32-$width)/2),64-$height,$width,$height),0,0,$crop.Width,$crop.Height,[Drawing.GraphicsUnit]::Pixel)
  $g.Dispose();$crop.Dispose()
  $target=Join-Path $output ($entry.name+'.png')
  $tile.Save($target,[Drawing.Imaging.ImageFormat]::Png);$tile.Dispose()
  $entry | Add-Member NoteProperty packed_sha256 (Get-FileHash $target).Hash.ToLowerInvariant()
}
$manifest | Select-Object name,url,sha256,rect,mask,packed_sha256 | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $project 'game-mod/AssetSources/furniture-sources.json') -Encoding UTF8
Write-Host "Packed $($manifest.Count) original furniture sprites into $output"
