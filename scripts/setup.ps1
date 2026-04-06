Write-Host "Setting up Blitz3D compiler..."

$compilerPath = "$env:RUNNER_TEMP\blitz3d"
$env:blitzpath = $compilerPath

New-Item -ItemType Directory -Force -Path $compilerPath | Out-Null

Copy-Item "$env:GITHUB_ACTION_PATH\blitz3d\*" $compilerPath -Recurse -Force
if (-not (Test-Path "$compilerPath\bin\blitzcc.exe")) {
    throw "Blitz3D compiler not found at: $compilerPath\bin\blitzcc.exe"
}

Write-Host "Copying userlibraries into the Blitz3D path..."
Get-ChildItem -Path $env:GITHUB_WORKSPACE -Filter *.dll -File |
    Copy-Item -Destination "$compilerPath\bin" -Force
    Copy-Item -Destination "$compilerPath\userlibs" -Force

$declFiles = Get-ChildItem -Path $env:GITHUB_WORKSPACE -Filter *.decl -File

if ($declFiles.Count -eq 0) {
    Write-Host "::warning::No .decl files found in repository root. Does your project include any Blitz3D user libraries?"
}
else {
    Write-Host "Copying .decl files to Blitz3D userlibs..."
    $declFiles | Copy-Item -Destination "$compilerPath\userlibs" -Force
}

Write-Output "compiler_path=$($compilerPath)" >> $Env:GITHUB_OUTPUT
