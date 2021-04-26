<#
    .SYNOPSIS
    Helper for retrying a command.
    
    .DESCRIPTION
    Helper for retrying a command or scriptblock. 
    
    This action can be useful for cases where polling for a short while may 
    be required to  determine the success of an action.

    .PARAMETER ScriptBlock
    Specifies the a Script Block to be executed.
    
    .PARAMETER Condition
    Specifies the condition to return on.
    By default, this will consider a truthful return.
    
    On condition success, returns the result of ScriptBlock.
    On condition failure, returns $null.
    
    .PARAMETER MaxTries
    Specifies the max number of attempts to make before failing.
    
    .PARAMETER Interval
    Specifies how long to wait between tries, in milliseconds.
    
    Note that if this is 0, the loop will spin freely.
    CPU usage will be unbound at this point.

    .EXAMPLE
    Waiting for a specific process:
    { Get-Process } | Wait-Command -Condition { $_.ProcessName -eq "Firefox" }

    Or:
    Wait-Command -ScriptBlock { Get-Process } -Condition { $_.ProcessName -eq "Firefox" }

    .NOTES
    Wait-Command.ps1
    Alex Iuculano, 2018
#>

function Wait-Command
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Position          = 1, 
                   ValueFromPipeline = $true, 
                   Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        [ScriptBlock]$ScriptBlock,
        
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [ScriptBlock]$Condition = { $true },    

        [ValidateRange(0, [Int32]::MaxValue)]
        [Int32]$MaxTries = 6,

        [ValidateRange(0, [Int32]::MaxValue)]
        [Int32]$Interval = 1000
    )

    
    $tries = 0
    while (++$tries -le $MaxTries)
    {        
        $result = $ScriptBlock.Invoke().Where($Condition)
        if ($result)
        {
            return $result
        }

        else 
        {
            # This can be pretty chatty
            Write-Verbose "Retrying in $Interval milliseconds. ($tries of $MaxTries)"

            if ($Interval -gt 0)
            {
                Start-Sleep -Milliseconds $Interval
            }            
        }    
    }

    if ($tries -ge $maxTries)
    {
        Write-Verbose "Giving up after $maxTries attempts."
        return $result
    }
}
