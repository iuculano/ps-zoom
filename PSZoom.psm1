<#
    PSZoom
    Zoom API wrapper.
    

    Alex Iuculano, 2020
#>


# This is set for the scope of the module
Set-StrictMode -Version Latest


$ImportableFiles = Get-ChildItem @(
    "$PSScriptRoot\Public\*.ps1",
    "$PSScriptRoot\Private\*.ps1"
)

foreach ($file in $ImportableFiles)
{    
    # Dot source the files, public functions are exported in the manifest
    . $file.FullName
}
