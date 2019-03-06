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
#$Output = "..\Logs\SymLinksCreate_" + $date + "_" + $Time + ".txt"
$Output = $OutPutFolder + "\SymLinksCreate_" + $date + ".txt"
$OutputError = $OutPutFolder + "\SymLinksCreateErrors_" + $date + ".txt"

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
#Write-Host "Archive Date:" $ArchivedFileDate


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


if ((($FileList | Measure-Object).Count) -ne 0 -and $ObjSymLinkTarget.FullName.Length -ne 0 -and $ObjSymLinkSource.FullName.Lenght -ne 0) 
{
    Foreach ($File in $FileList)
    {
       
        #Write-Host "Processing File:" $File.FullName " - LastAccessTime:" $File.LastAccessTime
        $FileToTest = TestFile -SourcePath $File.FullName
        $AfterMoveFileName = ""
		if (!($FileToTest.Length -eq 0))
		{
			$AfterMoveFileName = RoboFile -SourcePath $FileToTest -DestinationPath $ObjSymLinkTarget

			#Write-Host "AfterMoveFileName:" $AfterMoveFileName

			$ObjAfterMoveFileName = ""
			$ObjAfterMoveFileName = TestFile -SourcePath $AfterMoveFileName

			if (!($ObjAfterMoveFileName.FullName.Length -eq 0)) {
				$SymLinkName = $FileToTest.Name+".lnk"
				#Write-Host "SymLink Name:" $SymLinkName
				$Link = CreateSymLinkToFile -SymLinkPath $FileToTest.Directory.FullName -SymLinkName $SymLinkName -SymLinkTarget $ObjAfterMoveFileName.FullName
				#Write-Host "SymLinkCreated;"$FileToTest.FullName";OK;"$Link.FullName				
			} else {
				#Write-Host "SymLinkError;"$FileToTest.FullName";NOK;"
				"MoveFileError;" + $FileToTest.FullName + ";NOK-TargetFileNotFound;" | Add-Content $Output
			}
		} else {
			#File NOT found
			"SourceFileError;" + $File.FullName + ";NOK-SourceFileNotFound;" | Add-Content $OutputError
		}
    }
} else {
    if (($FileList | Measure-Object).Count -eq '0')
    {
        #Write-Host "No files to process at:" $SymLinkSource
        "NoFiles;" + $SymLinkSource + ";NOK;" | Add-Content $Output
    }
    if (!$SymLinkSourceStatus)
    {
        #Write-Host "Sym Link Source NOK:" $SymLinkSource
        "SourceNOK;" + $SymLinkSource + ";NOK;" | Add-Content $Output
    }
    if (!$SymLinkTargetStatus)
    {
        #Write-Host "Sym Link Target NOK:" $SymLinkTarget
        "TargetNOK;" + $SymLinkTarget + ";NOK;" | Add-Content $Output
    }
}

<# End of Script itself #>

$Date = get-date -format yyyy-MM-dd
$Time = get-date -format HH-mm

#"Finished;" + $Date + " at " + $Time  | Add-Content $Output
