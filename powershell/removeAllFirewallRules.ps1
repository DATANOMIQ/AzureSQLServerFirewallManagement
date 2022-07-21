<#
  .DESCRIPTION
    Loops through all logical SQL Servers and remove all autocreated firewall rules.

  .NOTES
    Autor: Otrek Wilke

#>

"Please enable appropriate RBAC permissions to the system identity of this automation account. Otherwise, the runbook may fail..."

try
{
    "Logging in to Azure..."
    Connect-AzAccount -Identity
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

# Get all SQL Server
$servers = Get-AzResourceGroup | Get-AzSqlServer

foreach ($server in $servers) {
    # Get all rules for the SQL Server
    $rules = Get-AzSqlServerFirewallRule -ResourceGroupName $server.ResourceGroupName -ServerName $server.ServerName -FirewallRuleName "ClientIPAddress*"
    foreach ($rule in $rules) {
      Remove-AzSqlServerFirewallRule -FirewallRuleName $rule.FirewallRuleName -ResourceGroupName $rule.ResourceGroupName -ServerName $rule.ServerName -Force  
    }
}

