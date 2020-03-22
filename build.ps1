[cmdletbinding()]
param(
    [switch]
    $Experimental,
    [switch]
    $Push,
    $MinMinor = 17
)

Write-Progress -Activity "Building Factorio" -Status "Downloading versions metadata"
$availableVersions = Invoke-RestMethod https://updater.factorio.com/get-available-versions
Write-Progress -Activity "Building Factorio" -Status "Downloading versions metadata" -Completed

$versionGroups = $availableVersions.'core-linux_headless64' | 
    ForEach-Object { [version]$_.to } | 
    Group-Object { ([version]$_).ToString(2) }

$versionGroups | 
    ForEach-Object { $_.group | Measure-Object -Maximum } | 
    Select-Object -ExpandProperty Maximum |
    ForEach-Object {
        $version = $_
        $minor = $version.ToString(2)
        Write-Progress -Activity "Building Factorio" -Status "Pulling existing image"
        docker pull "cryowatt/factorio:$version"
        Write-Progress -Activity "Building Factorio" -Status "Building image"
        docker build --build-arg FACTORIO_VERSION=$version --tag "cryowatt/factorio:$version" --tag "cryowatt/factorio:$minor" .
        Write-Progress -Activity "Building Factorio" -Status "Pushing image"
        docker push "cryowatt/factorio:$version"
        docker push "cryowatt/factorio:$minor"
    }

$versionGroups | Select-Object -Last 1 -ExpandProperty Group | ForEach-Object {
    $version = $_
    Write-Progress -Activity "Building Factorio" -Status "Pulling existing image"
    docker pull "cryowatt/factorio:$version"
    Write-Progress -Activity "Building Factorio" -Status "Building image"
    docker build --build-arg FACTORIO_VERSION=$version --tag "cryowatt/factorio:$version" .
    Write-Progress -Activity "Building Factorio" -Status "Pushing image"
    docker push "cryowatt/factorio:$version"
}

# if ($Experimental) {
    $version = $availableVersions.'core-linux_headless64' | ForEach-Object { [version]$_.to } | Sort-Object | Select-Object -Last 1
    docker tag "cryowatt/factorio:$version" "cryowatt/factorio:experimental"
    docker tag "cryowatt/factorio:$version" "cryowatt/factorio:latest"
    docker push "cryowatt/factorio:$version"
    docker push "cryowatt/factorio:latest"
    docker push "cryowatt/factorio:experimental"
# } else {
    $version = [version]($availableVersions.'core-linux_headless64' | Where-Object { $_.stable } | Select-Object -ExpandProperty stable)
    docker tag "cryowatt/factorio:$version" "cryowatt/factorio:stable"
    docker push "cryowatt/factorio:$version"
# }


# $tags = @(
#     ($Experimental ? "experimental" : "stable"),
#     $version.ToString(3),
#     $version.ToString(2)
# )

# $tagArgs = $tags | ForEach-Object { "--tag"; "cryowatt/factorio:$_" }

# docker build --build-arg FACTORIO_VERSION=$version @tagArgs .

# if ($Push) {
#     docker tag cryowatt/factorio:stable cryowatt/factorio
#     docker push cryowatt/factorio
#     $tags | ForEach-Object {
#         docker push cryowatt/factorio:$_
#     }
# }

#Invoke-WebRequest -Method HEAD https://www.factorio.com/get-download/$_/headless/linux64 -ErrorAction SilentlyContinue | Write-Debug

#$version
# $stable = [version]($availableVersions.'core-linux_headless64' | Where-Object { $_.stable } | Select-Object -ExpandProperty stable)
# $allVersions = $availableVersions.'core-linux_headless64' | ForEach-Object { $_.from; $_.to } | Select-Object -Unique | ForEach-Object { [version] $_ }

# $allVersions | ForEach-Object {
#     try
#     {
#         Write-Verbose "Checking for version $_"
#         Invoke-WebRequest -Method HEAD https://www.factorio.com/get-download/$_/headless/linux64 -ErrorAction SilentlyContinue | Write-Debug
#         Write-Progress -Activity "Building image for version $_"
#         #docker build --build-arg FACTORIO_VERSION=$_ --tag cryowatt/factorio:$_ .
#     }
#     catch
#     {
#     }
# }

# #docker tag cryowatt/factorio:$stable cryowatt/factorio:latest

# $latestExperimentalVersion = $allVersions | Sort-Object -Descending | Select-Object -First 1
# #docker tag cryowatt/factorio:$latestExperimentalVersion cryowatt/factorio:experimental

# #todo
# #docker images | ConvertFrom-String -PropertyNames @('Repository','Tag','ImageId') | % { docker push "$($_.Repository)$($_.Tag)"}