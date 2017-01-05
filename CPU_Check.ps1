<#
Author:Jonathan Parrilla
Created:5/20/2015
#>


Function Get-CPU-Status-From-Server
{
<#
.SYNOPSIS
This command will generate the top 10 processes running on a server.

.PARAMETER serverName
The name of the server you wish to obtain the processes for.

.EXAMPLE
Get-CPU-Status-From-Server -serverName $server


#>
    [cmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $True)]
        [String]$serverName
    )


    BEGIN
    {
        Write-Verbose "Get CPU Status from a Server function was called successfully." 
    }

    PROCESS
    {
        Write-Host "`nObtaining the top 10 CPU Processes for $serverName..."

        Write-Output "Obtaining the top 10  CPU Processes for $serverName"

        $output = Get-WmiObject -Class Win32_PerfFormattedData_PerfProc_Process -ComputerName $serverName |
        Where-Object {$_.Name -ne "_Total" -and $_.Name -ne "Idle"} | Sort-Object -Property Name | 
        Select-Object -Skip 1 -Property @{Name = "Process"; Expression = {$PSItem.Name}},
        @{Name = "CPU"; Expression = {([int]$PSItem.PercentProcessorTime)}},
        @{Name = "Process ID"; Expression = {[int]$PSItem.IDProcess}} | 
        Sort-Object -Property "CPU" -Descending | 
        Select -First 10 | 
        Format-Table -AutoSize 

        
        Write-Output $output | Out-Host

        Write-Verbose "Obtaining Total CPU Usage for $serverName"

        $CpuProcesses = get-counter -Counter "\Processor(_Total)\% Processor Time" -SampleInterval 2
 
        #$TotalCpuUsage = [Math]::round((($CpuProcesses.readings -split ":")[-1]),3) * 10

        $TotalCpuUsage = [Math]::Round((Get-Counter -ErrorAction Stop -Counter "\Processor(_Total)\% Processor Time" -ComputerName $serverName -MaxSamples 1).CounterSamples[0].CookedValue,2)

        Write-Host "Total CPU Usage on $serverName : $TotalCpuUsage%"

        Write-Output "Total CPU Usage on $serverName : $TotalCpuUsage%"
    }

    END
    {
        Write-Verbose "End of Get CPU Status from a server function."
    }

}