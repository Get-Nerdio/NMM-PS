function Add-NMMTypeName {
    <#
    .SYNOPSIS
        Adds a PSTypeName to objects for report template matching.

    .DESCRIPTION
        Tags PSCustomObjects with an NMM.* type name so the report
        generator can automatically select the appropriate template.
        This is useful for custom data that doesn't come from NMM cmdlets.

    .PARAMETER InputObject
        The object(s) to tag with a PSTypeName.

    .PARAMETER TypeName
        The type name to add. Must start with 'NMM.' (e.g., 'NMM.HostPool').

    .EXAMPLE
        $customData | Add-NMMTypeName -TypeName 'NMM.HostPool'

        Tags custom data with the HostPool type for report generation.

    .EXAMPLE
        Get-NMMHostPool -AccountId 123 | ForEach-Object { $_.HostPool } | Add-NMMTypeName 'NMM.HostPool' | ConvertTo-NMMHtmlReport

        Manually tags host pool data and generates a report.

    .NOTES
        Most Get-NMM* cmdlets automatically add PSTypeNames, so this cmdlet
        is primarily for custom data or when manual tagging is needed.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object]$InputObject,

        [Parameter(Mandatory = $true, Position = 0)]
        [ValidatePattern('^NMM\.\w+$')]
        [string]$TypeName
    )

    process {
        # Insert type name at beginning of TypeNames collection
        $InputObject.PSObject.TypeNames.Insert(0, $TypeName)
        $InputObject
    }
}
