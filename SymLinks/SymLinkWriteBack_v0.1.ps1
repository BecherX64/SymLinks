<######################################################
#
# Author: Ivan Batis - ivan.bati@dxc.com
# Usage: [Script].ps1
# Version: 0.1 [Script Description]
# Info: Simple script with Parameters
#
# Usage: [scriptname].ps1 -SymLinkSource [SymLinkSource] -ArchivedFileDays [Number of Days for LastWriteTime]
#
#######################################################>

#Parameters
Param(
    [Parameter(Mandatory=$True)]
    [string]$SymLinkSource,
    [Parameter(Mandatory=$false)]
    [int16]$ArchivedFileDays=30,
    [Parameter(Mandatory=$false)]
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
<#End of Custom Variables #>

<# Define Output Log File #>
<# Old way
$Output = $OutPutFolder + "\SymLinksRevert_" + $date + ".txt"
$OutputError = $OutPutFolder + "\SymLinksRevertErrors_" + $date + ".txt"
$RoboDirLog = $OutPutFolder + "\SymLinksRevertRoboDir_" + $date + ".txt"
$RoboFileLog = $OutPutFolder + "\SymLinksRevertRoboFile_" + $date + ".txt"
#>

#New way how to name OutPut logs - Date first
$Output = $OutPutFolder + "\" + $date + "_SymLinksRevert.txt"
$OutputError = $OutPutFolder + "\" + $date + "_SymLinksRevertErrors.txt"
$RoboDirLog = $OutPutFolder + "\" + $date + "_SymLinksRevertRoboDir.txt"
$RoboFileLog = $OutPutFolder + "\" + $date + "_SymLinksRevertRoboFile.txt"

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

	    If (Test-Path $OutputError)
    {
        #Write-Host "Output File OK:" $OutPutError
    } else {
        #Write-Host "OutPut File NOK :" $OutPutError
    }


}
Catch {
    $_.Exception.Message
    $Error.Clear()
}


<# End of Define Output Log File #>


<# Script itself #>

# ALIGN WITH CUSTOMER REQUIRMENTS IN PROD
$ArchivedFileDate = $CurrentDate.AddDays(-($ArchivedFileDays))

#Write-Host "ArchivedDate:" $ArchivedFileDate
$SymLinkList = Get-ChildItem -path $SymLinkSource -File | Where-Object {$_.LinkType -eq "SymbolicLink"}

$ObjSymLinkSource = TestFolder -FolderToTest $SymLinkSource

if ((($SymLinkList | Measure-Object).Count) -ne '0' -and $ObjSymLinkSource.FullName.Length -ne 0) 
{ 
    Foreach ($Link in $SymLinkList)
    {
        #Write-Host "Processing Link" $Link.FullName
        $LinkTarget = TestFile -SourcePath $Link.Target.Replace("UNC","\")
        if ($LinkTarget.LastWriteTime -gt $ArchivedFileDate) 
        {

			#MoveFile
            #$AfterMoveFileName = MoveFile -SourcePath $LinkTarget -DestinationPath $SymLinkSource
			
			#Robo
			$AfterMoveFileName = RoboFile -SourcePath $LinkTarget -DestinationPath $ObjSymLinkSource

			$ObjAfterMoveFileName = ""
			$ObjAfterMoveFileName = TestFile -SourcePath $AfterMoveFileName

            if (!($ObjAfterMoveFileName.FullName.Length -eq 0)) {
                if (DeleteItem -ItemToDelete $Link.FullName) 
                {
                    #Write-Host "LinkRevert;"$Link.FullName";OK;"$AfterMoveFileName
                    "LinkRevert;" + $Link.FullName + ";OK-RevertDone;" + $ObjAfterMoveFileName.FullName | Add-Content $Output
                } 
            } else {
                #Write-Host "LinkRevert;"$Link.FullName";NOK"
                "LinkRevert;" + $Link.FullName + ";NOK-CheckErrors" | Add-Content $Output
				"LinkRevert;" + $Link.FullName + ";NOK-CheckErrors" | Add-Content $OutputError
            }
        } else {
            #Write-Host "NOK:" $LinkTarget " - " $LinkTarget.LastWriteTime
            Write-Host "LinkSkip;"$Link.FullName";Skip;"$LinkTarget
            "LinkSkip;" + $Link.FullName + ";Skip;" + $LinkTarget | Add-Content $Output
        }
        

    }
} else {
    if (($SymLinkList | Measure-Object).Count -eq '0')
    {
        Write-Host "No Links to process at:" $SymLinkSource
        "NoLinks;" + $SymLinkSource + ";NOK;" | Add-Content $Output
    } else {
        Write-Host "Something bad happend..."    
        "Unknown;Unknown;NOK;" | Add-Content $Output
    }
    

    
}

<# End of Script itself #>

$Date = get-date -format yyyy-MM-dd
$Time = get-date -format HH-mm

#"Finished;" + $Date + " at " + $Time  | Add-Content $Output
