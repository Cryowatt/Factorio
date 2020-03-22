[cmdletbinding()]
param(
    [version]$FactorioVersion
)

$availableVersions = Invoke-RestMethod https://updater.factorio.com/get-available-versions

$latestVersion = $availableVersions.'core-linux_headless64' | 
    ForEach-Object { [version]$_.to } | 
    Where-Object { $_.Major -eq $FactorioVersion.Major -and $_.Minor -eq $FactorioVersion.Minor } |
    Sort-Object |
    Select-Object -Last 1

$latestVersion.ToString(3)