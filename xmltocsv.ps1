<#
.Synopsis
Convert Fujitsu XML to CSV format

.Description
The `Get-IbReport` cmdlet import transaction history from Interactive Brokers using flex query version 3 API.
Interactive Brokers provides two types of statements. The Activity Flex and Trade Confirms Flex.
Activity Flex statement provides daily data with all information at the end of the day (Total equity, open positions, trades, cash transactions etc.)
Trade Confirms Flex provides the trades only but it is refreshed immediately after the trade is confirmed.

.Parameter Query
Flex query ID of Interactive Brokers.

.Parameter Token
Your flex web service token in Interactive Brokers.

.Example
Get-IbReport -Query 123456

.Example
Get-IbReport 123456

.Example
Get-IbReport 123456 | Sort-Object settledate | Select-Object -Last 15 | Format-Table

.LINK
Online version: https://www.interactivebrokers.com/en/software/am/am/reports/flex_web_service_version_3.htm
Project homepage: https://github.com/scout249/Interactive-Brokers-Powershell

#>

#Installation
#Install-Module -Name JoinModule

#Define Variable
$baseDir = "C:\XML2CSV"
$inFile = "in.xml"
$outFile = "out.csv"
$masterFile = "BTO component master database.csv"

#Convert XML to CSV
sl $baseDir
[xml]$xmlin = Get-Content $inFile
$xmlin.Order.Systems.Component.Components.Component | select `
    @{N="Product Name"; E={$_.name}},
    @{N="Part Number"; E={$_.SachNr}},
    @{N="Quantity"; E={$_.Count}},
    @{N="Unit Price"; E={"0"}} | Export-Csv $outFile -NoTypeInformation


#Merge Tables
$importMaster = Import-Csv $masterFile | 
    Select "Part Number", "CP Figure Number"
Import-csv $outFile | 
    InnerJoin $importMaster -On "Part Number" | 
    Select "Product Name", "Part Number", "CP Figure Number", "Quantity", "Unit Price" | 
    Export-Csv temp.txt -NoTypeInformation

#Append to CSV file
ac temp.txt ",,,,Total Price`n,,,,0"

#Remove Double Quote
gc temp.txt | % {$_ -replace '"'}  | Set-Content $outFile







<#

#Unused Code
#Remove Empty Lines
gc temp.txt | ? {$_.trim() -ne "" } | Set-Content $outFile
Export-Csv out.csv -NoTypeInformation
@{Name = "Attributes"; Expression = {$_.Mode}},
@{Name = "Updated_UTC"; Expression = {$_.LastWriteTime.ToUniversalTime()}}
name, SachNr, count
#>