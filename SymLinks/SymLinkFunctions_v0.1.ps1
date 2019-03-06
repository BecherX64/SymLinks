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
       "TestFile;" + $SourcePath + ";NOK;" | Add-Content $OutputError
       $_.Exception.Message | Add-content $Output
       $Error.Clear()
       Return ""
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
			"MoveFileError;" + $SourcePath.FullName +";NOK;"+ $Error | Add-content $OutputError
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
        "MoveFileError;" + $SourcePath.FullName +";NOK;"+ $DestinationPath | Add-content $Output
		"MoveFileError;" + $SourcePath.FullName +";NOK;"+ $DestinationPath | Add-content $OutputError
        $_.Exception.Message | Add-content $OutputError
        $Error.Clear()
        Return ""
        break
    }
}

Function RoboFile{
Param(
    [parameter(Mandatory=$true)]
    $SourcePath,
    [parameter(Mandatory=$true)]
    $DestinationPath
)
    #Write-Host "MoveFile:" $SourcePath
    Try 
    {

		$RoboComand = "Robocopy '"+$SourcePath.Directory.FullName+"' '"+$DestinationPath.FullName+"' '"+$SourcePath.Name+"' /MOV /R:0 /W:0 /SEC"
		#$cmd = "robocopy '"+$fileObj.Directory.FullName+"' '"+$targetObj.Fullname+"' '"+$fileObj.name+"' /MOV /R:0 /W:0"

		$RoboOutput = Invoke-Expression -Command $RoboComand
		$RoboError = $LASTEXITCODE

		Write-Host "RoboResults: " $RoboError
        
        if ($RoboError -eq 1) {
            #Write-Host "File:" $SourcePath.FullName " - LastAccessTime:" $SourcePath.LastAccessTime
            "MoveFile;" + $SourcePath.FullName + ";OK;" + $DestinationPath.FullName | Add-Content $Output
            Write-host $SourcePath.FullName": Move OK"
            Return $DestinationPath+"\"+$SourcePath.Name
        } else {
            #Write-host $SourcePath.FullName": Move NOK"
            "MoveFile;" + $SourcePath.FullName +";NOK;"+ $DestinationPath.FullName | Add-content $Output
			"MoveFile;" + $SourcePath.FullName +";NOK;"+ $DestinationPath.FullName | Add-content $OutputError
            "MoveFileError;" + $SourcePath.FullName +";NOK;"+ $Error | Add-content $Output
			"MoveFileError;" + $SourcePath.FullName +";NOK;"+ $Error | Add-content $OutputError
			Return ""
            $error.Clear()
        }
    }
    Catch 
    {             
        #Write-host $SourcePath.FullName": Move NOK"
        "MoveFileError;" + $SourcePath.FullName +";NOK;"+ $DestinationPath.FullName  | Add-content $Output
		"MoveFileError;" + $SourcePath.FullName +";NOK;"+ $DestinationPath.FullName  | Add-content $OutputError
        $_.Exception.Message | Add-content $OutputError
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
        return $item
    } else {
        return ""
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