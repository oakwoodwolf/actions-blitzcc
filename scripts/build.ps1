param(
    [string]$source,
    [string]$output,
    [string]$name,
    [string]$compiler_path
)
$env:blitzpath = $compiler_path

Write-Host "Compiling $source"

Write-Host "Output directory: $output"

New-Item -ItemType Directory -Force -Path $output | Out-Null

Write-Host "Running: & `"$compiler_path\bin\blitzcc.exe`" -o `"$name`" `"$source`""
$compile_output =& "$compiler_path\bin\blitzcc.exe" -o "$name.exe" "`"$source`"" 2>&1

if ($LASTEXITCODE -ne 0) {
    $lastLine = $compile_output[-1]
    # if ($lastLine -match '(.*?)(?::(\d+)):(\d+):(.+)$') {
        # $sourceFile = $matches[1] -replace '\\', '/'
        # $lineNumber = $matches[2]
        # $colNumber = $matches[3]
        # $errorMessage = $matches[4]
        # Write-Host "::error file=$sourceFile,line=$lineNumber,col=$colNumber:: $sourceFile $errorMessage"
    # }
    # else {
        Write-Host "::error::$lastLine"
   # }
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
