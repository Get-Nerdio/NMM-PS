function Test-ResponseSchema {
    <#
    .SYNOPSIS
        Validates API response against swagger schema definition.
    .DESCRIPTION
        Compares the properties in an API response against the expected
        properties defined in the swagger schema. Reports missing and
        extra properties.
    .PARAMETER Response
        The API response to validate.
    .PARAMETER SwaggerSchema
        The swagger schema definition (from Get-SwaggerSchema).
    .PARAMETER ApiVersion
        API version for loading swagger file. Default is 'v1'.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Response,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $SwaggerSchema,

        [Parameter()]
        [ValidateSet('v1', 'v1-beta')]
        [string]$ApiVersion = 'v1'
    )

    $result = [PSCustomObject]@{
        IsValid          = $true
        TotalExpected    = 0
        TotalFound       = 0
        MatchingProps    = @()
        MissingProps     = @()
        ExtraProps       = @()
        Message          = ''
    }

    # Handle null response
    if ($null -eq $Response) {
        $result.IsValid = $false
        $result.Message = 'Response is null'
        return $result
    }

    # Handle null schema
    if ($null -eq $SwaggerSchema) {
        $result.Message = 'No swagger schema available for validation'
        return $result
    }

    # Get response properties from first item
    $responseItems = @($Response)
    if ($responseItems.Count -eq 0) {
        $result.Message = 'Response is empty'
        return $result
    }

    $responseProps = @($responseItems[0].PSObject.Properties.Name)

    # Get expected properties from schema
    $expectedProps = @()

    # Load swagger for resolving refs
    $moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    $swaggerFile = Join-Path $moduleRoot ".swagger" "$ApiVersion.json"
    $swagger = $null

    if (Test-Path $swaggerFile) {
        $swagger = Get-Content $swaggerFile -Raw | ConvertFrom-Json -AsHashtable
    }

    # Extract properties from schema
    if ($SwaggerSchema.ResponseSchema) {
        $schema = $SwaggerSchema.ResponseSchema

        # Handle array responses
        if ($schema.type -eq 'array' -and $schema.items) {
            $itemSchema = $schema.items
            if ($itemSchema.'$ref' -and $swagger) {
                $itemSchema = Resolve-SwaggerRef -Swagger $swagger -Ref $itemSchema.'$ref'
            }
            if ($itemSchema.properties) {
                $expectedProps = @($itemSchema.properties.Keys)
            }
        }
        # Handle object responses
        elseif ($schema.properties) {
            $expectedProps = @($schema.properties.Keys)
        }
        # Handle $ref at root
        elseif ($schema.'$ref' -and $swagger) {
            $resolved = Resolve-SwaggerRef -Swagger $swagger -Ref $schema.'$ref'
            if ($resolved.properties) {
                $expectedProps = @($resolved.properties.Keys)
            }
        }
    }

    # If we couldn't extract expected props, try response example
    if ($expectedProps.Count -eq 0 -and $SwaggerSchema.ResponseExample) {
        $example = $SwaggerSchema.ResponseExample
        if ($example -is [array] -and $example.Count -gt 0) {
            $expectedProps = @($example[0].PSObject.Properties.Name)
        }
        elseif ($example -is [hashtable]) {
            $expectedProps = @($example.Keys)
        }
    }

    $result.TotalExpected = $expectedProps.Count
    $result.TotalFound = $responseProps.Count

    # Compare properties
    $result.MatchingProps = @($responseProps | Where-Object { $_ -in $expectedProps })
    $result.MissingProps = @($expectedProps | Where-Object { $_ -notin $responseProps })
    $result.ExtraProps = @($responseProps | Where-Object { $_ -notin $expectedProps })

    # Determine validity (missing props = fail, extra props = warning)
    if ($result.MissingProps.Count -gt 0) {
        $result.IsValid = $false
        $result.Message = "Missing $($result.MissingProps.Count) expected properties: $($result.MissingProps -join ', ')"
    }
    elseif ($result.ExtraProps.Count -gt 0) {
        $result.Message = "Found $($result.ExtraProps.Count) extra properties not in schema: $($result.ExtraProps -join ', ')"
    }
    else {
        $result.Message = "All $($result.TotalExpected) expected properties found"
    }

    return $result
}

function Format-SchemaValidation {
    <#
    .SYNOPSIS
        Formats schema validation results for console output.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $ValidationResult
    )

    $lines = @()

    if ($ValidationResult.IsValid) {
        $lines += "  Schema: VALID ($($ValidationResult.MatchingProps.Count)/$($ValidationResult.TotalExpected) properties)"
    }
    else {
        $lines += "  Schema: INVALID"
        if ($ValidationResult.MissingProps.Count -gt 0) {
            $lines += "    Missing: $($ValidationResult.MissingProps -join ', ')"
        }
    }

    if ($ValidationResult.ExtraProps.Count -gt 0) {
        $lines += "    Extra: $($ValidationResult.ExtraProps -join ', ')"
    }

    return $lines -join "`n"
}
