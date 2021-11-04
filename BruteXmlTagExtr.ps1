
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


function bruteXmlTagExtract([string]$tag = "",[string]$separator = ","))
{
#pars parametrs with param
#foreach ($file in (Get-ChildItem .\EventLogs)) {.\xml2csv.ps1 -tag "event_message" -inputfile $file.fullname >> .\Events.csv}
    $status = "out_tag"

    if ($tag -eq "") {
      "You must enter -tag parameter"
      ""
      usage
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

