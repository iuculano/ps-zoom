#
# Module manifest for module 'PSZoom'
#

@{
# Script module or binary module file associated with this manifest.
RootModule        = 'PSZoom.psm1'

# Version number of this module.
ModuleVersion     = '0.0.1'

# ID used to uniquely identify this module
GUID              = 'e48caf80-0ea4-4e0c-848a-b832518f829f'

# Author of this module
Author            = 'Alex Iuculano'

# Company or vendor of this module
CompanyName       = ''

# Copyright statement for this module
Copyright         = '(c) Alex Iuculano. All rights reserved.'

# Description of the functionality provided by this module
Description       = 'Zoom API wrapper.'

# Minimum version of the PowerShell engine required by this module
PowerShellVersion = '7.0'

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 
@(
    "Get-ZoomUser"
)

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport   = @()

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport   = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        # Tags = @()

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        # ProjectUri = ''

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        # RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}
