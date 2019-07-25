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
       "TestFile;" + $SourcePath + ";NOK-FileNotFound;" | Add-Content $OutputError
       $_.Exception.Message | Add-content $OutputError
       $Error.Clear()
       Return ""
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

		#$RoboComand = "Robocopy '"+$SourcePath.Directory.FullName+"' '"+$DestinationPath.FullName+"' '"+$SourcePath.Name+"' /MOV /R:0 /W:0 /COPY:DATS /secfix /ZB"

		$RoboComand = "Robocopy '"+$SourcePath.Directory.FullName+"' '"+$DestinationPath.FullName+"' '"+$SourcePath.Name+`
		"' /MOV /R:0 /W:0 /COPY:DATS /secfix /ZB /NP /Log+:"+$RoboFileLog
		#$cmd = "robocopy '"+$fileObj.Directory.FullName+"' '"+$targetObj.Fullname+"' '"+$fileObj.name+"' /MOV /R:0 /W:0"
		
		$RoboOutput = Invoke-Expression -Command $RoboComand
		$RoboError = $LASTEXITCODE
		
        #Copy OK
        if ($RoboError -eq 1) {
            #Write-Host "File:" $SourcePath.FullName " - LastAccessTime:" $SourcePath.LastAccessTime
            "MoveFile;" + $SourcePath.FullName + ";OK-MoveSuccefull;" + $DestinationPath.FullName + ";" + $RoboError| Add-Content $Output
            #Write-host $SourcePath.FullName": Move OK"
            
			$Return = $DestinationPath.FullName+"\"+$SourcePath.Name
			#"Return;" + $Return | Add-Content $Output
			Return $Return
        } else {
			#No Change
			if ($RoboError -eq 0)
			{
				"MoveFileNoChange;" + $SourcePath.FullName +";NOK-NoChange;" + $DestinationPath.FullName + ";" + $RoboError | Add-content $Output
				"MoveFileNoChange;" + $SourcePath.FullName +";NOK-NoChange;" + $DestinationPath.FullName + ";" + $RoboError | Add-content $OutputError
				#$Return = $DestinationPath.FullName+"\"+$SourcePath.Name
				if ((TestFile -SourcePath $SourcePath.FullName).FullName.Length -ne 0 `
					-and (TestFile -SourcePath ($DestinationPath.FullName+"\"+$SourcePath.Name)).FullName.Length -ne 0)
				{
					#delete target file
					"ExtraFile;" + $DestinationPath.FullName+"\"+$SourcePath.Name + ";TobeDeleted" | Add-Content $Output
					DeleteItem -ItemToDelete ($DestinationPath.FullName+"\"+$SourcePath.Name)
				}
				Return ""
			} else {
				#Combination CopyOK + Exta + Mismatch
				If ($RoboError -gt 1 -and $RoboError -lt 8)
				{
					"MoveFileCombo;" + $SourcePath.FullName +";NOK-Combo;" + $DestinationPath.FullName + ";" + $RoboError | Add-content $Output
					"MoveFileCombo;" + $SourcePath.FullName +";NOK-Combo;" + $DestinationPath.FullName + ";" + $RoboError | Add-content $OutputError
					"MoveFileRoboInfo;" + $SourcePath.FullName +";NOK-RoboInfo;" + $DestinationPath.FullName + ";" + $RoboError | Add-content $Output
					"MoveFileRoboInfo;" + $SourcePath.FullName +";NOK-RoboInfo;" + $DestinationPath.FullName + ";" + $RoboError | Add-content $OutputError
					#Return $DestinationPath.FullName+"\"+$SourcePath.Name

					if ((TestFile -SourcePath $SourcePath.FullName).FullName.Length -ne 0 `
						-and (TestFile -SourcePath ($DestinationPath.FullName+"\"+$SourcePath.Name)).FullName.Length -ne 0)
					{
						#delete target file
						"ExtraFile;" + $DestinationPath.FullName+"\"+$SourcePath.Name + ";TobeDeleted" | Add-Content $Output
						DeleteItem -ItemToDelete ($DestinationPath.FullName+"\"+$SourcePath.Name)
					}
					Return ""
				} Else {
					#ERROR
					"MoveFileError;" + $SourcePath.FullName +";NOK-Error;" + $DestinationPath.FullName + ";" + $RoboError | Add-content $Output
					"MoveFileError;" + $SourcePath.FullName +";NOK-Error;" + $DestinationPath.FullName + ";" + $RoboError | Add-content $OutputError
					"MoveFileRoboError;" + $SourcePath.FullName + ";NOK-RoboError;" + $DestinationPath.FullName + ";" + $RoboError | Add-content $Output
					"MoveFileRoboError;" + $SourcePath.FullName + ";NOK-RoboError;" + $DestinationPath.FullName + ";" + $RoboError | Add-content $OutputError				
					Return ""
				}
			}
		}
	}
    Catch 
    {             
        #Write-host $SourcePath.FullName": Move NOK"
        "MoveFileErrorCatch;" + $SourcePath.FullName +";NOK-CheckException;"+ $DestinationPath.FullName  | Add-content $Output
		"MoveFileErrorCatch;" + $SourcePath.FullName +";NOK-CheckException;"+ $DestinationPath.FullName  | Add-content $OutputError
        $_.Exception.Message | Add-content $OutputError
        $Error.Clear()
        Return ""
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
        "SymLink;" + $SymLinkName + ";OK-Created;" + $SymLinkTarget | Add-Content $Output
        Return $link
    }
    catch {
        
        #Write-Host $SymLinkName": SymLink NOK"
        "SymLinkError;" + $SymLinkName + ";NOK-CheckException;" + $SymLinkTarget | Add-Content $Output
		"SymLinkError;" + $SymLinkName + ";NOK-CheckException;" + $SymLinkTarget | Add-Content $OutputError
        $_.Exception.Message | Add-content $OutputError
        $Error.Clear()
        Return ""
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
        "DeleteItem;" + $ItemToDelete + ";NOK-CheckException" | Add-Content $Output
        $_.Exception.Message | Add-content $Output
        $Error.Clear()
        Return $false
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

Function RoboFolder{
    Param(
        
        [Parameter(Mandatory=$true)]
        $SourceFolder,
		[Parameter(Mandatory=$true)]
        $TargetFolder
    )
    try 
    {
        #Robo Folder
		#$cmd = "robocopy '"+$ObjSource.FullName+"' '"+$ObjTarget.Fullname+"' /xf * /CopyAll /lev:0 /zb"
		#$RoboComand = "Robocopy '"+$SourceFolder+"' '"+$TargetFolder+"' /xf * /COPY:DATS /secfix /Lev:0 /ZB /R:0 /W:0"
		
		$RoboComand = "Robocopy '"+$SourceFolder+"' '"+$TargetFolder+`
		"' /xf * /COPY:DATS /secfix /Lev:0 /ZB /R:0 /W:0 /NP /Log+:"+$RoboDirLog
		
		$RoboOutput = Invoke-Expression -Command $RoboComand
		$RoboError = $LASTEXITCODE
		#$RoboErrorText = GetRoboErrorLevel -RoboLastExitCode $RoboError
		if ($RoboError -eq 1)
		{
			#Copy OK
			"DestinationFolder;" + $TargetFolder + ";OK-Created;" + $RoboError | Add-Content $Output
			Return TestFolder -FolderToTest $TargetFolder
		} Else {
			If ($RoboError -eq 0)
			{
				#No change
				"DestinationFolderNoChange;" + $TargetFolder + ";OK-AccessDeniedOrSkipped;" + $RoboError | Add-Content $Output
				Return TestFolder -FolderToTest $TargetFolder
			} Else {
				#Combination CopyOK + Exta + Mismatch
				If ($RoboError -gt 1 -and $RoboError -lt 8)
				{
					
					"DestinationFolderCombo;" + $TargetFolder + ";OK-Combo;" + $RoboError | Add-Content $Output
					Return TestFolder -FolderToTest $TargetFolder
				} Else {
					#Error
					"DestinationFolderError;" + $TargetFolder + ";NOK-CheckError;" + $RoboError | Add-Content $Output
					"DestinationFolderError;" + $TargetFolder + ";NOK-CheckError;" + $RoboError | Add-Content $OutputError
					Return ""
				}
			}
		}

    }
    catch {
        #Write-Host "Create Destination Folder: "$FolderToCreate "OK"
        "DestinationFolder;" + $TargetFolder + ";NOK-CheckException" | Add-Content $Output
		"DestinationFolder;" + $TargetFolder + ";NOK-CheckException" | Add-Content $OutputError
        $_.Exception.Message | Add-content $OutputError
        $Error.Clear()
        Return ""
    }
}

Function GetRoboErrorLevel {
Param(
        
        [Parameter(Mandatory=$true)]
        $RoboLastExitCode
    )

	switch($RoboLastExitCode) {
		0 {Return "NoChange"; break} 
		1 {Return "CopyOK"; break}
		2 {Return "Extra";break}
		4 {Return "Mismathces";break}
		5 {Return "CopyOK and Mismatches"; break}
		6 {Return "Extra and Mismatches"; break}
		7 {Return "CopyOK and Mismatches"; break}
		8 {Return "Fail"; break}
		9 {Return "CopyOK and Fail"; break}
		10 {Return "Extra and Fail"; break}
		11 {Retun "CopyOK and Extra and Fail"; break}
		12 {Return "Fail and Mismatches"; break}
		13 {Return "CopyOK and Fail and Mismatches"; break}
		14 {Return "Fail and Mismatches and Extra"; break}
		15 {Return "CopyOK and Fail and Mismatches"; break}
		16 {Return "FatalError"; break}
	}
}