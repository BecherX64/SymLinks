<######################################################
#
# Author: Ivan Batis - ivan.bati@dxc.com
# Version: 0.1 [Script Description]
# Info: Simple script with some Parameters
#
# Usage: [scriptname].ps1 -PathToLogFiles [Config File Path] -Months [number of months]
#
#######################################################>

#Parameters
Param(
    [Parameter(Mandatory=$false)]
    [int]$Months = -1,
	[Parameter(Mandatory=$false)]
    [String]$PathToLogFiles = ".\Logs"

)

$error.clear()
$Date = get-date -format yyyy-MM-dd
$Time = get-date -format HH-mm

$Output = $PathToLogFiles + "\"+ $date + "_LogsHouseKeeping.log"

If ($Months -gt 0)
{
	$Months = $Months * -1
}


$ObjFilesToRemove = Get-ChildItem -Path $PathToLogFiles *.log | where  {!$_.PSIsContainer -and $_.CreationTime -lt (Get-Date).Date.AddMonths($Months)}

if ($ObjFilesToRemove.Count -gt 1)
{
	"LogFile;CreationTime;Action;Status" | Add-Content $Output

	ForEach ($LogFile in $ObjFilesToRemove)
	{
		Try {
			Remove-Item $LogFile
			$LogFile.FullName + ";" + $LogFile.CreationTime + ";Removed;OK" | Add-Content $Output
		}

		Catch {
			$_.Exception.Message
			$LogFile.FullName +";Removed;NOK" | Add-Content $Output
			$Error.Clear()
		}

	}
} Else {
	#No files to remove
}
