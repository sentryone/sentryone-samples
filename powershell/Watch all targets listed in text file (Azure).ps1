<#Specify the server housing the SentryOne database and the name of the SentryOne database #>
Connect-SQLSentry -ServerName sqlserver -DatabaseName SentryOne

<#Change this to match the Site into which you are adding the targets #>
$Site= Get-Site -Name DefaultSite

<#Change this to match the name of the text file that includes all the names of the Azure SQL Database targets you want to watch #>
$Servers = Get-Content C:\Powershell\TestWatch.txt

<#Change this to match the name of the text file that includes all the names of Azure SQL Database databases #> 
$DatabaseName = Get-Content C:\Powershell\Databases.txt

<#Username: change this to match the name of the Azure SQL Database login #>
$user= "login"

<#Password: change this to match the name of the Azure SQL Database password #>
$pass= "pass"

Foreach ($Server in $Servers)
{
Register-Computer -ComputerType AzureSqlDatabase -Name $Servers -DatabaseName $DatabaseName -Login $user -Password $pass -AccessLevel Full -UseIntegratedSecurity 0 -TargetSite $Site| Invoke-WatchComputer
}
