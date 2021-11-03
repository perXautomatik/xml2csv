function  xml-unNest {

  param (

  [Parameter(Mandatory=$true)][xml]$xml,
  [Parameter(Mandatory=$false)][int]$depth = 0
  )     
  $outPut= ""      
    if ($xml.HasChildNodes -and $xml.ChildNodes.Count -ne 1) 
    {
        ##"has childnodes"
        ForEach ($XmlNode in $xml.ChildNodes) 
        {
            [System.XML.XMLDocument]$oXMLDocument=New-Object System.XML.XMLDocument


            $z = $oXMLDocument.ImportNode($XmlNode, $true)
            
            if($null -ne $z )
            {
            
                if($null -ne $oXMLDocument)
                {
                    try {
                            
                        #Write-Progress "Step $i - Substep $j - iteration $k"
                        $newDepth = (1+$dept)
                        #$newDepth
                        if($oXMLDocument.DocumentElement -ne $null)
                        {
                            $null =  $oXMLDocument.DocumentElement.AppendChild($z)                     
                               
                            xml-unNest -xml $oXMLDocument -depth $newDepth
                        }
                        else {
                            $null =  $oXMLDocument.AppendChild($z)
                            xml-unNest -xml $oXMLDocument -depth $newDepth
                        }                    
                        }
                    catch {
                            $outPut = 'Caught Error'
                        }
                }
                else
                {
                    $outPut = "Temp oxmlDocumentIsnull"
                }
            }
            else 
            {
                $outPut = "z is null"
            }           

            [pscustomobject]@{
                Name = if($XmlNode.localName -ne $null -and $XmlNode.localName -ne ""){$XmlNode.localName}else{$counter}
                FromGroup = if($XmlNode.ParentNode -ne $null -and $XmlNode.ParentNode -ne ""){$XmlNode.ParentNode}else{$counter}
                Value = $outPut
                depth = $counter
                children = $XmlNode.HasChildNodes
                childrenCount = $XmlNode.ChildNodes.Count
                length = $XmlNode.InnerXml.Length
                xml = $XmlNode.InnerXml.Substring(0, [Math]::Min($XmlNode.InnerXml.Length, 40))
            }
        }  

    }
    else {
    ##"no childnodes"

    ## Send the non-group object out
    $outPut = $xml.Value
      
    }     
    ##$xml.LocalName

    [pscustomobject]@{
    Name = if($xml.localName -ne $null -and $xml.localName -ne ""){$xml.localName}else{$counter}
    FromGroup = if($xml.ParentNode -ne $null -and $xml.ParentNode -ne ""){$xml.ParentNode}else{$counter}
    Value = $outPut
    depth = $counter
    children = $xml.HasChildNodes
    childrenCount = $xml.ChildNodes.Count
    length = $xml.InnerXml.Length
    xml = $xml.InnerXml.Substring(0, [Math]::Min($xml.InnerXml.Length, 40))
    }  
}

  xml-unNest ( get-content C:\Users\crbk01\Desktop\Todo.xml ) #| format


  ####

  
  Clear-Host
  function  xml-unNest {

  param (

  [Parameter(Mandatory=$true)][xml]$xml,
  [Parameter(Mandatory=$false)][int]$depth = 0
  )     
    $counter = 0

    ##"has childnodes"
    ForEach ($XmlNode in $xml.ChildNodes) 
    {   
        $counter= $counter+1     
        
        #$q = $XmlNode | ConvertTo-Xml
        

        $LocalName = $XmlNode.localName;
        $Value = $XmlNode.Value        
        $Type = $XmlNode.getType()
        
                    
        if($XmlNode.ChildNodes.count -ge 1 )
        {
            $a = $xmlNode.innerXml
            
            if($a -is [system.object])
            {
                $d = (""+$XmlNode).Substring(0, [Math]::Min((""+$XmlNode).Length, 80))
                $dd = (""+$XmlNode).Length
                $b = ($a | ConvertTo-Xml)
                $c = $b.InnerXml
                $aa = (""+$a).Substring(0, [Math]::Min((""+$a).Length, 80))
                $aaa =  (""+$a).Length
                $bb = (""+$b).Substring(0, [Math]::Min((""+$b).Length, 80))
                $bbb = (""+$b).Length
                $cc = (""+$c).Substring(0, [Math]::Min((""+$c).Length, 80))
                $ccc  = (""+$c).Length
                $o = $a.keys.length
          

                 [pscustomobject]@{

                    counter = $counter
                    LocalName = $LocalName
                    Value = $value
                    Type = $type
                    Depth = $depth
                    a = $aa
                    aa = $aaa
                    b = $bb
                    bb = $bbb
                    c = $cc
                    cc = $ccc
                    d = $d
                    dd = $dd
                    o = $o
                    
                    }
         
                                                         
                if($ccc -ge 1 -and $depth -le 10)
                {
                    xml-unNest -xml $c -depth (1+$depth)
                }
            
            }
            else
            {
                xml-unNest -xml $a -depth (1+$depth)
            }
            
        }


    }
}

  xml-unNest ( get-content C:\Users\crbk01\Desktop\Todo.xml ) #| format


  
  ####

  
  Clear-Host
  function  xml-unNest {

  param (

  [Parameter(Mandatory=$true)]$xml,
  [Parameter(Mandatory=$false)][int]$depth = 0
  )     
    $counter = 0

    $LocalName = $xml.localName;
    $Value = $xml.Value        
    $Type = $xml.getType()        
    $aa = $Xml.ChildNodes.count 
     
    $localName
    $value
    $type
    $aa
    $counter
        
    
    ##"has childnodes"
    ForEach ($XmlNode in $xml.ChildNodes) 
    {   
        $counter= $counter+1     
        
        #$q = $XmlNode | ConvertTo-Xml
        
        $a = $xmlNodes.innerXml
        $LocalName = $XmlNode.localName;
        $Value = $XmlNode.Value        
        $Type = $XmlNode.getType()        
        $aa = $XmlNode.ChildNodes.count 
        
        $localName
        $value
        $type
        $aa
                           

        if($aa -ge 1 -and $depth -le 10 )
        {                                             
                xml-unNest -xml $a -depth (1+$depth)            
        }       
    }
}

  xml-unNest ( get-content C:\Users\crbk01\Desktop\Todo.xml ) #| format


