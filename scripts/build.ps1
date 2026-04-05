param(
    [string]$source,
    [string]$output,
    [string]$name,
    [string]$bump_version,
    [string]$compiler_path
)
$env:blitzpath = $compiler_path

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

Write-Host "Running: & `"$compiler_path\bin\blitzcc.exe`" -o `"$name`" `"$source`""
$compile_output =& "$compiler_path\bin\blitzcc.exe" -o "$name.exe" "`"$source`"" 

if ($LASTEXITCODE -ne 0) {
    $lastLine = $compile_output[-1]
    if ($lastLine -match '(.*?)(?::(\d+)):(\d+):(\d+):(\d+):(.+)$') {
        $sourceFile = $matches[1]
        $lineNumber = $matches[2]
        $colNumber = $matches[3]
        $endLine = $matches[4]
        $endCol = $matches[5]
        $errorMessage = $matches[6]
        Write-Host "::error file=$sourceFile line=$lineNumber col=$colNumber endLine=$endLine endCol=$endCol:: $errorMessage"
    }
    else {
        Write-Host "::error::$lastLine"
    }
    throw "Blitz3D compilation failed. Exit code: $LASTEXITCODE"
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
Write-Host "Build completed successfully."


if ($bump_version -ne "") {
    git config user.name "github-actions"
    git config user.email "actions@github.com"

    git add $source
    git commit -m "Auto bump version to $env:GAME_VERSION"

    git tag "$env:GAME_VERSION"

    git push
    git push origin "$env:GAME_VERSION"
    echo "GAME_VERSION=$env:GAME_VERSION" >> $env:GITHUB_ENV
}
