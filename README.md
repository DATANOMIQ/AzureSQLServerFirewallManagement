# AzureSQLServerFirewallManagement

## tl;dr
Use the powershell script included in the repository to remove all Firewall Rules, that are automatically created by SQL clients life SQL Server Management Studio or Azure Data Studio. The included Terraform template helps you to create a Azure Automation Job based on the PowerShell script

---
Azure SQL Database Security is based on various measures, one of them are Firewall rules. You only whant to allow clients connect from certain IPs. These are you internal VNet IPs and also - for a better development experience - the clients of your developers. Using DHCP and remote work, these IPs change frequently. Using Tools like SSMS or Azure Data Studio, it is easy to add new firewall rules. But they don't remove these rules after use and People are lazy. These rules, based on dynamic IPs might be an unecessary vulnerability, as the next day other clients might have these IPs. A Solution would be to automatically remove all these auto created rules regularly.

But there is no out of the box solution, Mircosoft? Your chance?

In the meantime add the included Terraform code to create an Azure Automation job, scheduled for every midnight, using the `remodeAllFirewallRules.ps1` PowerShell script.

### Steps the scrip takes

The afore mentioned tools create firewall rules at the logical Azure SQL Server, named like `ClientAddress_*`. 

The scope the script job runs in is the Azure Subscription. Hence the Automation Service needs to be Contributer on Subscription level.

The script is simple, it uses PowerShell AZ module - it is preinstalled in the Azures Cloud Shell, and can be added to your local shell.

```PowerShell
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force

Import-Module Az
```

First step is to get the SQL Servers and their Resource Group available in the current subscription.

Next, for every SQL Server, all FirewallRules are listed, that obey to the Format `ClientAddress_*`. These rules are then deleted.

## Prerequisites

- Have Powershell installed
- Azure CLI installed
- Azure Module installed in Powershell `Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force`
- Be a Contributor at Subscription Level in the Azure Subscription

## How To Use

Add the terraform resources to your terraform project or add an resource group to the terraform file and run terraform to setup the Automation host.

Additionally it is possible to just run the script. If you run the script locally, make sure that you are logged in to the correct Azure Account and have set the Subscription to manipulate. You and do this using Azure CLI.

```Powsershell
az account set -s "your-subs-crip-tion-id"
```

```Powershell
chmod +x removeAllFirewallRules.ps1

./removeAllFirewallRules.ps1
```

## How To Contribute

If you have found a bug, or have questions, feel free to create an issue.

If you like to contribute code, feel free to fork the repo and create a pull request.

## Warranty

As stated in the GPL License, no warranty for anything. You use the script at your own risk!