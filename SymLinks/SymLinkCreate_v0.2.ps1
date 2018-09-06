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

Try {
    "Started;" + $Date + " at " + $Time  | Add-Content $Output
    "Action;Source;ActionStatus;Target" | Add-Content $Output
    If (Test-Path $OutPut)
    {
        Write-Host "Output File OK:" $OutPut
    } else {
        Write-Host "OutPut File NOK :" $OutPut
    }

}
Catch {
    $_.Exception.Message
    $Error.Clear()
}

<# End of Define Output Log File #>


<# Script itself #>
$ArchivedFileDate = $CurrentDate.AddMonths(-($ArchivedFileMonths))
Write-Host "Archive Date:" $ArchivedFileDate


#Test Source and Destination
$SymLinkSourceStatus = $false
$SymLinkTargetStatus = $false



if (TestFolder -FolderToTest $SymLinkSource) {
    $SymLinkSourceStatus = $true
    #Write-Host "Sym Link Source OK:" $SymLinkSource
}

if (TestFolder -FolderToTest $SymLinkTarget ) {
    $SymLinkTargetStatus = $true
    #Write-Host "Sym Link Store OK:" $SymLinkTarget
} else {
    #Try to create Folder in Destination
    if (CreateFolder -FolderToCreate $SymLinkTarget)
    {
        $SymLinkTargetStatus = $true
    }
}

#$ArchivedFileDate = $CurrentDate
$FileList = Get-ChildItem -path $SymLinkSource -File | Where-Object {$_.LinkType -ne "SymbolicLink" -and $_.LastAccessTime -lt $ArchivedFileDate}

if ((($FileList | Measure-Object).Count) -ne 0 -and $SymLinkSourceStatus -and $SymLinkTargetStatus) 
{
    Foreach ($File in $FileList)
    {
       
        Write-Host "Processing File:" $File.FullName " - LastAccessTime:" $File.LastAccessTime
        $FileToTest = TestFile -SourcePath $File.FullName
        

        $AfterMoveFileName = MoveFile -SourcePath $FileToTest -DestinationPath $SymLinkTarget
        #Write-Host "AfterMoveFileName:" $AfterMoveFileName
        if ($AfterMoveFileName) {
            $SymLinkName = $FileToTest.Name+".lnk"
            #Write-Host "SymLink Name:" $SymLinkName
            $Link = CreateSymLinkToFile -SymLinkPath $FileToTest.Directory.FullName -SymLinkName $SymLinkName -SymLinkTarget $AfterMoveFileName
            Write-Host "SymLinkCreated;"$FileToTest.FullName";OK;"$Link.FullName
            #"LinkCreate;" + $FileToTest.FullName + ";OK;" + $Link.FullName | Add-Content $Output
        } else {
            Write-Host "SymLinkCreated;"$FileToTest.FullName";NOK;"
            #"LinkCreate;" + $FileToTest.FullName + ";NOK;" | Add-Content $Output
        }
    }
} else {
    if (($FileList | Measure-Object).Count -eq '0')
    {
        Write-Host "No files to process at:" $SymLinkSource
        "NoFiles;" + $SymLinkSource + ";NOK;" | Add-Content $Output
    }
    if (!$SymLinkSourceStatus)
    {
        Write-Host "Sym Link Source NOK:" $SymLinkSource
        "SourceNOK;" + $SymLinkSource + ";NOK;" | Add-Content $Output
    }
    if (!$SymLinkTargetStatus)
    {
        Write-Host "Sym Link Target NOK:" $SymLinkTarget
        "TargetNOK;" + $SymLinkTarget + ";NOK;" | Add-Content $Output
    }
}

<# End of Script itself #>

$Date = get-date -format yyyy-MM-dd
$Time = get-date -format HH-mm

"Finished;" + $Date + " at " + $Time  | Add-Content $Output
