param(
    [string]$source,
    [string]$compiler_path
)
$env:blitzpath = $compiler_path
if (-not (Test-Path $source)) {
    throw "Source file not found: $source"
}
Write-Host "Running: & `"$compiler_path\bin\blitzcc.exe`" -q -c `"$source`""
$compile_output = & "$compiler_path\bin\blitzcc.exe" -q -c "`"$source`""

if ($LASTEXITCODE -ne 0) {
    $lastLine = $compile_output[-1]
    if ($lastLine -match '(.*?)(?::(\d+)):(\d+):(.+)$') {
        $sourceFile = $matches[1] -replace '\\', '/'
        $lineNumber = $matches[2]
        $colNumber = $matches[3]
        $errorMessage = $matches[4]
        Write-Host "::error file=$sourceFile,line=$lineNumber,col=$colNumber:: $sourceFile $errorMessage"
    }
    else {
        Write-Host "::error::$lastLine"
    }
    throw "Blitz3D compilation failed. Exit code: $LASTEXITCODE"
}

Write-Host "Build completed successfully. No errors found."
