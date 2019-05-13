[cmdletbinding()]
param()
$availableVersions = Invoke-RestMethod https://updater.factorio.com/get-available-versions
$stable = [version]($availableVersions.'core-linux_headless64' | Where-Object { $_.stable } | Select-Object -ExpandProperty stable)
$allVersions = $availableVersions.'core-linux_headless64' | ForEach-Object { $_.from; $_.to } | Select-Object -Unique | ForEach-Object { [version] $_ }

$allVersions | ForEach-Object {
    try
    {
        Write-Verbose "Checking for version $_"
        Invoke-WebRequest -Method HEAD https://www.factorio.com/get-download/$_/headless/linux64 -ErrorAction SilentlyContinue | Write-Debug
        Write-Progress -Activity "Building image for version $_"
        docker pull cryowatt/factorio:$_
        docker build --build-arg FACTORIO_VERSION=$_ --tag cryowatt/factorio:$_ .
        docker push cryowatt/factorio:$_
    }
    catch
    {
    }
}

docker tag cryowatt/factorio:$stable cryowatt/factorio:latest
docker push cryowatt/factorio:latest

$latestExperimentalVersion = $allVersions | Sort-Object -Descending | Select-Object -First 1
docker tag cryowatt/factorio:$latestExperimentalVersion cryowatt/factorio:experimental
docker push cryowatt/factorio:experimental