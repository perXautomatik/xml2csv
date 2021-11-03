
Clear-Host
##Add-Type -Path 'C:\Program Files\dotnet\packs\Microsoft.NETCore.App.Ref\3.1.0\ref\netcoreapp3.1\System.Xml.ReaderWriter.dll'
[System.Reflection.Assembly]::LoadWithPartialName("System.Xml.ReaderWriter.Smo")


function xml-pack {

  param (

  [Parameter(Mandatory=$true)] $xml,
  [Parameter(Mandatory=$false)][int]$depth = 0,
  [Parameter(Mandatory=$false)][int]$counter = 0
  )     
                                                      $Name = "empty"
                                                      $value = "empty"
                                                      $complexity = 0
                                                      $length = 0
                                                      $type = "empty"
                                                      $parent = "unknown"
                                                      $debugg = ""
                                                      $inputLength = 0 
                                                      $inputLength = (""+$xml).Length        

    if ($xml  -is [System.Object])
                {
                    $complexity = $xml.ChildNodes.Count
                    $debugg = $debugg + "System.Object"

                    try{
                        $xml = $xml | ConvertTo-Xml
                        $debugg = $debugg + $xml.GetType()
                    }
                    catch{$debugg = "error"}

                }
  
  if($xml  -is  [System.Xml.XmlElement])
                  {
                    [System.XML.XMLDocument]$oXMLDocument=New-Object System.XML.XMLDocument
                    $z = $oXMLDocument.ImportNode($Xml, $true)
                    $null =  $oXMLDocument.DocumentElement.AppendChild($z)      
                    $xml = $z
                    $debugg = "xmlElement"
                   }
   
  if ($xml  -is  [System.Xml.XmlDocument])
                   {

                    $Name = if($xml.localName -ne $null -and $xml.localName -ne ""){$xml.localName}else{$counter}
                    
                    $complexity = $xml.ChildNodes.Count

                    $Value = if($complexity -ge 2){$xml.InnerXml}else{$xml.value}
                    
                    $length = $xml.InnerXml.Length        
                    $type = $Xml.GetType()
                    $debugg = $debugg + "xmlDocument"
                    }
   
    else
    {
        $length = (""+$xml).length
        $value = (""+$xml).Substring(0, [Math]::Min($length, 40))
        $type = $xml.GetType()
        $debugg = $debugg + ($xml  -is [System.Object] )
    }
    
    return [pscustomobject]@{
        Name = $Name
        value = $value
        complexity = $complexity
        length = $length
        type = $type
        parent = $parent
        debugg = $debugg
        depth = $depth
    }
}


function  xml-unNest {

  param (

  [Parameter(Mandatory=$true)][xml]$xml,
  [Parameter(Mandatory=$false)][int]$depth = 0
  )     
    $counter = 0
    ##"has childnodes"
    ForEach ($XmlNode in $xml) 
    {   
        $counter= $counter+1     
        $q = xml-pack $XmlNode,$depth,$counter 
        
        if($q.complexity -cge 1 -and $depth -le 3)
        {
            xml-unNest -xml $q.value -depth (1+$depth)
        }
        $q

    }
}

  xml-unNest ( get-content C:\Users\crbk01\Desktop\Todo.xml ) #| format

####
  [xml]$q = get-content C:\Users\crbk01\Desktop\Todo.xml ;$t = $q.DocumentElement.body.sect | ConvertTo-Xml ; $t.ChildNodes

  [xml]$q = get-content C:\Users\crbk01\Desktop\Todo.xml ;$q.ChildNodes.body.sect.ChildNodes
  
  [xml]$q = get-content C:\Users\crbk01\Desktop\Todo.xml ;$q.DocumentElement

  [xml]$q = get-content C:\Users\crbk01\Desktop\Todo.xml ;$q.ChildNodes.body.sect.getType()localName.FirstChild.FirstChild.FirstChild.FirstChild

#####
Clear-Host
function  xml-unNest {

  param (

  [Parameter(Mandatory=$true)]$xml,
  [Parameter(Mandatory=$false)][int]$depth = 0
  )     
    $counter = 0
    ##"has childnodes"
    "outerDp:" + $depth
    #$xml.Attributes
    "outerPN:" + $xml.ParentNode
    "outerLN:" + $xml.LocalName
    "outerNT:" + $xml.NodeType
    

    if($depth -eq 0){
    try{
        [xml]$q = $xml
        $xml = $q
    } catch{}}
    else
    {
        [System.Xml.XmlLinkedNode]$q = $xml
        $xml = $q
    }    

    if($xml.ChildNodes)
    {
        ForEach ($XmlNode in $q.ChildNodes) 
        {
               $counter = $counter+1   
            if($XmlNode.nodeType -eq "Text"){
             #   $XmlNode.Attributes
                "innerNRr:" + $counter
                "innerLN:" + $XmlNode.LocalName
                "innerNT:" + $XmlNode.nodeType
                "innerLT:" + $XmlNode.InnerText
            }
            if($XmlNode.ChildNodes -and $XmlNode.childnodes -ne "")
            {                    
                "innerCN:" + $XmlNode.childnodes
                    xml-unNest -xml $XmlNode -depth (1+$depth)
                
            }

        }
    }

}
xml-unNest ( get-content C:\Users\crbk01\Desktop\Todo.xml )


##

[xml]$q = get-content C:\Users\crbk01\Desktop\Todo.xml ;

$a = $q.ChildNodes
"a:" + $a.Count
$b = $a.lastChild
"b:" + $b.Count
$c = $b.FirstChild
"c:" + $c.Count
$d = $c.FirstChild
"d:" + $d.Count
$e = $d.FirstChild
"e:" + $e.Count




.body.sect.FirstChild.FirstChild.FirstChild.FirstChild.FirstChild