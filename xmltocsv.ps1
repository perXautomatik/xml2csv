<#
.Synopsis
Convert Fujitsu XML to CSV format

.Description
The `ConvertTo-FujitsuCsv` cmdlet import transaction Fujitsu XML into a series of character-separated value (CSV) strings.

.Parameter InputObject
Specifies the objects that are converted to CSV strings. Enter a variable that contains the objects or type a command or expression that gets the objects.

.Parameter OutputObject
Specifies the output filename of CSV.

.Example
ConvertTo-FujitsuCsv -InputObject input.xml -OutputObject out.csv

.LINK
Project homepage: https://github.com/scout249/fujitsu-xml2csv

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
