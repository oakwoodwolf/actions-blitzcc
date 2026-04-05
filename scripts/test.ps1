param(
    [string]$source,
    [string]$compiler_path
)
$env:blitzpath = $compiler_path
if (-not (Test-Path $source)) {
    throw "Source file not found: $source"
}
Write-Host "Running: & `"$compiler_path\bin\blitzcc.exe`" -q -c `"$source`""
$compileOutput = & "$compiler_path\bin\blitzcc.exe" -q -c "`"$source`""

if ($LASTEXITCODE -ne 0) {
    $file = Split-Path $source -Leaf
    $lastLine = $compileOutput[-1]
    # Match the pattern that contains the error message, line number, and column number
    if ($lastLine -match '(.*?)(?::(\d+)):(\d+):(.+)$') {
        $sourceFile = $matches[1]
        $lineNumber = $matches[2]
        $colNumber = $matches[3]
        $errorMessage = $matches[4]

        # Print in the desired format:
        Write-Host "::error file=$sourceFile line=$lineNumber col=$colNumber:: $errorMessage"
    }
    else {
        # If no match, print the full output for diagnostics
        Write-Host "No matching error found in the compilation output:"
        Write-Host $lastLine
    }
    throw "Blitz3D compilation failed. Exit code: $LASTEXITCODE"
}

Write-Host "Build completed successfully. No errors found."
