param(
    [string]$source,
    [string]$output,
    [string]$name,
    [string]$bump_version
)

Write-Host "Setting up Blitz3D compiler..."

$compilerPath = "$env:RUNNER_TEMP\blitz3d"
$env:blitzpath = $compilerPath

New-Item -ItemType Directory -Force -Path $compilerPath | Out-Null

Copy-Item "$env:GITHUB_ACTION_PATH\blitz3d\*" $compilerPath -Recurse -Force
if (-not (Test-Path "$compilerPath\bin\blitzcc.exe")) {
    throw "Blitz3D compiler not found at: $compilerPath\bin\blitzcc.exe"
}

if ($bump_version -ne "") {
    Write-Host "Bumping version in $source..."
    $content = Get-Content $source -Raw

    $pattern = "Global\s+$bump_version\$=`"(\d+)\.(\d+)\.(\d+)\.Beta(\d+)`""
    Write-Host "Looking for pattern: $pattern"
    if ($content -match $pattern) {

        $major = [int]$matches[1]
        $minor = [int]$matches[2]
        $patch = [int]$matches[3]
        $beta  = [int]$matches[4] + 1

        $newVersion = "$major.$minor.$patch.Beta$beta"

        $newLine = "Global $bump_version$=`"$newVersion`""

        $content = [regex]::Replace($content, $pattern, $newLine)

        Set-Content $source $content

        Write-Host "Version bumped to $newVersion"

        $env:GAME_VERSION = $newVersion
    }
    else {
        throw "$bump_version not found."
    }
}

Write-Host "Compiling $source"

Write-Host "Output directory: $output"

New-Item -ItemType Directory -Force -Path $output | Out-Null

Write-Host "Running: & `"$compilerPath\bin\blitzcc.exe`" `"$source`" -o `"$name`""
& "$compilerPath\bin\blitzcc.exe" -o "$name.exe" "`"$source`"" 

if ($LASTEXITCODE -ne 0) {
    throw "Blitz3D compilation failed."
}

Write-Host "Checking for executable..."
if (-not (Test-Path "$name.exe")) {
    Write-Host "Expected exe not found at: $name"
    Get-ChildItem (Split-Path $source) -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "  $($_.Name)" }
    Write-Host "Contents of output directory ($output):"
    Get-ChildItem $output -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "  $($_.Name)" }
    throw "Compilation succeeded but $name.exe not found at: $output"
}
Copy-Item "$name.exe" $output -Force

Write-Host "Executable created at: $output"
if ($include_runtime -eq "true") {
    Write-Host "Copying userlibraries to $output"
    Copy-Item "$compilerPath\bin\B3D-AS.dll" $output -Force
    Copy-Item "$compilerPath\bin\Blitzcord.dll" $output -Force
    Copy-Item "$compilerPath\bin\discord_game_sdk.dll" $output -Force
}

if ($media_dir -ne "") {
    Copy-Item $media_dir "$output\$media_dir" -Recurse -Force
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
