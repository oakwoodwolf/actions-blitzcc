Write-Host "Setting up Blitz3D compiler..."

$compilerPath = "$env:RUNNER_TEMP\blitz3d"
$env:blitzpath = $compilerPath

New-Item -ItemType Directory -Force -Path $compilerPath | Out-Null

Copy-Item "$env:GITHUB_ACTION_PATH\blitz3d\*" $compilerPath -Recurse -Force
if (-not (Test-Path "$compilerPath\bin\blitzcc.exe")) {
    throw "Blitz3D compiler not found at: $compilerPath\bin\blitzcc.exe"
}

Write-Host "Copying userlibraries into the Blitz3D path..."
$dllFiles = Get-ChildItem -Path $env:GITHUB_WORKSPACE -Filter *.dll -File

if ($dllFiles.Count -gt 0) {
    Write-Host "Copying DLLs: $($dllFiles.Name -join ', ')"
    Copy-Item $dllFiles.FullName -Destination "$compilerPath\bin" -Force
    Copy-Item $dllFiles.FullName -Destination "$compilerPath\userlibs" -Force
}
else {
    Write-Host "::warning::No .dll files found in repository root. Does your project include any Blitz3D user libraries?"
}

$declFiles = Get-ChildItem -Path $env:GITHUB_WORKSPACE -Filter *.decls -File

if ($declFiles.Count -eq 0) {
    Write-Host "::warning::No .decls files found in repository root. Does your project include any Blitz3D user libraries?"
}
else {
    Write-Host "Copying .decls files: $($declFiles.Name -join ', ')"
    $declFiles | ForEach-Object {
        Copy-Item $_.FullName -Destination "$compilerPath\userlibs" -Force
        if (-not (Test-Path "$compilerPath\userlibs\$($_.Name)")) {
            Write-Host "::warning::Failed to copy .decls file: $compilerPath\userlibs\$($_.Name)"
        }
    }
}

Write-Output "compiler_path=$($compilerPath)" >> $Env:GITHUB_OUTPUT
