Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

$root = Split-Path -Parent $PSScriptRoot
$source = Join-Path $root 'assets\icons\vdry-halloween.png'
$backup = Join-Path $PSScriptRoot 'vdry-halloween-before-redesign.png'
if (-not (Test-Path $backup)) { Copy-Item -LiteralPath $source -Destination $backup }

function New-Canvas([int]$size) {
  $bitmap = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $graphics.ScaleTransform($size / 1024.0, $size / 1024.0)
  return @{ Bitmap = $bitmap; Graphics = $graphics }
}

function Write-Icon([string]$path, [int]$size) {
  $canvas = New-Canvas $size
  $b = $canvas.Bitmap
  $g = $canvas.Graphics
  $g.Clear([System.Drawing.Color]::FromArgb(255, 22, 12, 45))

  $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Rectangle(0, 0, 1024, 1024)),
    ([System.Drawing.Color]::FromArgb(255, 22, 12, 50)),
    ([System.Drawing.Color]::FromArgb(255, 75, 25, 108)), 45.0)
  $g.FillRectangle($bg, 0, 0, 1024, 1024)
  $bg.Dispose()

  $glow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(28, 255, 145, 40))
  $g.FillEllipse($glow, 126, 126, 772, 772)
  $glow.Dispose()

  $ring = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(75, 255, 215, 132), 5)
  $g.DrawEllipse($ring, 94, 94, 836, 836)
  $ring.Dispose()

  # Small glowing stars around the central badge.
  $starBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 222, 164))
  foreach ($point in @('218,250','794,264','182,650','846,656','306,812','704,182')) {
    $coordinates = $point.Split(',')
    $g.FillEllipse($starBrush, [int]$coordinates[0], [int]$coordinates[1], 9, 9)
  }
  $starBrush.Dispose()

  # Pumpkin silhouette with dimensional lobes.
  $shadow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(80, 9, 4, 25))
  $g.FillEllipse($shadow, 225, 744, 575, 75)
  $shadow.Dispose()
  $outline = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 120, 47, 55), 10)
  $pumpkin = New-Object System.Drawing.Drawing2D.GraphicsPath
  $pumpkin.AddBezier(512, 350, 436, 303, 326, 358, 291, 447)
  $pumpkin.AddBezier(291, 447, 211, 575, 301, 751, 431, 773)
  $pumpkin.AddBezier(431, 773, 468, 783, 494, 777, 512, 761)
  $pumpkin.AddBezier(512, 761, 531, 779, 561, 783, 596, 773)
  $pumpkin.AddBezier(596, 773, 729, 748, 810, 577, 733, 447)
  $pumpkin.AddBezier(733, 447, 686, 358, 579, 303, 512, 350)
  $bodyBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Rectangle(416, 330, 196, 450)),
    ([System.Drawing.Color]::FromArgb(255, 255, 177, 57)),
    ([System.Drawing.Color]::FromArgb(255, 255, 104, 25)), 90.0)
  $g.FillPath($bodyBrush, $pumpkin)
  $bodyBrush.Dispose()
  $g.DrawPath($outline, $pumpkin)
  $outline.Dispose(); $pumpkin.Dispose()
  $groove = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(125, 168, 69, 35), 8)
  $groove.StartCap = [System.Drawing.Drawing2D.LineCap]::Round; $groove.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $g.DrawBezier($groove, 404, 385, 336, 488, 365, 656, 437, 742)
  $g.DrawBezier($groove, 620, 385, 688, 488, 659, 656, 587, 742)
  $groove.Dispose()

  # Stem and leaf.
  $stemPath = New-Object System.Drawing.Drawing2D.GraphicsPath
  $stemPath.AddBezier(483, 378, 473, 326, 509, 296, 514, 258)
  $stemPath.AddBezier(514, 258, 546, 281, 558, 322, 545, 383)
  $stemPath.CloseFigure()
  $stemBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Rectangle(478, 258, 84, 125)),
    ([System.Drawing.Color]::FromArgb(255, 117, 68, 31)),
    ([System.Drawing.Color]::FromArgb(255, 53, 42, 49)), 20.0)
  $g.FillPath($stemBrush, $stemPath)
  $stemBrush.Dispose(); $stemPath.Dispose()
  $leaf = New-Object System.Drawing.Drawing2D.GraphicsPath
  $leaf.AddBezier(519, 296, 555, 261, 598, 274, 619, 302)
  $leaf.AddBezier(619, 302, 581, 308, 556, 330, 537, 353)
  $leaf.AddBezier(537, 353, 526, 329, 519, 311, 519, 296)
  $leaf.CloseFigure()
  $leafBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Rectangle(519, 270, 100, 84)),
    ([System.Drawing.Color]::FromArgb(255, 79, 203, 145)),
    ([System.Drawing.Color]::FromArgb(255, 37, 112, 114)), 45.0)
  $g.FillPath($leafBrush, $leaf); $leafBrush.Dispose(); $leaf.Dispose()

  # Friendly carved face: two sharp, warm eyes and a confident smile.
  $face = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 67, 27, 60))
  $g.FillPolygon($face, [System.Drawing.PointF[]]@((New-Object System.Drawing.PointF(365, 500)),(New-Object System.Drawing.PointF(434, 532)),(New-Object System.Drawing.PointF(411, 584))))
  $g.FillPolygon($face, [System.Drawing.PointF[]]@((New-Object System.Drawing.PointF(658, 500)),(New-Object System.Drawing.PointF(589, 532)),(New-Object System.Drawing.PointF(612, 584))))
  $g.FillEllipse($face, 481, 541, 62, 62)
  $smile = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 67, 27, 60), 25)
  $smile.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $smile.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $g.DrawArc($smile, 389, 530, 246, 178, 18, 145)
  $smile.Dispose(); $face.Dispose()

  # Tiny cyan-magenta glints keep the app's existing KittyTokTik palette.
  $cyan = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 91, 231, 237))
  $pink = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 103, 191))
  $g.FillEllipse($cyan, 229, 352, 18, 18); $g.FillEllipse($pink, 774, 390, 16, 16)
  $cyan.Dispose(); $pink.Dispose()

  $directory = Split-Path -Parent $path
  if (-not (Test-Path $directory)) { New-Item -ItemType Directory -Path $directory | Out-Null }
  $b.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $b.Dispose()
}

# Flutter splash, settings card and web favicon source.
Write-Icon $source 1024

# Keep every platform launcher icon in sync with the seasonal asset.
$android = Join-Path $root 'android\app\src\main\res'
foreach ($qualifier in @('mdpi','hdpi','xhdpi','xxhdpi','xxxhdpi')) {
  $target = Join-Path $android "mipmap-$qualifier\ic_launcher_halloween.png"
  $size = switch ($qualifier) { 'mdpi' {48} 'hdpi' {72} 'xhdpi' {96} 'xxhdpi' {144} 'xxxhdpi' {192} }
  Write-Icon $target $size
  $artTarget = Join-Path $android "drawable-$qualifier\ic_launcher_halloween_artwork.png"
  if (Test-Path $artTarget) {
    $old = [System.Drawing.Image]::FromFile($artTarget)
    $artSize = $old.Width; $old.Dispose()
    Write-Icon $artTarget $artSize
  }
}

$iosSet = Join-Path $root 'ios\Runner\Assets.xcassets\Halloween.appiconset'
$contents = Get-Content (Join-Path $iosSet 'Contents.json') -Raw | ConvertFrom-Json
foreach ($entry in $contents.images) {
  if (-not $entry.filename) { continue }
  $match = [regex]::Match($entry.filename, '(\d+(?:\.\d+)?)x(\d+(?:\.\d+)?)@(\d+)x')
  if ($match.Success) {
    $pixels = [int][math]::Round([double]$match.Groups[1].Value * [double]$match.Groups[3].Value)
    Write-Icon (Join-Path $iosSet $entry.filename) $pixels
  }
}

Write-Output 'Halloween icon master and launcher resources regenerated.'
