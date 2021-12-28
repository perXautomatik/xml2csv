function x {

param([string]$fin = "",[string]$fout)

    if ($fin -ne ""){
      [xml]$xmlContent = get-content $fin -ErrorAction Stop
    }
    else {
      $lines=$input
    }
    $xmlContent.Attributes


}



function expObjProperties($o)
{
return $o.PSObject.Properties | ForEach-Object { if(($_.Value) -and $_.value.getType().toString() -ne $_.value.toString()){[pscustomobject]@{name=$_.Name;type=$_.value.GetType();value=$_.value}}}

}

# datagrip recent projects name and path

 $temp =  [xml]$xmlContent = get-content 'D:\Users\crbk01\AppData\Roaming\JetBrains\DataGrip2021.1\options\recentProjects.xml' -Encoding UTF8


$result1 = $temp.application.firstChild.ChildNodes[0].map.ChildNodes | % {[pscustomobject]@{
path = $_.key
name = $_.FirstChild.FirstChild.frameTitle }}


#$result1 | % { $_.path}

$temp =  [xml]$xmlContent = get-content 'D:\Users\crbk01\AppData\Roaming\JetBrains\DataGrip2021.1\projects\default\.idea\workspace.xml' 
$projectId = $temp.LastChild.FirstChild.NextSibling.NextSibling.NextSibling.NextSibling.id


$temp =  [xml]$xmlContent = get-content 'D:\Users\crbk01\AppData\Roaming\JetBrains\DataGrip2021.1\projects\Kv-FlaggGenerering\.idea\dataSources.local.xml'
$dbPatterns = $temp.LastChild.FirstChild.ChildNodes | %{ [pscustomobject]@{ name = $_.name; uuid = $_.uuid; pattern = $_.'table-pattern'}}


#compare 

$folder = 'D:\Users\crbk01\AppData\Roaming\JetBrains\DataGrip2021.1\projects\';$ds = '\.idea\dataSources.xml'

$b = 'Kv-Utsökning'
$a = 'default'
$childa = ([xml]$xmlContent = get-content ($folder+$a+$ds) -Encoding UTF8).LastChild.FirstChild.ChildNodes
$childb = ([xml]$xmlContent = get-content ($folder+$b+$ds) -Encoding UTF8).LastChild.FirstChild.ChildNodes

$Data1 = @([PSCustomObject][Ordered]@{Name='';uuid=''});$childa | %{$Data1 = $Data1 +[pscustomobject]@{source = $b;name=$_.name; uuid =$_.uuid; remarks = $_.remarks; url = $_.'jdbc-url' }}
$Data2 = @([PSCustomObject][Ordered]@{Name='';uuid=''});$childb | %{$Data2 = $Data2 +[pscustomobject]@{source = $a;name=$_.name; uuid =$_.uuid; remarks = $_.remarks; url = $_.'jdbc-url' }}

#(Compare-Object -ReferenceObject $Data1 -DifferenceObject $Data2 -Property uuid,name -PassThru) | Sort-Object -Property uuid,sideIndicator | Select-Object -Property uuid,source,name

$childb|?{$_.uuid -eq '2ca40bb3-aca4-412d-a610-84b4e5da6dbe'} | select -property name 

$childa | 
   ? { $_.uuid -eq '2ca40bb3-aca4-412d-a610-84b4e5da6dbe' } 
  # | % { $_.name = }



