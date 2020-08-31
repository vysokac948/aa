
##########################################################################
#    This script checking status of services and HW in the server.       #
########################################################################## 
#    File Name     :  AA_EventLogInfo.ps1                                #
#    Author        :  Petr Vysokomenský                                  #
#    Company       :  Accelapps, s.r.o.                                  #
#    Created       :  09.3.2020                                          #
#    Last Modified :  09.3.2020                                          #
#    Version       :  1.0                                                #
##########################################################################


$CompArr = "d4769"  
$LogNames = @("Application")
$ExportFolder = "C:\Accelapps Insights\EventLog\ApplicationLog\"
$el_c = @()   #consolidated error log
$now = get-date


function GetUserName {
  param (
  $sid
  )
  
  $objSid = New-Object System.Security.Principal.SecurityIdentifier($sid)
  $user = $objSid.Translate([System.Security.Principal.NTAccount])
  $user
}


$startdate=$now.adddays(-1)
$ExportFile=$ExportFolder + "aad4769SystemLog" + ".csv" 



foreach($comp in $CompArr)
{
  foreach($log in $LogNames)
  {
 
    Write-Host Processing $comp\$log
    $el = Get-WinEvent -FilterHashtable @{LogName=$LogNames; StartTime=(Get-Date).AddHours(-24); Level=1,2,3} | 
    Select-Object @{N='TimeCreated';E={$_.TimeCreated.ToString("yyyy-MM-dd hh:mm:ss") -replace ('"','')}},
    @{N='LevelDisplayName';E={$_.LevelDisplayName -replace ('"','')}}, 
    @{N='UserName';E={GetUserName $_.UserId -replace ('"','')}}, 
    @{N='ComputerName';E={$_.MachineName -replace ('"','')}}, 
    @{N='ProviderName';E={$_.ProviderName -replace ('"','')}},
    @{N='Id';E={$_.Id -replace ('"','')}},
    @{N='Message';E={$_.Message -replace ('"','')}}
    $el_c += $el  #consolidating
  }
  }


$el_sorted = $el_c | Sort-Object TimeCreated   
Write-Host Exporting to $ExportFile

$el_sorted  | Export-CSV -Encoding UTF8 $ExportFile -NoTypeInfo
Write-Host Done!

    