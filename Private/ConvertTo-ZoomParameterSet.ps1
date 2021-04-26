function ConvertTo-ZoomParameterSet
{
    <#
        .SYNOPSIS
        Helper function to build query strings automatically based off a 
        function's parameter set.

        .PARAMETER PSCmdletVariable
        Specifies a cmdlet's PSCmdlet... variable.


        ConvertTo-ZoomParameterSet.ps1
        Alex Iuculano, 2018
    #>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCmdlet]$PSCmdletVariable,

        [Parameter(Mandatory = $true)]
        [ValidateSet("QueryString", "Submittable")]
        [String]$As
    )


    $boundParams = $PSCmdletVariable.MyInvocation.BoundParameters
    $query       = [System.Web.HttpUtility]::ParseQueryString("")

    foreach ($param in $boundParams.GetEnumerator())
    {
        $variable  = (Get-Variable $param.Key)
        $attribute = $variable.Attributes | Where-Object { 
            $_.TypeId.Name -contains "API$($As)Attribute"
        }

        # Just bail early if there's no attributes defined
        if (!$attribute)
        {
            continue
        }



        if ($attribute.APIParameterName)
        {
            # Direct specifications in the attribute are considered gospel
            $key = $attribute.APIParameterName
        }

        else
        {
            # If a parameter name isn't specified on the attribute, make 
            # the assumption that the parameter name is a direct match

            # Regex grabs the index of each capital letter. This is used
            # to determine where to inject the underscores for snake_case
            $string = $variable.Key | Select-String -Pattern "[A-Z]" -CaseSensitive -AllMatches
            $snake  = $variable.Key.ToLower()
            $offset = 0

            foreach ($match in $string.Matches)
            {
                # Skip the beginning, don't place an underscore at the start
                if ($match.Index -gt 0)
                {
                    # Need offset because we're making the string longer with each underscore
                    $snake   = $snake.Insert($match.Index + $offset, "_")
                    $offset += 1
                }
            }

            $key = $snake
        }    
    
        # If you need do any further data bending before passing it along...
        # For instance, transforming a DateTime string into a differnet format
        # that whatever underlying API expects
        switch ($variable.Value.GetType().Name)
        {
            { @("Boolean", "SwitchParameter") -contains $_ }
            {
                # Not sure if the query string is actually case sensitive?
                # This may not be needed, but I guess it's more 'correct'
                $value = $variable.Value.ToString().ToLower()
            }
        
            "DateTime"
            {
                # Snipe-IT expects hyphenated dates
                $value = ($variable.Value.ToShortDateString()).Replace("/", "-")
            }
        
            default
            {
                $value = $variable.Value
            }
        }


        # Almost done...
        $query[$key] = $value
    }


    # I thought about implicitly deciding based on the attribute, but I think
    # this is a little safer/better design...
    switch ($As)
    {
        "QueryString"
        {
            # Return just the query string, don't need the entire URI
            if ($query.Count)
            {
                "?$($query.ToString())"
                return
            }

            else
            {
                # Not sure if this better than nothing?
                return [String]::Empty
            }
        }

        "Submittable"
        {
            $table = @{ }
            foreach ($item in $query.GetEnumerator())
            {
                $table[$item.Key] = $item.Value
            }

            $table
        }
    }
}
