<######################################################
#
# Author: Ivan Batis - ivan.bati@dxc.com
# Usage: [Script].ps1
# Version: 0.1 [Script Description]
# Info: Simple script with some Parameters
#
# Usage: [scriptname].ps1 -SymLinkSource [SymLinkSource] -SymLinkTarget [SymLinkTarget]
#
#######################################################>

#Parameters
Param(
    [Parameter(Mandatory=$True)]
    [string]$SymLinkSource,
    [Parameter(Mandatory=$True)]
    [string]$SymLinkTarget,
    [Parameter(Mandatory=$false)]
    [int16]$ArchivedFileMonths=2,
    [Parameter(Mandatory=$True)]
    [string]$OutPutFolder=".\Logs"
)

<################ SCRIPT BODY #######################>
#Setup date and time for log output

. .\SymLinkFunctions_v0.1.ps1
$error.clear()

$CurrentDate = get-date
$Date = get-date -format yyyy-MM-dd
$Time = get-date -format HH-mm

Import-Module ActiveDirectory

<# Custom Variables #>
#$SymLinkSource = "C:\SymLinkSource\"
#$SymLinkSource = "C:\Temp\"
#$SymLinkTarget = "\\azureSync-dc01\SymLinkStrore$\"
#$ArchivedFileYears = 2

<#End of Custom Variables #>

<# Define Output Log File #>
<# Old way
$Output = $OutPutFolder + "\SymLinksCreate_" + $date + ".txt"
$OutputError = $OutPutFolder + "\SymLinksCreateErrors_" + $date + ".txt"
$RoboDirLog = $OutPutFolder + "\SymLinksCreateRoboDir_" + $date + ".txt"
$RoboFileLog = $OutPutFolder + "\SymLinksCreateRoboFile_" + $date + ".txt"
#>

#New way how to name OutPut logs - Date first
$Output = $OutPutFolder + "\"+ $date + "_SymLinksCreate.txt"
$OutputError = $OutPutFolder + "\" + $date + "_SymLinksCreateErrors.txt"
$RoboDirLog = $OutPutFolder + "\" + $date + "_SymLinksCreateRoboDir.txt"
$RoboFileLog = $OutPutFolder + "\" + $date + "_SymLinksCreateRoboFile.txt"


Try {
    #"Started;" + $Date + " at " + $Time  | Add-Content $Output
    "Action;Source;ActionStatus;Target" | Add-Content $Output
	"Action;Source;ActionStatus;Target" | Add-Content $OutputError
    If (Test-Path $OutPut)
    {
        #Write-Host "Output File OK:" $OutPut
    } else {
        #Write-Host "OutPut File NOK :" $OutPut
    }

	If (Test-Path $OutPutError)
    {
        #Write-Host "Output File OK:" $OutputError
    } else {
        #Write-Host "OutPut File NOK :" $OutputError
    }
}
Catch {
    #$_.Exception.Message
    $Error.Clear()
}

<# End of Define Output Log File #>


<# Script itself #>
$ArchivedFileDate = $CurrentDate.AddMonths(-($ArchivedFileMonths))
#Comment for test
#"Archive Date;" + $ArchivedFileDate | Add-Content $OutPut


#Test Source and Destination
$ObjSymLinkSource = TestFolder -FolderToTest $SymLinkSource
$ObjSymLinkTarget = TestFolder -FolderToTest $SymLinkTarget

if (!($ObjSymLinkSource.FullName.Length -eq 0)) {
    $SymLinkSourceStatus = $true
    #Write-Host "Sym Link Source OK:" $SymLinkSource
}

if (!($ObjSymLinkTarget.FullName.Length -eq 0 )) {
	#RoboFolder
	$ObjSymLinkTarget = RoboFolder -SourceFolder $ObjSymLinkSource.FullName -TargetFolder $ObjSymLinkTarget.Fullname

} else {
    #RoboFolder
	$ObjSymLinkTarget = RoboFolder -SourceFolder $ObjSymLinkSource.FullName -TargetFolder $SymLinkTarget
}

#$ArchivedFileDate = $CurrentDate
$FileList = Get-ChildItem -path $ObjSymLinkSource.FullName -File | Where-Object {$_.LinkType -ne "SymbolicLink" -and $_.LastAccessTime -lt $ArchivedFileDate}

#Testing output
"Initial;" + $ObjSymLinkSource.FullName + ";"+ ($FileList | Measure-Object).Count + ";" + $ObjSymLinkTarget.FullName + ";" + $ArchivedFileDate | Add-Content $OutPut

if ((($FileList | Measure-Object).Count) -ne 0 -and $ObjSymLinkTarget.FullName.Length -ne 0 -and $ObjSymLinkSource.FullName.Length -ne 0) 
{
	#Comment for test
	
    Foreach ($File in $FileList)
    {
       
        #Write-Host "Processing File:" $File.FullName " - LastAccessTime:" $File.LastAccessTime
        $FileToTest = TestFile -SourcePath $File.FullName
        $AfterMoveFileName = ""
		if (!($FileToTest.Length -eq 0))
		{
			
			#MoveFile
			#$AfterMoveFileName = MoveFile -SourcePath $FileToTest -DestinationPath $SymLinkTarget

			#RoboFile
			#"RoboFile: start" | Add-Content $OutPut
			$AfterMoveFileName = RoboFile -SourcePath $FileToTest -DestinationPath $ObjSymLinkTarget

			#Write-Host "AfterMoveFileName:" $AfterMoveFileName
			#"RoboFile: Done - AfterMoveFileName:" + $AfterMoveFileName | Add-Content $Output
			if (!($AfterMoveFileName.Length -eq 0))
			{
				$ObjAfterMoveFileName = ""
				$ObjAfterMoveFileName = TestFile -SourcePath $AfterMoveFileName

				if (!($ObjAfterMoveFileName.FullName.Length -eq 0)) {
					$SymLinkName = $FileToTest.Name+".lnk"
					#"SymLink Name:" + $SymLinkName | Add-Content $OutPut
					$Link = CreateSymLinkToFile -SymLinkPath $FileToTest.Directory.FullName -SymLinkName $SymLinkName -SymLinkTarget $ObjAfterMoveFileName.FullName
					#Write-Host "SymLinkCreated;"$FileToTest.FullName";OK;"$Link.FullName				
				} else {
					#Write-Host "SymLinkError;"$FileToTest.FullName";NOK;"
					"TargetFileError;" + $FileToTest.FullName + ";NOK-TargetFileNotFound;" | Add-Content $Output
				}
			} Else {
				#AfterMoveFileName Empty
			}
		} else {
			#File NOT found or ZERO Length
			If ($File.Lenght -eq 0)
			{
				#ZERO Lenght
				"SourceFileEmpty;" + $File.FullName + ";NOK-SourceFileSkipped;" | Add-Content $OutputError
			} Else {
				"SourceFileError;" + $File.FullName + ";NOK-SourceFileNotFound;" | Add-Content $OutputError
			}
		}
    }
	
	#End of test comment
	
	#Testing
	#"InputPath;" + $ObjSymLinkSource.FullName + ";OK-Files;"+ ($FileList | Measure-Object).Count + ";" + $ObjSymLinkTarget.FullName | Add-Content $OutPut

} else {
    if (($FileList | Measure-Object).Count -eq 0)
    {
        #Write-Host "No files to process at:" $SymLinkSource
        "NoFiles;" + $ObjSymLinkSource.FullName + ";OK-NoFilesInSource;" + $ObjSymLinkTarget.FullName | Add-Content $Output
    } Else {
		"UnknownStatus;" + $ObjSymLinkSource.FullName + ";" + ($FileList | Measure-Object).Count  + ";" + $ObjSymLinkTarget.FullName | Add-Content $OutPut
	}
	
}

<# End of Script itself #>

$Date = get-date -format yyyy-MM-dd
$Time = get-date -format HH-mm

#"Finished;" + $Date + " at " + $Time  | Add-Content $Output
