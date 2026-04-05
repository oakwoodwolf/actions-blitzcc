Write-Host "Setting up Blitz3D compiler..."

$compilerPath = "$env:RUNNER_TEMP\blitz3d"
$env:blitzpath = $compilerPath

New-Item -ItemType Directory -Force -Path $compilerPath | Out-Null

Copy-Item "$env:GITHUB_ACTION_PATH\blitz3d\*" $compilerPath -Recurse -Force
if (-not (Test-Path "$compilerPath\bin\blitzcc.exe")) {
    throw "Blitz3D compiler not found at: $compilerPath\bin\blitzcc.exe"
}

Write-Output "compiler_path=$($compilerPath)" >> $Env:GITHUB_OUTPUT
