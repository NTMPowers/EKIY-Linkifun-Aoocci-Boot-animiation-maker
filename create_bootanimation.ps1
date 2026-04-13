param(
    [Parameter(Mandatory=$true)]
    [string]$video,

    [Parameter(Mandatory=$true)]
    [string]$start,

    [ValidateRange(1,40)]
    [int]$framecount = 40,

    [bool]$loop = $false
)

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$FFmpegPath = Join-Path $ScriptDir "ffmpeg.exe"

# Check for ffmpeg.exe
if (-not (Test-Path $FFmpegPath)) {
    Write-Host "ERROR: ffmpeg.exe not found in script folder:"
    Write-Host "       $ScriptDir"
    exit
}

# Prepare work folder
$WorkDir = Join-Path $ScriptDir "zqc_tfcard_work"
if (Test-Path $WorkDir) { Remove-Item $WorkDir -Recurse -Force }
New-Item -ItemType Directory -Path $WorkDir | Out-Null

# Prepare part0 folder
$part0 = Join-Path $WorkDir "part0"
New-Item -ItemType Directory -Path $part0 | Out-Null

# Calculate duration based on frame count (10 fps)
$Duration = $framecount / 10

# Extract frames
& $FFmpegPath -ss $start -i "$video" -t $Duration -vf "crop=iw:iw/2,scale=1440:720,fps=10" -q:v 2 "$part0/%02d.jpg"

# Determine play mode line
if ($loop) {
    $DescLine = "p 0 0 part0"
} else {
    $DescLine = "p 1 0 part0"
}

# Create desc.txt
$descPath = Join-Path $WorkDir "desc.txt"
$desc = @"
1440 720 10
$DescLine
"@
Set-Content -Path $descPath -Value $desc -Encoding ASCII

# Create bootanimation.zip (no compression)
$ZipPath = Join-Path $WorkDir "bootanimation.zip"
if (Test-Path $ZipPath) { Remove-Item $ZipPath -Force }

Add-Type -AssemblyName System.IO.Compression.FileSystem

# Temp folder for clean zip contents
$TempZipDir = Join-Path $WorkDir "ziptemp"
New-Item -ItemType Directory -Path $TempZipDir | Out-Null

Copy-Item $part0 -Destination $TempZipDir -Recurse
Copy-Item $descPath -Destination $TempZipDir

[System.IO.Compression.ZipFile]::CreateFromDirectory($TempZipDir, $ZipPath, [System.IO.Compression.CompressionLevel]::NoCompression, $false)

# Cleanup: remove everything except bootanimation.zip
Remove-Item $TempZipDir -Recurse -Force
Remove-Item $part0 -Recurse -Force
Remove-Item $descPath -Force

Write-Host "Done! bootanimation.zip created in:"
Write-Host "       $WorkDir"
