[cmdletbinding()]
param(
    $ResourceGroupName = "GameServer",
    $StorageAccountName = "gameserverfiles",
    $LogWorkspaceName = "GameServerLogs",
    [version]$FactorioVersion = "0.18"
)

$DeployParameters = @{
    saves_storage_account_name = $StorageAccountName
    saves_storage_account_key = [string] (Get-AzStorageAccountKey -Name $StorageAccountName -ResourceGroupName $ResourceGroupName | Select-Object -First 1 -ExpandProperty Value)
    log_analytics_workspace_id = [string] (Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $LogWorkspaceName | Select-Object -ExpandProperty CustomerId)
    log_analytics_workspace_key = [string] (Get-AzOperationalInsightsWorkspaceSharedKeys -ResourceGroupName $ResourceGroupName -Name $LogWorkspaceName | Select-Object -ExpandProperty PrimarySharedKey)
    factorio_version = [string] (./Get-LatestVersion.ps1 -FactorioVersion $FactorioVersion)
}

New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateParameterObject $DeployParameters -TemplateFile .\deploy\template.json -Name Hahntorio