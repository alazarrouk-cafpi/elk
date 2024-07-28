Write-Output "-----------Setting up Sysmon-----------"
$path = "C:\Sysmon"

Write-Output "--Creating Sysmon directory under C:"
If (!(Test-Path -Path $path)) {
     New-Item -ItemType Directory -Force -Path $path | Out-Null
}
Set-Location -Path $path

Write-Output "--Downloading sysmon"
Invoke-WebRequest -Uri "https://download.sysinternals.com/files/Sysmon.zip" -OutFile "Sysmon.zip"
Expand-Archive -Path "Sysmon.zip" -DestinationPath .
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" -OutFile "sysmonconfig-export.xml"

Write-Output "--Running sysmon"
.\\sysmon64.exe -accepteula -i sysmonconfig-export.xml


Write-Output "-----------Setting up elastic-agent-----------"

$path = "C:\Elastic"
Write-Output "--Creating Elastic directory under C:"
# Create directory if it doesn't exist
If (!(Test-Path -Path $path)) {
   New-Item -ItemType Directory -Force -Path $path | Out-Null
}
# Change to the specified directory
Set-Location -Path $path
$credentials = "elastic:Aloulou556"
$encodedCredentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($credentials))
$headers = @{ Authorization = "Basic $($encodedCredentials)" }
$url = "http://10.53.2.15:30001/api/fleet/enrollment_api_keys"
$response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
Write-Output "--Getting enrollement token"
$enrollementToken = $response.items | Where-Object { $_.policy_id -eq "windows-policy" } | Select-Object -ExpandProperty api_key
Write-Output $enrollementToken

#Write-Output "Downloading elastic agent .."
#Invoke-WebRequest -Uri https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-8.14.2-windows-x86_64.zip -OutFile elastic-agent-8.14.2-windows-x86_64.zip
Write-Output "Expanding archive .."
Expand-Archive .\elastic-agent-8.14.2-windows-x86_64.zip -DestinationPath .

Write-Output "cd elastic-agent-8.14.2-windows-x86_64 .."
Set-Location -Path .\elastic-agent-8.14.2-windows-x86_64

New-Item -ItemType Directory -Force certs
Set-Location -Path .\certs  

$blobUrl = "https://sapfe.blob.core.windows.net/elk-files/ssh-keys/master-key.pem?sp=r&st=2024-07-27T21:03:24Z&se=2024-10-18T05:03:24Z&sv=2022-11-02&sr=b&sig=R1KjcDyRtbZcb8KerABrY0wqfUyVPXDmYHbcl9%2BPspg%3D"
Invoke-WebRequest -Uri $blobUrl -OutFile "master-key.pem"
$Username=(whoami).split("\")[1]
Write-Output "Adding permission to ssh file .."
icacls C:\Elastic\elastic-agent-8.14.2-windows-x86_64\certs\master-key.pem /inheritance:r /grant "$($Username):F" /deny "Everyone:(OI)(CI)(F)"

Write-Output "getting certs"
scp -o "StrictHostKeyChecking=no" -r -i "C:\Elastic\elastic-agent-8.14.2-windows-x86_64\certs\master-key.pem"  admala@10.53.2.115:/mnt/data/certs/ca/ca.crt C:\Elastic\elastic-agent-8.14.2-windows-x86_64\certs\ca.crt
Import-Certificate -FilePath "C:\Elastic\elastic-agent-8.14.2-windows-x86_64\certs\ca.crt" -CertStoreLocation Cert:\LocalMachine\Root

Write-Output "Enrolling agent"
Set-Location -Path "C:\Elastic\elastic-agent-8.14.2-windows-x86_64"
echo "Y" | .\elastic-agent.exe install --url=https://10.53.2.15:30002 --enrollment-token=$enrollementToken --certificate-authorities C:\Elastic\elastic-agent-8.14.2-windows-x86_64\certs\ca.crt