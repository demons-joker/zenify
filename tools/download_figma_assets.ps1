param(
    [string]$outDir = "assets/figma"
)

if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

Write-Host "Downloading Figma assets to $outDir ..."

$files = @(
    @{ url = 'https://www.figma.com/api/mcp/asset/93ca7f20-7da7-47dd-a63a-713a19bab3dd'; file = 'mascot.svg' },
    @{ url = 'https://www.figma.com/api/mcp/asset/3a6ac073-85eb-4ebf-9e2f-dc1f5a0bb954'; file = 'logo3.png' }
)

foreach ($f in $files) {
    $out = Join-Path $outDir $($f.file)
    Write-Host "Downloading $($f.url) -> $out"
    try {
        Invoke-WebRequest -Uri $f.url -OutFile $out -UseBasicParsing -ErrorAction Stop
        Write-Host "Saved: $out"
    } catch {
        Write-Host "Failed to download $($f.url): $_" -ForegroundColor Yellow
    }
}

Write-Host "Done. Please update pubspec.yaml if not already and run 'flutter pub get'."
