# PowerShell script that will create the SBOM file

# 1 Preparation
# 1.a general settings
$ErrorActionPreference = "Stop"
function Fail-On-Error {
    param(
        $description
    )

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Executing '$description' failed with exit code $LASTEXITCODE."
        exit 1
    }
}

# 1.b Create a temporary folder
$tempPath = Join-Path $PSScriptRoot "_temp"
New-Item -ItemType Directory -Force -Path $tempPath

# 2 Create NuGet SBOM
# 2.a install the .Net tool
dotnet tool install cyclonedx --tool-path $tempPath

# 2.b create nuget bom
$cyclonDxToolPath = Join-Path $tempPath "dotnet-CycloneDX.exe"
& "${cyclonDxToolPath}" --output "${tempPath}" -f "nuget.bom.xml" --exclude-dev src\DemoExample.csproj

# 3 Create NPM SBOM
$packageJsonPath = Join-Path $PSScriptRoot ".." "src" "package.json"
$npmBomPath = Join-Path $tempPath "npm.bom.xml"

# 3.a make sure the package is installed
Push-Location (Join-Path $PSScriptRoot ".." "src")
npm install --omit=optional
Fail-On-Error "npm install"
Pop-Location

# 3.b. create actual NPM SBOM
npx --yes "@cyclonedx/cyclonedx-npm" "${packageJsonPath}" --omit dev --output-format XML --output-file "${npmBomPath}"
Fail-On-Error "cyclonedx-npm"

# 4 Merge SBOMs
# 4.a download cyclonedx-cli.exe
$cycloneDxCliToolPath = Join-Path $tempPath "cyclonedx-cli.exe"
if (-Not (Test-Path $cycloneDxCliToolPath)) {
    $releases = Invoke-RestMethod -Uri "https://api.github.com/repos/CycloneDX/cyclonedx-cli/releases"
    $asset = ($releases | Select-Object -First 1).assets | ? { $_.name -eq "cyclonedx-win-x64.exe" }
    Invoke-WebRequest -Uri ($asset.browser_download_url) -OutFile "${cycloneDxCliToolPath}"
}

# 4.b merge both SBOMs into a final one
$nugetBomPath = Join-Path $tempPath "nuget.bom.xml"
$finalBomPath = Join-Path $PSScriptRoot ".." "_BuildResult-unsigned" "bom.xml"
& "${cycloneDxCliToolPath}" merge --input-files "${npmBomPath}" "${nugetBomPath}" --output-format "xml" --output-file "${finalBomPath}" --group "com.SignPath.demos" --name "SignPath Demo Application" --version "1.0.0"