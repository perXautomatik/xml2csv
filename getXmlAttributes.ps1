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
