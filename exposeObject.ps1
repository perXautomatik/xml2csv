#parselist = orderedSet of [ref]xmlElement

#appen each protperty to parselist

#while i < length of parselist
 #   set ObjectTOParse = parselist[i++]
  #  append propertie to output
   #     if of type xmlElement append to parselist

function expObjProperties($o)
{
return $o.PSObject.Properties | ForEach-Object { if(($_.Value) -and $_.value.getType().toString() -ne $_.value.toString()){[pscustomobject]@{name=$_.Name;type=$_.value.GetType();value=$_.value}}}

}

function popNappend([ref]$itemCount,$startPos,[ref]$queue)
{
    $ty = $queue.Value
    
    $range = $startPos..$itemCount.value
    
    if($ty[$range].count -ne 0)
    {
        $t = $ty[$range]
        "r"+$ty[$range].count
    }
    else
    {
        $t = $ty
    }
      
    $q=$t.GetEnumerator() | %{expObjProperties -o $_.key} 

    #$q

    $q | %{         

    if( $_.value -is [System.Xml.XmlElement]  )
    {
        $a = $_.value
        try{
        $queue.value.insert( $itemCount.value,$a,$a.ParentNode)
        $itemCount.value++
        }catch{
        # $itemCount,$a.getType() 
         }
        }
    }
}
$queue = [Ordered]@{}

$itemCount = 0;

[xml]$documents = Get-Content "C:\Users\crbk01\Desktop\Todo.xml"


expObjProperties -o $documents | %{         

if( $_.value -is [System.Xml.XmlElement]  )
{
    try{
    $z = $_.value

    $queue.insert( $itemCount,$z,$documents)
    $itemCount++
    }catch{
     #$itemCount,$z.getType()
     }
    }
}
$pastBatch = 0
$totalCount = $itemCount
  
for ($i=0;$i-le 10;$i++)
{
    "" + $i  + " p" + $pastBatch + " t" + $queue.Count + " " + $pastBatch/$totalCount
    
    popNappend -itemCount([ref]$itemCount) -queue([ref]$queue) -startPos($pastbatch)
    "q:" + $queue.Count
    "i" +$itemcount
    $pastBatch = $totalCount
    $totalCount = $queue.Count

}





