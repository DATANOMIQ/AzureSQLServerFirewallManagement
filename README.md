# AzureSQLServerFirewallManagement

During the development of Azure Sql Databases client like Azure Data Studio and SQL Server Management Studio create firewall rules at the logical Azure SQL Server. These represent non static IPs of local clients. These rules are normally named like `ClientAddress_*`. This might be a potential security issue, if these rules are not removed after finishing the development session.

This respository contains a powershell script and an example terraform file to setup a daily scheduled Azure Automation job to remove all auto created firewall rules.

## Prerequisites

- Have Powershell installed
- Azure CLI installed
- Azure Module installed in Powershell `Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force`
- Be a Contributor at Subscription Level in the Azure Subscription

## How To Use

Add the terraform resources to your terraform project or add an resource group to the terraform file and run terraform to setup the Automation host.

Additionally it is possible to just run the script. If you run the script locally, make sure that you are logged in to the correct Azure Account and have set the Subscription to manipulate. You and do this using Azure CLI.

```Powershell
chmod +x removeAllFirewallRules.ps1

./removeAllFirewallRules.ps1
```

## How To Contribute

If you have found a bug, or have questions, feel free to create an issue.

If you like to contribute code, feel free to fork the repo and create a pull request.

## Warranty

As stated in the GPL License, no warranty for anything. You use the script at your own risk!