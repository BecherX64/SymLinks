<######################################################
#
# Author: Ivan Batis - ivan.bati@hp.com
# Usage: [Script].ps1
# Version: 0.1 [Script Description]
# Info: Simple script with no input file
#
#######################################################>

<################ FUNCTIONS #######################>
Function TestFile{
    Param(
        [parameter(Mandatory=$true)]
        $SourcePath = $SymLinkSource
    )
    Try
    {
        $FileToTest = Get-Item -path $SourcePath
        Write-host  $FileToTest.FullName": File Found"
        Return $FileToTest.FullName
    }
    Catch
    {
       $_.Exception.Message | Add-content $Output
       Write-host $SourcePath": File Not Found"
       Return $false
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
        Move-Item -Path $SourcePath.FullName -Destination $DestinationPath -force
        "Move;" + $SourcePath.FullName + ";OK;" + $DestinationPath | Add-Content $Output
        Write-host $SourcePath.FullName": Move OK"
        Return $DestinationPath+$SourcePath.Name
    }
    Catch 
    {             
        $_.Exception.Message | Add-content $Output
        $Error.Clear()
        Write-host $SourcePath.FullName": Move NOK"
        "Move;" + $SourcePath.FullName +";NOK" | Add-content $Output
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
        Write-Host $SymLinkName": SymLink OK"
        "SymLink;" + $SymLinkName + ";OK;" + $SymLinkTarget | Add-Content $Output
        Return $link
    }
    catch {
        $_.Exception.Message | Add-content $Output
        $Error.Clear()
        Write-Host $SymLinkName": SymLink NOK"
        "SymLink;" + $SymLinkName + ";NOK;" + $SymLinkTarget | Add-Content $Output
        Return ""
    }

}


<################ SCRIPT BODY #######################>
#Setup date and time for log output
$error.clear()

$Date = get-date -format yyyy-MM-dd
$Time = get-date -format HH-mm

Import-Module ActiveDirectory

<# Custom Variables #>
$SymLinkSource = "C:\SymLinkSource\"
$SymLinkStore = "\\azureSync-dc01\SymLinkStrore$\"
<#End of Custom Variables #>

<# Define Output Log File #>
$Output = "..\Logs\SymLinksTest_" + $date + "_" + $Time + ".txt"
If (Test-Path $Output) 
{
    Remove-Item $Output
}
<# End of Define Output Log File #>

"Started: on " + $Date + " at " + $Time  | Add-Content $Output
<# Script itself #>
$FileList = Get-ChildItem -path $SymLinkSource -File | Where-Object {$_.LinkType -ne "SymbolicLink"}
if ((($FileList | Measure-Object).Count) -ne '0') 
{
    "Action;Source;ActionStatus;Target" | Add-Content $Output
    Foreach ($File in $fileList)
    {
        $AfterMoveFileName = MoveFile -SourcePath $File -DestinationPath $SymLinkStore
        $SymLinkName = $File.Name+".lnk"
        $link = CreateSymLinkToFile -SymLinkPath $File.Directory.FullName -SymLinkName $SymLinkName -SymLinkTarget $AfterMoveFileName
        #Write-Host $link.FullName
    }
} else {
    Write-Host "No files to process..."
}

<# End of Script itself #>

$Date = get-date -format yyyy-MM-dd
$Time = get-date -format HH-mm

"Finished: on " + $Date + " at " + $Time  | Add-Content $Output
