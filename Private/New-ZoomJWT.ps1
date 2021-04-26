function ConvertTo-Base64Url
{
    [CmdletBinding(DefaultParameterSetName = "Default")]
    Param
    (
        [Parameter(Mandatory        = $true,
                  ValueFromPipeline = $true,
                  ParameterSetName  = "Default")]
        [ValidateNotNullOrEmpty()]
        [String]$Url,

        [Parameter(Mandatory         = $true,
                   ValueFromPipeline = $true,
                   ParameterSetName  = "ByteArray")]
        [Byte[]]$Bytes
    )


    if ($Url)
    {
        $bytes = [Text.Encoding]::UTF8.GetBytes($Url)
    }


    # https://base64.guru/standards/base64url
    # Basically, replace a couple characters so they're web safe, and remove padding
    $string = [Convert]::ToBase64String($bytes).Replace("+", "-").Replace("/", "_").Replace("=", "")
    $string
}

function New-ZoomJWT
{
    [CmdletBinding()]
    Param
    (
        [ValidateRange(1, [Int32]::MaxValue)]
        [Int32]$SecondsToExpire = 30,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$APIKey,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$APISecret
    )


    # https://marketplace.zoom.us/docs/guides/auth/jwt
    # https://jwt.io/introduction
    # TLDR:
    # Token     = header.payload.signature

    # Where:
    # Header    = base64url(header)
    # Payload   = base64url(payload)
    # Signature = hmacsha256("base64url(header).base64url(payload)")
    # hmacsha256 uses the APISecret as the key

    $header =
    @{
        alg = "HS256"
        typ = "JWT"
    } | ConvertTo-Json | ConvertTo-Base64Url

    $payload =
    @{
        iss = $APIKey
        exp = [DateTimeOffset]::Now.AddSeconds($SecondsToExpire).ToUnixTimeSeconds()
    } | ConvertTo-Json | ConvertTo-Base64Url

    $key        = [Text.Encoding]::UTF8.GetBytes($APISecret)
    $hmacsha256 = [System.Security.Cryptography.HMACSHA256]::new($key)
    $signature  = , $hmacsha256.ComputeHash([Text.Encoding]::UTF8.GetBytes("$header.$payload")) | ConvertTo-Base64Url

    
    # Finally, the JWT - literally the 3 parts seperated by a period
    $token = "$header.$payload.$signature"
    $token
}
