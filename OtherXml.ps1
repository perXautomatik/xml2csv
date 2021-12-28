
function expObjProperties($o)
{
return $o.PSObject.Properties | ForEach-Object { if(($_.Value) -and $_.value.getType().toString() -ne $_.value.toString()){[pscustomobject]@{name=$_.Name;type=$_.value.GetType();value=$_.value}}}

}


function x {

param([string]$fin = "",[string]$fout)

    if ($fin -ne ""){
      [xml]$xmlContent = get-content $fin -ErrorAction Stop
    }
    else {
      $lines=$input
    }
   

  #expObjProperties()
   $xmlContent.lastChild.component.childnodes[0].innerXml


}

x -fin 'C:\Users\crbk01\AppData\Roaming\JetBrains\DataGrip2021.1\projects\default\.idea\dataSources.local.xml'