# ============================================================================= 
#  
# NAME:xml2csv.ps1
#  
# AUTHOR: 
# THANKS TO: Rick Sheeley (original snippet on STack Overflow) 
# DATE  : 
#  Url: https://stackoverflow.com/questions/43393961/powershell-convert-xml-to-csv
# COMMENT:  
# Send large XML with multiple children and Attributes to CSv for analysis
#
# Note: For versions 3.0 or newer only
# ============================================================================= 
<#  
.SYNOPSIS  
    This script converts xml to csv.
.DESCRIPTION  
    Script takes XML and and all subtags under given tag put in one line.
    It adds dummy pair to empty tags: <tag /> = <tag >,,</> 
.NOTES  
    File Name      : xml2csv.ps1  
    Author         : Jiri Kindl; kindl_jiri@yahoo.com
    Prerequisite   : PowerShell V2 over Vista and upper.
    Version        : 20171004
    Copyright 2017 - Jiri Kindl
.LINK  
    
.EXAMPLE  
    .\xml2csv.ps1 -tag event_message -inputfile inputfile.xml"
#>

#pars parametrs with param
#foreach ($file in (Get-ChildItem .\EventLogs)) {.\xml2csv.ps1 -tag "event_message" -inputfile $file.fullname >> .\Events.csv}
param([string]$inputfile = "",[string]$tag = "",[string]$separator = ",")

Function usage {
  "Script takes XML and all subtags/ tags nested under given tag put in one line. rest is ingonred"
  "It adds dummy pair to empty tags: <tag /> = <tag >,,</>" 
  "xml2csv.ps1 -tag tag -inputfile inputfile.xml"
  "-inputfile - XML file"
  "-tag - parrent tag, all tag nested under this tag will be put in one line"
  "Examples:"
  "---------"
  "xml2csv.ps1 -tag event_message -inputfile events.xml"
  "type file.xml | xml2csv.ps1 -tag event_messaga"
  exit
}

$status = "out_tag"

if ($tag -eq "") {
  "You must enter -tag parameter"
  ""
  usage
}

 
  try {
    if ($inputfile -ne ""){
      $lines=get-content $inputfile -ErrorAction Stop
    }
    else {
      $lines=$input
    }
    Foreach ($line in $lines) {
      if (($line -Match "<$tag>") -or ($line -Match "<$tag .*>")){
        $message = ""
        $status = "in_tag"
      }
      elseif ($line -Match "</$tag>") {
        $tmp = $message -replace ">\s*<", ">$separator<"
        $tmp = $tmp -replace "><", ">,<"
        $tmp = $tmp -replace "^\s*", ""
        $message = $tmp -replace "/>",">$separator$separator</>"
        $message
        $status = "out_tag"
      }
      elseif ($status -eq "in_tag") {
        $message = $message + $line
      }
    }
  }
    catch [System.Management.Automation.ItemNotFoundException] {
    "No such file"
    ""
    usage
  }
  catch {
    $Error[0]
  }

function Get-Attributes([Object]$pnode)
{

    if($pnode.HasAttributes) {
        foreach($attr in $pnode.Attributes)
         {
         $xattString+= $attr.Name + ":" + $attr."#text" + ","}
    }
    else {
        $xattString = $pnode.nNode + ": No Attributes,"}

    return $xattString
}

function Get-XmlNode([ xml ]$XmlDocument, [string]$NodePath, [string]$NamespaceURI = "", [string]$NodeSeparatorCharacter = '.')
{
    # If a Namespace URI was not given, use the Xml document's default namespace.
    if ([string]::IsNullOrEmpty($NamespaceURI)) { $NamespaceURI = $XmlDocument.DocumentElement.NamespaceURI }   

    # In order for SelectSingleNode() to actually work, we need to use the fully qualified node path along with an Xml Namespace Manager, so set them up.
    $xmlNsManager = New-Object System.Xml.XmlNamespaceManager($XmlDocument.NameTable)
    $xmlNsManager.AddNamespace("ns", $NamespaceURI)
    $fullyQualifiedNodePath = "/ns:$($NodePath.Replace($($NodeSeparatorCharacter), '/ns:'))"

    # Try and get the node, then return it. Returns $null if the node was not found.
    $node = $XmlDocument.SelectSingleNode($fullyQualifiedNodePath, $xmlNsManager)
    return $node
}

function AppendToXmlArray([ref]$xmlArray,[ref]$row,[string]$inputAttribute,[string]$inputType )
{
    $node = $xmlArray.value
    $node += @([pscustomobject]@{Row= $row.value;Parent=$pNode;Node=$nNode;Attribute='';ItemType='Root';Value=''})
    
    $node[$row.value].Row = $row.value
    $node[$row.value].Parent = $pNode
    $node[$row.value].Node = $nNode
    $node[$row.value].Attribute = $inputAttribute
    $node[$row.value].ItemType = $inputType
    $node[$row.value].Value = $attr."#text"
    $row.value = 1+$row.value
    $xmlArray.value =$node
} 

function AddNodeAndSubNodes ([ref]$xmlArray,[ref]$row,$node )
{
    AppendToXmlArray -xmlArray($xmlArray) -row($row) -inputAttribute "" -inputType "Root"

    if($node.HasAttributes) {
        foreach($attr in $node.Attributes) {
                AppendToXmlArray -xmlArray($xmlArray) -row($row) -inputAttribute $attr.LocalName -inputType "Attribute"
        }
    }

}

    cls
    $fin = "C:\Users\crbk01\Desktop\Todo.xml"
    $fout = "C:\Users\crbk01\Desktop\Todo.csv"

    Remove-Item $fout -ErrorAction SilentlyContinue

    [xml]$xmlContent = get-content $fin
    $row=0
    $COMMA=","
    $pNode = "ROOT"
    $xmlArray = @([pscustomobject]@{Row= $row;Parent=$pNode;Node=$nNode;Attribute='';ItemType='Root';Value=''})
    
    # Replace all "wordDocument" with your top node..
    $nNode = "wordDocument" #foreach($attr in $xmlContent) {$attr}
    $rootNode = $xmlContent.wordDocument
    
    
    AddNodeAndSubNodes -xmlArray([ref]$xmlArray) -row([ref]$row) -q $rootNode

    try {          # Begin TRY
        foreach($node in $rootNode.ChildNodes) {

            $pNode = $rootNode.localName;$nNode = $node.LocalName

            AddNodeAndSubNodes -xmlArray([ref]$xmlArray) -row([ref]$row) -q $nNode

            foreach($sNode in $node.ChildNodes) {

                $pNode = $nNode;$snNode = $sNode.LocalName
            
                AddNodeAndSubNodes -xmlArray([ref]$xmlArray) -row([ref]$row) -q $snNode
            }
        }

        $xmlArray | SELECT Row,Parent,Node,Attribute,ItemType,Value | Export-CSV $fout -NoTypeInformation
    }

# End TRY

# Begin Catch

Catch [System.Runtime.InteropServices.COMException]
{
    $ErrException = Format-ErrMsg -errmsg $_.Exception
    $ErrorMessage = $_.Exception.Message
    $ErrorID = $_.FullyQualifiedErrorId
    $line = $_.InvocationInfo.ScriptLineNumber

    Write-Host                           "  "
    Write-Host                           "  "
    Write-Host -ForegroundColor DarkMagenta  ""
    Write-Host -ForegroundColor Magenta      "==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!=="
    Write-Host -ForegroundColor DarkMagenta  ""
    Write-Host -ForegroundColor DarkCyan     "Details:"  
    Write-Host -ForegroundColor White        "---------------------------------------------------------------------------------------------------------------------------------------------------- "
    Write-Host -ForegroundColor Cyan         "`t  Module:        $modname"
    Write-Host -ForegroundColor Cyan         "`t Section:        $sFunc"
    Write-Host -ForegroundColor Cyan         "`t On Line:        $line"
    Write-Host -ForegroundColor Cyan         "`t File:           $fSearchFile | Search will be skipped!!"
    Write-Host -ForegroundColor White        "---------------------------------------------------------------------------------------------------------------------------------------------------- "
    Write-Host -ForegroundColor DarkCyan      "Exception Message:"  
    Write-Host -ForegroundColor White       "---------------------------------------------------------------------------------------------------------------------------------------------------- "
    Write-Host -ForegroundColor Yellow       "`t ShortMessage:   $ErrorMessage"       
    Write-Host -ForegroundColor Yellow       "`t ErrorID:        $ErrorID"
    Write-Host -ForegroundColor White        "---------------------------------------------------------------------------------------------------------------------------------------------------- "
    Write-Host -ForegroundColor Magenta      "$ErrException"  
    Write-Host -ForegroundColor White        "---------------------------------------------------------------------------------------------------------------------------------------------------- "
    Write-Host -ForegroundColor DarkMagenta  "========================================================================================================================================== "
    Write-Host -ForegroundColor Yellow       "This File will be added to the Skip list. Please restart script $sScriptName ...." 
    Write-Host -ForegroundColor DarkMagenta  "========================================================================================================================================== "
    Write-Host                           "  "
    Write-Host                           "  "
}

Catch
{
    $ErrException = Format-ErrMsg -errmsg $_.Exception
    $ErrorMessage = $_.Exception.Message
    $ErrorID = $_.FullyQualifiedErrorId
    $line = $_.InvocationInfo.ScriptLineNumber

    Write-Host                           "  "
    Write-Host                           "  "
    Write-Host -ForegroundColor DarkRed  "================================================================================================================================================="
    Write-Host -ForegroundColor Red      "==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!==!!Error!!=="
    Write-Host -ForegroundColor DarkRed  "================================================================================================================================================="
    Write-Host -ForegroundColor DarkCyan "Details:"  
    Write-Host -ForegroundColor White    "---------------------------------------------------------------------------------------------------------------------------------------------------- "
    Write-Host -ForegroundColor Cyan     "`t  Module:        $modname"
    Write-Host -ForegroundColor Cyan     "`t Section:        $sFunc"
    Write-Host -ForegroundColor Cyan     "`t On Line:        $line"
    Write-Host -ForegroundColor Cyan     "`t File:           $fSearchFile"
    Write-Host -ForegroundColor White    "---------------------------------------------------------------------------------------------------------------------------------------------------- "
    Write-Host -ForegroundColor DarkCyan "Exception Message:"  
    Write-Host -ForegroundColor White    "---------------------------------------------------------------------------------------------------------------------------------------------------- "
    Write-Host -ForegroundColor Yellow      "`t ShortMessage:   $ErrorMessage"       
    Write-Host -ForegroundColor Magenta  "`t ErrorID:        $ErrorID"
    Write-Host -ForegroundColor White    "---------------------------------------------------------------------------------------------------------------------------------------------------- "
    Write-Host -ForegroundColor Red      "$ErrException"  
    Write-Host -ForegroundColor White    "---------------------------------------------------------------------------------------------------------------------------------------------------- "

# Show etended error info if in debug mode.

    if ($extDebug -eq $true) {

        Write-Host -ForegroundColor White    "---------------------------------------------------------------------------------------------------------------------------------------------------- "
        Write-Host -ForegroundColor Red      "Extended Debugging info"  

        Write-Host -ForegroundColor White    "---------------------------------------------------------------------------------------------------------------------------------------------------- "
        $error[0].Exception | Format-List * -Force
        Write-Host -ForegroundColor White    "---------------------------------------------------------------------------------------------------------------------------------------------------- "

    }

    Write-Host -ForegroundColor DarkRed  "==================================================================================================================================================== "
    Write-Host -ForegroundColor DarkRed  "==================================================================================================================================================== "
    Write-Host                           "  "
    Write-Host                           "  "

    Break

# End Catch
}

# Begin Finally

Finally
{
    "finis."
    Exit 0

# End Finally
}