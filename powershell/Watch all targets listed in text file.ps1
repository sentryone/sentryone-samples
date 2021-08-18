<#Change this to match the name of the server housing the SentryOne database and the name of the SentryOne database #>
Connect-SQLSentry -ServerName servername -DatabaseName SentryOne

<#Change this to match the name of the text file that includes all the names of all the servers you want to watch #>
$Servers = Get-Content "C:\Powershell\TestWatch.txt"

Foreach ($Server in $Servers)
{
    Register-Connection -ConnectionType SqlServer -Name $Server
    Get-Connection -Name $Server -NamedServerConnectionType SqlServer| Invoke-WatchConnection
}
