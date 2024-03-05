New-Item -ItemType Directory -Force -Path verification

# Get signing request details
$signingRequestDetails = Invoke-RestMethod -Headers @{ Authorization = "Bearer ${env:SIGNPATH_CI_USER_TOKEN}" } `
    "https://app.signpath.io/Api/v1/${env:SIGNPATH_ORGANIZATION_ID}/SigningRequests/${env:SIGNPATH_SIGNING_REQUEST_ID}"
# Get project details
$projectDetails = Invoke-RestMethod -Headers @{ Authorization = "Bearer ${env:SIGNPATH_CI_USER_TOKEN}" } `
    "https://app.signpath.io/Api/v1-pre/${env:SIGNPATH_ORGANIZATION_ID}/Projects/$($signingRequestDetails.projectSlug)"
# Extract signing policy from project details
$signingPolicyDetails = $projectDetails.signingPolicies `
    | Where-Object {$_.metadata.slug -eq $signingRequestDetails.signingPolicySlug} `
    | Select -First 1

# Download certificate
Invoke-WebRequest -Headers @{ Authorization = "Bearer ${env:SIGNPATH_CI_USER_TOKEN}" } `
    "$($signingPolicyDetails.certificateUrl)/X509Certificate" -OutFile verification/certificate.cer
# Extract public key
openssl x509 -pubkey -noout -in verification/certificate.cer -inform DER -out verification/public_key.pem

# Download verify tool
$releases = Invoke-RestMethod -Uri "https://api.github.com/repos/signpath/cyclonedx-cli/releases"
$asset = ($releases | Select-Object -First 1).assets | ? { $_.name -eq "cyclonedx-win-x64.exe" }
Invoke-WebRequest -Uri ($asset.browser_download_url) -OutFile "verification/cyclonedx-cli.exe"

# Actual verification
& ./verification/cyclonedx-cli.exe verify all ./_BuildResult-signed/bom.xml --key-file ./verification/public_key.pem 