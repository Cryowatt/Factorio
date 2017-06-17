[cmdletbinding()]
param()
$releaseVersions = @(
    '0.12.35',
    '0.13.20',
    '0.14.23');

$experimentalVersions = @(
    '0.15.16',
    '0.15.18',
    '0.15.19',
    '0.15.20',
    '0.15.21');

$releaseVersions + $experimentalVersions | ForEach-Object {
    Write-Progress -Activity "Building image for version $_"
    docker build --build-arg FACTORIO_VERSION=$_ --tag cryowatt/factorio:$_ .
}

$latestReleaseVersion = $releaseVersions | Sort-Object -Descending | Select-Object -First 1
docker tag cryowatt/factorio:$latestReleaseVersion cryowatt/factorio:latest

$latestExperimentalVersion = $experimentalVersions | Sort-Object -Descending | Select-Object -First 1
docker tag cryowatt/factorio:$latestExperimentalVersion cryowatt/factorio:experimental