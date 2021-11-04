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

function xml2csv {
param([string]$fin = "",[string]$fout)
  try {
    if ($fin -ne ""){
      [xml]$xmlContent = get-content $fin -ErrorAction Stop
    }
    else {
      $lines=$input
    }

    $row=0
    $COMMA=","
    $pNode = "ROOT"
    $xmlArray = @([pscustomobject]@{Row= $row;Parent=$pNode;Node=$nNode;Attribute='';ItemType='Root';Value=''})
    Remove-Item $fout -ErrorAction SilentlyContinue

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
    Finally{  "finis." #Exit 0# End Finally
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
}
# End TRY
# Begin Catch
# Begin Finally


    cls
    xml2csv -fin "C:\Users\crbk01\Desktop\Todo.xml" -fout "C:\Users\crbk01\Desktop\Todo.csv"