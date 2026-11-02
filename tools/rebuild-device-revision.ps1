param([Parameter(Mandatory=$true)][string]$SourceRoot)
$ErrorActionPreference = 'Stop'
$base=$SourceRoot
$files=@('exec-7607187f-c19a-43ed-8c8b-1ac79fb0875c.png','exec-7afce080-b59e-4bcb-9691-1da945c280e0.png','exec-f91b4fab-a994-4173-8fa6-411b24a11c61.png','exec-9bdb25d7-d030-4c79-af66-83828d5bc41a.png','exec-0cb12180-3938-4b11-9aef-7d645fcb0a6f.png','exec-447e51ae-acdf-47f5-a7c6-cda33b9578a1.png')
$sources=$files | ForEach-Object { Join-Path $base $_ }
& "$PSScriptRoot/../game-mod/tools/build_device_sprites.ps1" -Sources $sources -Names @('rune','web','antenna-R','antenna-L','antenna-U','antenna-D')
& "$PSScriptRoot/../game-mod/tools/build_device_sprites.ps1" -Names @('conveyor')
# Guarantee matching side views and an unambiguous left-facing emitter.
$assetRoot=Join-Path $PSScriptRoot '../game-mod/Graphics/ArenaDevices'
$right=[Drawing.Bitmap]::FromFile((Join-Path $assetRoot 'antenna-R.png'))
$right.RotateFlip([Drawing.RotateFlipType]::RotateNoneFlipX)
$right.Save((Join-Path $assetRoot 'antenna-L.png'),[Drawing.Imaging.ImageFormat]::Png)
$right.Dispose()
