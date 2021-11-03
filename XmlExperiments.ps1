[xml] $xdoc = get-content C:\Users\crbk01\Desktop\Todo.xml

$xdoc.ChildNodes

######

[xml] $xdoc = get-content C:\Users\crbk01\Desktop\Todo.xml

$xdoc.DocumentElement

######

[xml] $xdoc = get-content C:\Users\crbk01\Desktop\Todo.xml

$xdoc.childNodes[2].ChildNodes[1].InnerText

#####


[xml] $xml =get-content C:\Users\crbk01\Desktop\Todo.xml

$xml.CreateNavigator().Evaluate('count(//unit)')
$xml.CreateNavigator().Evaluate('sum(//unit)')

###


[xml] $xml =get-content C:\Users\crbk01\Desktop\Todo.xml

$xml.CreateNavigator().Value


####



[xml] $xml =get-content C:\Users\crbk01\Desktop\Todo.xml

$xml.CreateNavigator().InnerXml


####



[xml] $xml =get-content C:\Users\crbk01\Desktop\Todo.xml


$xml.wordDocument.body.sect

#######

[xml] $xml =get-content C:\Users\crbk01\Desktop\Todo.xml


$xml.wordDocument.body.FirstChild.FirstChild.InnerText

######
[xml] $xml =get-content C:\Users\crbk01\Desktop\Todo.xml

$xml.wordDocument.body.FirstChild.FirstChild.ChildNodes[2].InnerText

######
[xml] $xml =get-content C:\Users\crbk01\Desktop\Todo.xml

$xml.wordDocument.body.FirstChild.ChildNodes | % { $_.localName }

            ##[xml] $inner = $_
            ##[xml] $inner = $_.innerXml | Convert-Xml
            
            ##[System.io.StringWriter] $str = new-object StringWriter
            #$q = New-TemporaryFile
                        
            #$XML_Path = $q #"D:SathishArticleSample.xml"
     
            # Create the XML File Tags
            #$xmlWriter = New-Object System.XMl.XmlTextWriter($XML_Path,$Null)
            #$xmlWriter.Formatting = 'Indented'
            #$xmlWriter.Indentation = 1
            #$XmlWriter.IndentChar = "`t"
            #$xmlWriter.WriteStartDocument()
#            $xmlWriter.WriteStartElement()
#$xmlWriter.WriteEndElement()
            #$xmlWriter.WriteEndDocument()
            #$xmlWriter.Flush()
            #$xmlWriter.Close()
                            
            #[XmlDocument] $doc = New-Object XmlDocument;

            #[System.Text.UTF8Encoding] $X 

            #$xmlWriter = New-Object System.XMl.XmlTextWriter($q.FullName,$X)
            #$xmlWriter = New-Object System.XMl.XmlTextWriter($str)
            #$xmlWriter
                     
            #$xmlWriter.WriteEndDocument()

            #$xmlWriter.WriteComment('Get the Information about the web application')
            #$xmlWriter.WriteStartElement('WebApplication')

######

            
            # Create a new XML File with config root node
            # New Node
            #[System.XML.XMLElement]$oXMLRoot=$oXMLDocument.CreateElement("config")
            # Append as child to an existing node
            
            #$oXMLDocument.appendChild($oXMLRoot)



##Add-Type -Path 'C:\Program Files\dotnet\packs\Microsoft.NETCore.App.Ref\3.1.0\ref\netcoreapp3.1\System.Xml.ReaderWriter.dll'
[System.Reflection.Assembly]::LoadWithPartialName("System.Xml.ReaderWriter.Smo")

function  xml-unNest {

  param (

  [Parameter(Mandatory=$true)][xml]$xml,
  [Parameter(Mandatory=$false)][int]$depth = 0
  )     
  $outPut= ""      
    if ($xml.HasChildNodes) 
    {
        ##"has childnodes"
        ForEach ($XmlNode in $xml.DocumentElement.ChildNodes) 
        {
            [System.XML.XMLDocument]$oXMLDocument=New-Object System.XML.XMLDocument


            $z = $oXMLDocument.ImportNode($XmlNode, $true)
            
            if($null -ne $z )
            {
                if($null -ne $oXMLDocument)
                {
                    try {
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
        }
      }
      else {
      ##"no childnodes"

        ## Send the non-group object out
       $outPut = $xml.Value
      
      }     
       ##$xml.LocalName

       ##return 
       [pscustomobject]@{
       Name = if($xml.localName -ne $null -and $xml.localName -ne "                                                        "){$xml.localName}else{"["+$counter+"]"}
       FromGroup = if($xml.ParentNode -ne $null -and $xml.ParentNode -ne "                                                        "){$xml.ParentNode}else{"["+$counter-1+"]"}
       Value = $outPut
       depth = $counter
       children = $xml.HasChildNodes
       }  
}

  xml-unNest ( get-content C:\Users\crbk01\Desktop\Todo.xml ) #| format

