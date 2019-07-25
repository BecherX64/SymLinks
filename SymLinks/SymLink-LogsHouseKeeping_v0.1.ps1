<######################################################
#
# Author: Ivan Batis - ivan.bati@dxc.com
# Version: 0.1 [Script Description]
# Info: Simple script with some Parameters
#
# Usage: [scriptname].ps1 -ConfigFile [Config File Path] -Months [number of months]
#
#######################################################>

#Parameters
Param(
    [Parameter(Mandatory=$false)]
    [int]$Months = -2,
    [Parameter(Mandatory=$false)]
    [string]$ConfigFile = ".\ConfigFile.txt"

)

$error.clear()
$Date = get-date -format yyyy-MM-dd
$Time = get-date -format HH-mm

#Fix number of Months
If ($Months -gt 0)
{
	$Months = $Months * -1
}

#Analyza and read ConfigFile
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
	Write-Host "---------=================------------"
}
catch {
    $_.Exception.Message
    $Error.Clear()
    break
}

#Settings script variables
$PathToLogFiles = $SymLinkCreateLogFolder
#Dates definition
$ListLogsFromMonth = (Get-Date).Date.AddMonths($Months).Date.Month
$ListLogsFromYear = (Get-Date).Date.AddMonths($Months).Date.Year
$DateForOutputFileName = (Get-Date).AddMonths($Months).toString("yyyy-MM")
#Logs and Zip output files
$Output = $PathToLogFiles + "\"+ $DateForOutputFileName + "_LogsHouseKeeping.txt"
$ZipFileOut = $PathToLogFiles + "\"+ $DateForOutputFileName + "_ArchivedLogs.zip"


#Get list of file to be processed by script
$ObjLogFilesToRemove = Get-ChildItem -Path $PathToLogFiles *.txt | `
where  {!$_.PSIsContainer -and $_.CreationTime.Date.Year -eq $ListLogsFromYear -and $_.CreationTime.Date.Month -eq $ListLogsFromMonth}

#Add header into HouseKeeping log file
"Action;Object;Status" | Add-Content $Output

#Compress and remove file
ForEach ($ItemFile in $ObjLogFilesToRemove)
{
	Try {
		Compress-Archive -Path $ItemFile.FullName  -DestinationPath $ZipFileOut -Update -Confirm:$false
		Write-Host "Zipping file:" $ItemFile.FullName
		"FileCompressed;" + $ItemFile.FullName + ";OK" | Add-Content $Output
		Remove-Item -Path $ItemFile.FullName -Force -Confirm:$false
		"FileRemoved;" + $ItemFile.FullName + ";OK" | Add-Content $Output
	}

	Catch {
		"FileOperationFailed;" + $ItemFile.FullName + ";NOK" | Add-Content $Output
		$_.Exception.Message | Add-Content $Output
		$Error.Clear()
	}
}


