param (
    [string]$ResourceGroupName,
    [string]$FunctionName,
    [string]$StorageAccountName,
    [string]$CoreResourceGroupName,    
    [string]$KeyVaultName,
    [string]$AppConfigurationService,
    [string]$InternalEventHubName,        
    [string]$ExternalEventHubName,
    [string]$ExternalEventHubNamespaceResourceGroupName    
)

$functionId = $(az webapp identity show -n $FunctionName -g $ResourceGroupName -o tsv --query principalId)

$storageAccountId = $(az storage account show -n $StorageAccountName -g $ResourceGroupName -o tsv --query id)

az role assignment create --assignee $functionId --role "Storage Blob Data Owner" --scope $storageAccountId | Out-Null

az role assignment create --assignee $functionId --role "Storage Account Contributor" --scope $storageAccountId | Out-Null

az role assignment create --assignee $functionId --role "Storage Queue Data Contributor" --scope $storageAccountId | Out-Null

$keyVaultId = $(az keyvault show -n $KeyVaultName -g $CoreResourceGroupName -o tsv --query id)

az role assignment create --assignee $functionId --role "Key Vault Secrets User" --scope $keyVaultId | Out-Null

$appConfigurationId = $(az appconfig show -n $AppConfigurationService -g $CoreResourceGroupName -o tsv --query id)

az role assignment create --assignee $functionId --role "App Configuration Data Reader" --scope $appConfigurationId | Out-Null

$internalEventHubNamespaceId = $(az eventhubs namespace show -n $InternalEventHubName -g $CoreResourceGroupName -o tsv --query id)

az role assignment create --assignee $functionId --role "Azure Event Hubs Data Receiver" --scope $internalEventHubNamespaceId | Out-Null

$externalEventHubNamespaceId = $(az eventhubs namespace show -n $ExternalEventHubName -g $ExternalEventHubNamespaceResourceGroupName -o tsv --query id)

az role assignment create --assignee $functionId --role "Azure Event Hubs Data Sender" --scope $externalEventHubNamespaceId | Out-Null

Write-Host "Identity Assignment Complete."
