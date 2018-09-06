<######################################################
#
# Author: Ivan Batis - ivan.bati@dxc.com
# Usage: [Script].ps1
# Version: 0.1 [Script Description]
# Info: Simple script with some Parameters
#
# Usage: [scriptname].ps1 -ConfigFilePath [Config File Path]
#
#######################################################>

#Parameters
Param(
    [Parameter(Mandatory=$false)]
    [string]$ShareConfigFile = ".\ShareConfig.txt",
    [Parameter(Mandatory=$false)]
    [string]$ConfigFile = ".\ConfigFile.txt"
)

<# Script itself #>
try 
{
    $ShareConfig = Import-Csv -path $ShareConfigFile
}
catch 
{
    $_.Exception.Message
    $Error.Clear()
    break
}

Try {
    $Config = Get-Content -Path $ConfigFile
    foreach ($Line in $Config)
    {
        If (!($Line.StartsWith("#")))
        {
            Write-Host $line
            if ($Line.StartsWith("WriteBackLogFolder:"))
            {
                $WriteBackLogFolder = ($Line.Split(":"))[1]
            }
            if ($Line.StartsWith("SymLinkCreateLogFolder:"))
            {
                $SymLinkCreateLogFolder = ($Line.Split(":"))[1]
            }
            if ($Line.StartsWith("RevertSymLinkFileDays:"))
            {
                $RevertSymLinkFileDays = ($Line.Split(":"))[1]
            }
            if ($Line.StartsWith("MoveFileToSymLinkStoreMonths:"))
            {
                $MoveFileToSymLinkStoreMonths = ($line.Split(":"))[1]
            }
        }
        
    }
    If ($WriteBackLogFolder -and $SymLinkCreateLogFolder `
        -and $RevertSymLinkFileDays -and $MoveFileToSymLinkStoreMonths)
        {
            <#
            Write-Host $WriteBackLogFolder
            Write-Host $SymLinkCreateLogFolder
            Write-Host $RevertSymLinkFileDays
            Write-Host $MoveFileToSymLinkStoreMonths
            #>
        } else {
            Write-Host "Missing config item."
            exit
        }

}
catch {
    $_.Exception.Message
    $Error.Clear()
    break
}

ForEach ($Share in $ShareConfig)
{
    write-host $share.Share ":" $Share.Source "->" $Share.Target
    $SourceFolderRoot = Get-Item $Share.Source
    $FolderList = Get-ChildItem -Path $share.Source -Directory -Recurse
    
    #Root Folder Processing
    $ScriptParams = "-SymLinkSource " + '"' + $SourceFolderRoot.FullName +  '"' + `
        " -SymLinkTarget " + '"' + $Share.Target + '"' + `
        " -ArchivedFileMonths " + '"' + $MoveFileToSymLinkStoreMonths + '"' + `
        " -OutPutFolder " + '"' + $SymLinkCreateLogFolder + '"'
    Invoke-Expression ".\SymLinkCreate_v0.2.ps1 $ScriptParams"

    #Sub Folders Processing
    ForEach ($SourceFolder in $FolderList)
    {
        $RelativePath = $SourceFolder.FullName.Replace($SourceFolderRoot,"")
        $TargetFolder = $Share.Target+$RelativePath
        #Write-Host "FullName:"$SourceFolder.FullName " - TargetPath": $TargetFolder
        
        $ScriptParams = "-SymLinkSource " + '"' + $SourceFolder.FullName +  '"' + `
        " -SymLinkTarget " + '"' + $TargetFolder + '"' + `
        " -ArchivedFileMonths " + '"' + $MoveFileToSymLinkStoreMonths + '"' + `
        " -OutPutFolder " + '"' + $SymLinkCreateLogFolder + '"'
        
        Invoke-Expression ".\SymLinkCreate_v0.2.ps1 $ScriptParams"
    }
    #Write-Host "---=====---"

}