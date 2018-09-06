<######################################################
#
# Author: Ivan Batis - ivan.bati@dxc.com
# Usage: [Script].ps1
# Version: 0.1 [Script Description]
# Info: Functions definitions required in other scripts
#
#######################################################>

<################ FUNCTIONS #######################>
Function TestFile{
    Param(
        [parameter(Mandatory=$true)]
        $SourcePath
    )
    Try
    {
        $FileToTest = Get-Item -path $SourcePath
        #Write-host  $FileToTest.FullName": File Found"
        #"TestFile;" + $SourcePath + ";OK;" | Add-Content $Output
        Return $FileToTest
    }
    Catch
    {
       #Write-host $SourcePath": File Not Found"
       #"TestFile;" + $SourcePath + ";NOK;" | Add-Content $Output
       $_.Exception.Message | Add-content $Output
       $Error.Clear()
       Return $false
       break
    }
    Return ""
    }
    
Function MoveFile{
Param(
    [parameter(Mandatory=$true)]
    $SourcePath,
    [parameter(Mandatory=$true)]
    $DestinationPath
)
    #Write-Host "MoveFile:" $SourcePath
    Try 
    {
        $DestinationPathLastIndex = $DestinationPath.LastIndexOf("\")
        $DestinationPathLength = $DestinationPath.Length
        if ($DestinationPathLastIndex -ne $DestinationPathLength) {
            $DestinationPath = $DestinationPath + "\"
        }
        #Write-Host "Move Destination:" $DestinationPath
        
        Move-Item -LiteralPath $SourcePath.FullName -Destination $DestinationPath -Confirm:$false
        
        if ($error) {
            #Write-host $SourcePath.FullName": Move NOK"
            "MoveFile;" + $SourcePath.FullName +";NOK;"+ $DestinationPath | Add-content $Output
            "MoveFileError;" + $SourcePath.FullName +";NOK;"+ $Error | Add-content $Output
            $error.Clear()
        } else {
            #Write-Host "File:" $SourcePath.FullName " - LastAccessTime:" $SourcePath.LastAccessTime
            "MoveFile;" + $SourcePath.FullName + ";OK;" + $DestinationPath | Add-Content $Output
            Write-host $SourcePath.FullName": Move OK"
            Return $DestinationPath+$SourcePath.Name
        }
    }
    Catch 
    {             
        #Write-host $SourcePath.FullName": Move NOK"
        "MoveFile;" + $SourcePath.FullName +";NOK;"+ $DestinationPath | Add-content $Output
        $_.Exception.Message | Add-content $Output
        $Error.Clear()
        Return ""
        break
    }
}

Function CreateSymLinkToFile{
Param(
    
    [Parameter(Mandatory=$true)]
    $SymLinkPath,
    [Parameter(Mandatory=$true)]
    $SymLinkName,
    [Parameter(Mandatory=$true)]
    $SymLinkTarget
)

    try {
        $link = New-Item -ItemType SymbolicLink -Path $SymLinkPath -Name $SymLinkName -Value $SymLinkTarget -Force
        #Write-Host $SymLinkName": SymLink OK"
        "LinkCreated;" + $SymLinkName + ";OK;" + $SymLinkTarget | Add-Content $Output
        Return $link
    }
    catch {
        
        #Write-Host $SymLinkName": SymLink NOK"
        "LinkCreated;" + $SymLinkName + ";NOK;" + $SymLinkTarget | Add-Content $Output
        $_.Exception.Message | Add-content $Output
        $Error.Clear()
        Return ""
        break
    }

}

Function DeleteItem{
    Param(
        
        [Parameter(Mandatory=$true)]
        $ItemToDelete
    )
    try {
        Remove-Item -Path $ItemToDelete
        #Write-Host $SymLinkPath": Deleted OK"
        "DeleteItem;" + $ItemToDelete + ";OK" | Add-Content $Output
        Return $true
    }
    catch {
        
        #Write-Host $SymLinkPath": Deleted NOK"
        "DeleteItem;" + $ItemToDelete + ";NOK" | Add-Content $Output
        $_.Exception.Message | Add-content $Output
        $Error.Clear()
        Return $false
        break
    }

}


Function TestFolder{
    Param(
        
        [Parameter(Mandatory=$true)]
        $FolderToTest
    )
    $item = Get-Item -Path $FolderToTest
    if ($item.Attributes -eq "Directory")
    {
        return $item.FullName
    } else {
        return $false
    }
}

Function CreateFolder{
    Param(
        
        [Parameter(Mandatory=$true)]
        $FolderToCreate
    )
    try 
    {
        New-Item -Path $FolderToCreate -ItemType Directory
        #Write-Host "Create Destination Folder: "$FolderToCreate "OK"
        "CreateDestinationFolder;" + $FolderToCreate + ";OK" | Add-Content $Output
        Return $true
    }
    catch {
        
        Write-Host "Create Destination Folder: "$FolderToCreate "OK"
        "CreateDestinationFolder;" + $FolderToCreate + ";NOK" | Add-Content $Output
        $_.Exception.Message | Add-content $Output
        $Error.Clear()
        Return $false
    }
}