param(
    [string]$source,
    [string]$output,
    [string]$include_runtime,
    [string]$media_dir
)

Write-Host "Setting up Blitz3D compiler..."

$compilerPath = "$env:RUNNER_TEMP\blitz3d"
$env:blitzpath = $compilerPath

New-Item -ItemType Directory -Force -Path $compilerPath | Out-Null

Copy-Item "$env:GITHUB_ACTION_PATH\blitz3d\*" $compilerPath -Recurse -Force

$content = Get-Content $source -Raw

$pattern = 'Global\s+GAME_VERSION_TAG\$="(\d+)\.(\d+)\.(\d+)\.Beta(\d+)"'

if ($content -match $pattern) {

    $major = [int]$matches[1]
    $minor = [int]$matches[2]
    $patch = [int]$matches[3]
    $beta  = [int]$matches[4] + 1

    $newVersion = "$major.$minor.$patch.Beta$beta"

    $newLine = "Global GAME_VERSION_TAG$=`"$newVersion`""

    $content = [regex]::Replace($content, $pattern, $newLine)

    Set-Content $source $content

    Write-Host "Version bumped to $newVersion"

    $env:GAME_VERSION = $newVersion
}
else {
    throw "GAME_VERSION_TAG not found."
}


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



git config user.name "github-actions"
git config user.email "actions@github.com"

git add $source
git commit -m "Auto bump version to $env:GAME_VERSION"

git tag "$env:GAME_VERSION"

git push
git push origin "$env:GAME_VERSION"
echo "GAME_VERSION=$env:GAME_VERSION" >> $env:GITHUB_ENV