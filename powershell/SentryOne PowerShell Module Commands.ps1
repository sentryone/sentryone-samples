<# Collection of PoSh Command Examples #>
<# See https://docs.sentryone.com/help/powershell-module #>

<# Import the SentryOne PowerShell Module - Version and location may vary from 2020.0 #>
Import-Module "C:\Program Files\SentryOne\2020.0\Intercerve.SQLSentry.Powershell.psd1"

<# Connect to a specific SentryOne Installation #>
Connect-SQLSentry -ServerName server.domain.com -DatabaseName SentryOne

<# Get Information about your SentryOne Installation #>
Get-SQLSentryConfiguration

<# Get Information about the Sites in your SentryOne Installation -use parameters to find information for a specific site #>
Get-Site

<# Get Information about the Connections (Instances) in your SentryOne Installation -use parameters to find information for a specific connection #>
Get-Connection

<# Get Information about the Computers (Targets) in your SentryOne Installation -use parameters to find information for a specific connection #>
Get-Computer

<# Get Information about the Connections in your SentryOne Installation -use parameters to find information for a specific connection #>
Get-Connection

<# Register Computers (Targets), so that they can be watched in your environment #>
Register-Computer -ComputerType Windows -Name server.domain.com -AccessLevel Full Register-Computer -ComputerType Windows - Name server.domain.com -AccessLevel Limited

<# Register a Target that cannot utilize Windows Authentication (e.g., Azure SQL Database) #>
Register-Computer -ComputerType AzureSqlDatabase -Name example.database.windows.net -DatabaseName dbName -Login username -Password password -AccessLevel Full -UseIntegratedSecurity 0

<# Register Connections (Instances), so that they can be watched in your environment #>
Register-Connection -ConnectionType SqlServerAnalysisServices -Name server.domain.com Register-Connection -ConnectionType SqlServer -Name server.domain.com

<# Watch Windows Computer (Target) with Performance Analysis and Event Calendar | -Pipe in the Computer #>
Get-Computer -Name server.domain.com -NamedServerComputerType Windows | Invoke-WatchComputer

<# Watch Hyper-V Host (Target) with Performance Analysis and Event Calendar (core-based licensing) | -Pipe in the Computer #>
Get-Computer -Name server.domain.com -NamedServerComputerType Windows | Invoke-WatchComputer -LicenseMode CoreBased

<# Watch SQLServer Connection (Instance) with Performance Analysis and Event Calendar | -Pipe in the Connection #>
Get-Connection -Name server.domain.com -NamedServerConnectionType SqlServer | Invoke-WatchConnection

<# Watch SSAS Connection (Instance) with Performance Analysis and Event Calendar | -Pipe in the Connection #>
Get-Connection -Name server.domain.com -NamedServerConnectionType SqlServerAnalysisServices | Invoke-WatchConnection

<# Unwatch Windows computer (Target) #>
Get-Computer -Name server.domain.com -NamedServerComputerType Windows | Invoke-UnwatchComputer

<# Unwatch SSAS connection #>
Get-Connection -Name server.domain.com -NamedServerConnectionType SqlServerAnalysisServices | Invoke-UnwatchConnection

<# Unwatch SQLServer connection #>
Get-Connection -Name server.domain.com -NamedServerConnectionType SqlServer| Invoke-UnwatchConnection

<# User cmdlets #>
 Register-User -FirstName Test -LastName user -Email tuser@test.net -PagerAddress tuser@testPager.net -Description Tester -Login domain\username Get-User -FirstName Test Get-User -Name "Test User" Disable-User -Name "Test User" Enable-User -Name "Test User" Unregister-User -Name "Test User"

<# Group cmdlets #>
Register-Group -Name "Test Group" -Description "A Group" -Login Domain\TestGroup Get-Group -Name "Test Group" Disable-Group -Name "Test Group" Enable-Group -Name "Test Group" Unregister-Group -Name "Test Group"

<# User = and - to the Group cmdlets #>
Get-User -Name "Test User" | Add-GroupUser -GroupName "Test Group" Get-User -Name "Test User" | Remove-GroupUser -GroupName "Test Group"
