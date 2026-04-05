param(
    [string]$source,
    [string]$compiler_path
)
$env:blitzpath = $compiler_path
if (-not (Test-Path $source)) {
    throw "Source file not found: $source"
}
Write-Host "Running: & `"$compiler_path\bin\blitzcc.exe`" -c `"$source`""
& "$compiler_path\bin\blitzcc.exe" -c "`"$source`""

if ($LASTEXITCODE -ne 0) {
    $file = Split-Path $source -Leaf
    Write-Host "::error file=$file::Blitz3D compilation failed. Exit code: $LASTEXITCODE"
    throw "Blitz3D compilation failed. Exit code: $LASTEXITCODE"
}

Write-Host "Build completed successfully. No errors found."
