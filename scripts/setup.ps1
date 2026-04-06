param(
    [string]$userlib_path
)
Write-Host "Setting up Blitz3D compiler..."

$compilerPath = "$env:RUNNER_TEMP\blitz3d"
$env:blitzpath = $compilerPath

New-Item -ItemType Directory -Force -Path $compilerPath | Out-Null

Copy-Item "$env:GITHUB_ACTION_PATH\blitz3d\*" $compilerPath -Recurse -Force
New-Item -ItemType Directory -Force -Path "$compilerPath\userlibs" | Out-Null

if (-not (Test-Path "$compilerPath\bin\blitzcc.exe")) {
    throw "Blitz3D compiler not found at: $compilerPath\bin\blitzcc.exe"
}

Write-Host "Copying userlibraries into the Blitz3D path..."
$dllFiles = Get-ChildItem -Path $env:GITHUB_WORKSPACE -Filter *.dll -File

if ($dllFiles.Count -gt 0) {
    Write-Host "Copying DLLs: $($dllFiles.Name -join ', ')"
    foreach ($file in $dllFiles) {
        Copy-Item $file.FullName -Destination "$compilerPath\bin" -Force
        Copy-Item $file.FullName -Destination "$compilerPath\userlibs" -Force
    }
}
else {
    Write-Host "::warning::No .dll files found in repository root. Does your project include any Blitz3D user libraries?"
}

$declFiles = Get-ChildItem -Path "$env:GITHUB_WORKSPACE/$userlib_path" -Filter *.decls -File

if ($declFiles.Count -gt 0) {
    Write-Host "Copying .decls files: $($declFiles.Name -join ', ')"

    foreach ($file in $declFiles) {
        Copy-Item $file.FullName -Destination "$compilerPath\userlibs" -Force
    }
}
else {
        Write-Host "::warning::No .decls files found in repository root $env:GITHUB_WORKSPACE/$userlib_path. Does your project include any Blitz3D user libraries?"
}

Write-Output "compiler_path=$($compilerPath)" >> $Env:GITHUB_OUTPUT
