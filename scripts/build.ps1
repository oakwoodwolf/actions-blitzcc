param(
    [string]$source,
    [string]$output,
    [string]$include_runtime,
    [string]$media_dir
)

Write-Host "Setting up Blitz3D compiler..."

$compilerPath = "$env:RUNNER_TEMP\blitz3d"

New-Item -ItemType Directory -Force -Path $compilerPath | Out-Null

Copy-Item "$env:GITHUB_ACTION_PATH\blitz3d\*" $compilerPath -Recurse -Force

Write-Host "Compiling $source"

$outputDir = Split-Path $output

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

& "$compilerPath\bin\blitzcc.exe" $source -o $output

if ($LASTEXITCODE -ne 0) {
    throw "Blitz3D compilation failed."
}

if ($include_runtime -eq "true") {
    Copy-Item "$compilerPath\bin\B3D-AS.dll" $outputDir -Force
    Copy-Item "$compilerPath\bin\Blitzcord.dll" $outputDir -Force
    Copy-Item "$compilerPath\bin\discord_game_sdk.dll" $outputDir -Force
}

if ($media_dir -ne "") {
    Copy-Item $media_dir "$outputDir\Data" -Recurse -Force
}

Write-Host "Build completed successfully."