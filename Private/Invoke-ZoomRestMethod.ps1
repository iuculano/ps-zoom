 <#
    .SYNOPSIS
    Wrapper for Invoke-RestMethod that takes care of some boilerplate.

    .PARAMETER Method
    Specifies the method used for the web request. 
    
    The acceptable values for this parameter are:
    GET, PATCH, PUT, POST, DELETE

    .PARAMETER Body
    Specifies the body of the request.

    .PARAMETER Url
    Specifies the Zoom endpoint to which the request is sent.

    .PARAMETER Token
    Specifies a Zoom JWT.

    .NOTES
    Invoke-ZoomRestMethod.ps1
    Alex Iuculano, 2021
 #>


 # Wrapper to help handle the exception that will be thrown when we're rate 
 # limited by the Snipe-IT API
function Invoke-InternalGuardedRestMethod
{
    param
    (
        [HashTable]$Params
    )


    try
    {
        Invoke-RestMethod @Params
    }

    catch
    {
        # Seems like the actual response is HTTP 405 despite the message that comes back? 
        # $response = $_.Exception.InnerException.InnerException.Response
        $response = $_.ErrorDetails | ConvertFrom-Json     
        if ($response.Messages -eq 429)
        {
            Write-Debug "Rate limited -> $($_.ErrorDetails)"
        }

        else
        {
            # Just bubble up any other exception
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
 }

function Invoke-ZoomRestMethod
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("GET", "PATCH", "PUT", "POST", "DELETE")]
        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method,

        [ValidateNotNull()]
        [HashTable]$Body,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Url,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Token
    )


    $wcArgs =
    @{
        Interval = 5000
        MaxTries = 12
    }

    $irmArgs =
    @{
        Uri     = $Url
        Method  = $Method
        Headers = 
        @{
            "Content-Type"  = "application/json"
            "Authorization" = "Bearer $Token"
        }
    }

    if ($Method -eq "GET")
    {
        $uri   = [System.UriBuilder]::new($Url)
        $query = [System.Web.HttpUtility]::ParseQueryString($uri.Query)
        

        # Need to call the API at least once as it'll return the total number
        # of items. At that point, need to handle paging since we can only get
        # 300 of them in one shot.

        # This also handles rate limiting and will retry on such a failure.
        $data  = @()
        $data += { Invoke-InternalGuardedRestMethod $irmArgs } | Wait-Command @wcArgs

        # https://marketplace.zoom.us/docs/api-reference/pagination
        # If 'next_page_token' is a non-empty string, there's sitll more data to retrieve
        if ($data.next_page_token)
        {
            # Set a couple defaults, these should exist in some capacity
            $query["page_count"]  ??= $data.page_count
            $query["page_number"] ??= $data.page_number
            $query["page_size"]   ??= $data.page_size            
            
            # page_count is only returned on the first call
            for ($i = 0; $i -lt ($data[0].page_count - 1); $i++)
            {
                # Set the next_page_token and advance the page number for each query
                $query["next_page_token"] = $data[$i].next_page_token                
                $query["page_number"]     = ([Int32]::Parse($query["page_number"]) + 1).ToString()
                $uri.Query                = $query.ToString()

                
                # Actually get and append additional paged data
                $irmArgs["Uri"] = $uri.Uri.ToString()
                $data          += { Invoke-InternalGuardedRestMethod $irmArgs } | Wait-Command @wcArgs        
            }

            [PSCustomObject]$data.users
            return
        }

        $data
    }

    else
    {
        if ($Body)
        {
            $irmArgs["Body"] = $Body | ConvertTo-Json
        }


        { Invoke-InternalGuardedRestMethod $irmArgs } | Wait-Command @wcArgs
    }
}
