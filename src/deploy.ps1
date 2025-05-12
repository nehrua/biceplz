
Connect-AzAccount -Environment AzureCloud

New-AzSubscriptionDeployment -Location eastus -TemplateFile .\src\lz.bicep -verbose