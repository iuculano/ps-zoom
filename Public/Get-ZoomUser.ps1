 <#
    .SYNOPSIS
    Gets one or more Zoom users.
    
    .PARAMETER Url
    Specifies the Zoom endpoint to which the request is sent.

    .PARAMETER Token
    Specifies a Zoom JWT.


    .NOTES
    Get-ZoomUser.ps1
    Alex Iuculano, 2021
 #>

function Get-ZoomUser
{
    [CmdletBinding(DefaultParameterSetName = "Default")]
    Param
    (
        [APIQueryStringAttribute("page_size")]
        [Parameter(ParameterSetName = "Default")]
        [ValidateRange(1, [Int32]::MaxValue)]
        [Int32]$Limit,

        [APIQueryStringAttribute()]
        [Parameter(ParameterSetName = "Default")]
        [ValidateSet("Active", "Inactive", "Pending")]
        [String]$Status,

        [APIQueryStringAttribute()]
        [Parameter(ParameterSetName = "Default")]
        [ValidateNotNullOrEmpty()]
        [String]$RoleId,

        [APIQueryStringAttribute()]
        [Parameter(ParameterSetName = "Default")]
        [ValidateSet("CustomAttributes", "HostKey")]
        [String]$IncludeFields,

        [Parameter(Mandatory         = $true,
                   ValueFromPipeline = $true,
                   ParameterSetName  = "Id")]
        [ValidateNotNullOrEmpty()]
        [String]$Id,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Url,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Token
    )


    Process
    {
        switch ($PSCmdlet.ParameterSetName)
        {
            "Default"
            {
                $endpoint  = "$Url/v2/users"
                $endpoint += ConvertTo-ZoomParameterSet $PSCmdlet -As "QueryString"
                break
            }

            "Id"
            {
                $endpoint = "$Url/v2/users/$Id"
                break
            }
        }
    

        $data = Invoke-ZoomRestMethod -Method "GET" -Url $endpoint -Token $Token
        foreach ($object in $data)
        {
            $object.PSObject.TypeNames.Insert(0, "axZoom.User")
            $object
        }
    }
}
