# Upload JA2 (Stracciatella 3DS port) to the 3DS over Wi-Fi via ftpd.
# Start ftpd on the 3DS first; it shows the IP and port (default 5000).
param([string]$Ip = "", [int]$Port = 5000, [switch]$EngineOnly)
$ErrorActionPreference = "Stop"
if (-not $Ip) { $Ip = Read-Host "3DS IP address shown by ftpd" }
$base   = "ftp://${Ip}:${Port}"
$engine = "C:\devkitPro\3ds-projects\SD-CARD\3ds\ja2"
$app    = "C:\devkitPro\3ds-projects\SD-CARD\3ds\ja2.3dsx"   # the game lives directly in /3ds
$gold   = "C:\Program Files (x86)\Steam\steamapps\common\Jagged Alliance 2 Gold\Data"

function Send-Tree($localRoot, $remoteRoot) {
  $files = @(Get-ChildItem -LiteralPath $localRoot -Recurse -File | Where-Object { $_.Extension -ne '.3dsx' })
  $i = 0
  foreach ($f in $files) {
    $i++
    $rel = $f.FullName.Substring($localRoot.Length).TrimStart('\') -replace '\\','/'
    $enc = (($rel -split '/') | ForEach-Object { [uri]::EscapeDataString($_) }) -join '/'
    $url = "$base$remoteRoot/$enc"
    Write-Progress -Activity "Uploading to $remoteRoot" -Status "$i / $($files.Count)  $rel" -PercentComplete (100 * $i / $files.Count)
    # -C - resumes / skips files that are already complete, so re-running is cheap
    & curl.exe -s -S --ftp-create-dirs -C - -T $f.FullName $url
    if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne 36) { throw "Upload failed ($LASTEXITCODE): $rel" }
  }
}

# The .3dsx goes to /3ds/ja2.3dsx (not into /3ds/ja2); no -C - here, so an update always replaces it
if (Test-Path -LiteralPath $app) {
  & curl.exe -s -S --ftp-create-dirs -T $app "$base/3ds/ja2.3dsx"
  if ($LASTEXITCODE -ne 0) { throw "Upload failed ($LASTEXITCODE): ja2.3dsx" }
} else { Write-Warning "No $app - build first (3ds/build-3ds.sh)." }
Send-Tree $engine "/3ds/ja2"
if (-not $EngineOnly) { Send-Tree $gold "/3ds/ja2/gamedata/Data" }
Write-Host "`nDone. On the 3DS: Homebrew Launcher -> Jagged Alliance 2."
