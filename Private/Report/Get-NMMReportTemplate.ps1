function Get-NMMReportTemplate {
    <#
    .SYNOPSIS
        Resolves the appropriate report template for given data based on PSTypeName.
    .DESCRIPTION
        Uses a registry pattern to match PSTypeName to predefined templates.
        Falls back to auto-detection for unregistered types.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$InputObject,

        [Parameter()]
        [string]$ForcedTypeName
    )

    # Load template registry
    $templatePath = Join-Path $PSScriptRoot '..\Data\ReportTemplates.json'
    $registry = Get-Content -Path $templatePath -Raw | ConvertFrom-Json -AsHashtable

    # Determine type name
    $typeName = if ($ForcedTypeName) {
        $ForcedTypeName
    }
    elseif ($InputObject.PSObject.TypeNames -and $InputObject.PSObject.TypeNames.Count -gt 0) {
        # Find first NMM.* type
        $InputObject.PSObject.TypeNames | Where-Object { $_ -like 'NMM.*' } | Select-Object -First 1
    }
    else {
        $null
    }

    # Resolve template
    $template = if ($typeName -and $registry.templates.ContainsKey($typeName)) {
        $registry.templates[$typeName]
    }
    else {
        $registry.templates['Default']
    }

    # If auto-detect, determine columns from object properties
    if ($template.autoDetectColumns) {
        $firstItem = if ($InputObject -is [array]) { $InputObject[0] } else { $InputObject }
        if ($firstItem) {
            $template.tableColumns = @($firstItem.PSObject.Properties.Name | Where-Object { $_ -notlike '_*' })
            $template.columnHeaders = @{}
            foreach ($prop in $template.tableColumns) {
                # Convert camelCase to Title Case
                $header = ($prop -creplace '([A-Z])', ' $1').Trim()
                $header = (Get-Culture).TextInfo.ToTitleCase($header.ToLower())
                $template.columnHeaders[$prop] = $header
            }
        }
    }

    return [PSCustomObject]@{
        TypeName = $typeName
        Template = $template
    }
}
