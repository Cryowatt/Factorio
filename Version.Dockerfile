FROM mcr.microsoft.com/powershell AS version
ADD Get-LatestVersion.ps1 .
ENTRYPOINT [ "pwsh", "--File", "./Get-LatestVersion.ps1" ]