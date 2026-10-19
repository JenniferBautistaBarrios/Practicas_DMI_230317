$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$assets = Join-Path $root 'assets\icons'
$sources = @{
  normal = Join-Path $assets 'Kittytoktik.png'
  halloween = Join-Path $assets 'Hallowen.png'
  christmas = Join-Path $assets 'Navidad.png'
  valentines = Join-Path $assets 'Sanvalentin.png'
}
$backgrounds = @{
  normal = '#282273'
  halloween = '#351366'
  christmas = '#064331'
  valentines = '#650D39'
}

foreach ($source in $sources.Values) {
  if (-not (Test-Path -LiteralPath $source)) { throw "No se encontró el icono: $source" }
}

function Save-ScaledPng([string]$sourcePath, [string]$destination, [int]$size, [string]$background = '') {
  $image = [System.Drawing.Image]::FromFile($sourcePath)
  $bitmap = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceOver
  $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
  $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  if ($background) { $graphics.Clear([System.Drawing.ColorTranslator]::FromHtml($background)) }
  else { $graphics.Clear([System.Drawing.Color]::Transparent) }
  $graphics.DrawImage($image, (New-Object System.Drawing.Rectangle(0, 0, $size, $size)))
  $directory = Split-Path -Parent $destination
  if (-not (Test-Path -LiteralPath $directory)) { New-Item -ItemType Directory -Path $directory | Out-Null }
  $bitmap.Save($destination, [System.Drawing.Imaging.ImageFormat]::Png)
  $graphics.Dispose(); $bitmap.Dispose(); $image.Dispose()
}

# Android adaptive-icon artwork remains transparent; legacy launcher PNGs are opaque.
$androidRes = Join-Path $root 'android\app\src\main\res'
$densitySizes = @{ mdpi = 48; hdpi = 72; xhdpi = 96; xxhdpi = 144; xxxhdpi = 192 }
$artworkSizes = @{ mdpi = 108; hdpi = 162; xhdpi = 216; xxhdpi = 324; xxxhdpi = 432 }
foreach ($theme in @('normal','halloween','christmas','valentines')) {
  $launcherName = if ($theme -eq 'normal') { 'ic_launcher' } else { "ic_launcher_$theme" }
  foreach ($density in $densitySizes.Keys) {
    Save-ScaledPng $sources[$theme] (Join-Path $androidRes "mipmap-$density\$launcherName.png") $densitySizes[$density] $backgrounds[$theme]
    $artName = if ($theme -eq 'normal') { 'ic_launcher_foreground.png' } else { "ic_launcher_${theme}_artwork.png" }
    Save-ScaledPng $sources[$theme] (Join-Path $androidRes "drawable-$density\$artName") $artworkSizes[$density]
  }
}

# iOS requires opaque launcher images. Use each icon's own dark background color.
$iosRoot = Join-Path $root 'ios\Runner\Assets.xcassets'
$iosSets = @{
  normal = 'AppIcon.appiconset'
  halloween = 'Halloween.appiconset'
  christmas = 'Christmas.appiconset'
  valentines = 'Valentines.appiconset'
}
foreach ($theme in $iosSets.Keys) {
  $setPath = Join-Path $iosRoot $iosSets[$theme]
  $catalog = Get-Content (Join-Path $setPath 'Contents.json') -Raw | ConvertFrom-Json
  foreach ($entry in $catalog.images) {
    if (-not $entry.filename) { continue }
    $match = [regex]::Match($entry.filename, '(\d+(?:\.\d+)?)x\d+@(\d+)x')
    if (-not $match.Success) { continue }
    $pixels = [int][math]::Round([double]$match.Groups[1].Value * [double]$match.Groups[2].Value)
    Save-ScaledPng $sources[$theme] (Join-Path $setPath $entry.filename) $pixels $backgrounds[$theme]
  }
}

# macOS launcher and installed-web-app icons use the normal-season mark.
$macSet = Join-Path $root 'macos\Runner\Assets.xcassets\AppIcon.appiconset'
foreach ($size in @(16,32,64,128,256,512,1024)) {
  $path = Join-Path $macSet "app_icon_$size.png"
  if (Test-Path -LiteralPath $path) { Save-ScaledPng $sources.normal $path $size $backgrounds.normal }
}
$webIcons = Join-Path $root 'web\icons'
foreach ($size in @(192,512)) {
  foreach ($name in @("Icon-$size.png", "Icon-maskable-$size.png")) {
    $path = Join-Path $webIcons $name
    if (Test-Path -LiteralPath $path) { Save-ScaledPng $sources.normal $path $size $backgrounds.normal }
  }
}
$favicon = Join-Path $root 'web\favicon.png'
if (Test-Path -LiteralPath $favicon) {
  $old = [System.Drawing.Image]::FromFile($favicon); $faviconSize = $old.Width; $old.Dispose()
  Save-ScaledPng $sources.normal $favicon $faviconSize $backgrounds.normal
}

# iOS launch storyboard uses a dedicated image set before Flutter's first frame.
$launchSet = Join-Path $iosRoot 'LaunchImage.imageset'
foreach ($launchImage in @(@('LaunchImage.png',156), @('LaunchImage@2x.png',312), @('LaunchImage@3x.png',468))) {
  Save-ScaledPng $sources.normal (Join-Path $launchSet $launchImage[0]) $launchImage[1]
}

Write-Output 'Iconos nuevos conectados: app, splash, selector de temporada, Android, iOS, macOS y web.'
