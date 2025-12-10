function Get-SwaggerSchema {
    <#
    .SYNOPSIS
        Retrieves the schema for an API endpoint from swagger files.
    .DESCRIPTION
        Parses the swagger JSON files to find endpoint definitions and extract
        response schemas. Resolves $ref references to component schemas.
    .PARAMETER SwaggerPath
        The API path to look up (e.g., "/rest-api/v1/accounts/{accountId}/host-pool")
    .PARAMETER Method
        HTTP method (GET, POST, PUT, DELETE). Default is GET.
    .PARAMETER ApiVersion
        API version: 'v1' or 'v1-beta'. Default is 'v1'.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SwaggerPath,

        [Parameter()]
        [ValidateSet('GET', 'POST', 'PUT', 'DELETE', 'PATCH')]
        [string]$Method = 'GET',

        [Parameter()]
        [ValidateSet('v1', 'v1-beta')]
        [string]$ApiVersion = 'v1'
    )

    # Determine swagger file path
    $moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    $swaggerFile = Join-Path $moduleRoot ".swagger" "$ApiVersion.json"

    if (-not (Test-Path $swaggerFile)) {
        Write-Warning "Swagger file not found: $swaggerFile"
        return $null
    }

    # Load and parse swagger JSON
    $swagger = Get-Content $swaggerFile -Raw | ConvertFrom-Json -AsHashtable

    # Normalize path for lookup (swagger uses lowercase method keys)
    $methodKey = $Method.ToLower()

    # Find the endpoint in paths
    $pathEntry = $null
    foreach ($path in $swagger.paths.Keys) {
        # Normalize both paths for comparison (handle parameter placeholders)
        $normalizedSwaggerPath = $path -replace '\{[^}]+\}', '{param}'
        $normalizedInputPath = $SwaggerPath -replace '\{[^}]+\}', '{param}'

        if ($normalizedSwaggerPath -eq $normalizedInputPath) {
            $pathEntry = $swagger.paths[$path]
            break
        }
    }

    if (-not $pathEntry) {
        Write-Warning "Endpoint not found in swagger: $SwaggerPath"
        return $null
    }

    # Get the method definition
    $methodDef = $pathEntry[$methodKey]
    if (-not $methodDef) {
        Write-Warning "Method $Method not found for endpoint: $SwaggerPath"
        return $null
    }

    # Extract response schema (typically from 200 response)
    $responseSchema = $null
    $responses = $methodDef.responses

    if ($responses.'200'.content.'application/json'.schema) {
        $responseSchema = $responses.'200'.content.'application/json'.schema
    }
    elseif ($responses.'200'.content.'text/plain'.schema) {
        $responseSchema = $responses.'200'.content.'text/plain'.schema
    }

    # Resolve $ref if present
    if ($responseSchema.'$ref') {
        $responseSchema = Resolve-SwaggerRef -Swagger $swagger -Ref $responseSchema.'$ref'
    }

    # Extract request body schema if POST/PUT
    $requestSchema = $null
    if ($methodDef.requestBody.content.'application/json'.schema) {
        $requestSchema = $methodDef.requestBody.content.'application/json'.schema
        if ($requestSchema.'$ref') {
            $requestSchema = Resolve-SwaggerRef -Swagger $swagger -Ref $requestSchema.'$ref'
        }
    }

    # Build result object
    return [PSCustomObject]@{
        Path            = $SwaggerPath
        Method          = $Method
        Summary         = $methodDef.summary
        Description     = $methodDef.description
        Tags            = $methodDef.tags
        Parameters      = $methodDef.parameters
        RequestSchema   = $requestSchema
        ResponseSchema  = $responseSchema
        ResponseExample = $responses.'200'.content.'application/json'.example
    }
}

function Resolve-SwaggerRef {
    <#
    .SYNOPSIS
        Resolves a $ref reference in swagger to its actual schema definition.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Swagger,

        [Parameter(Mandatory = $true)]
        [string]$Ref
    )

    # Parse ref path (e.g., "#/components/schemas/AccountModel")
    $refPath = $Ref -replace '^#/', '' -split '/'

    $current = $Swagger
    foreach ($segment in $refPath) {
        if ($current -is [hashtable] -and $current.ContainsKey($segment)) {
            $current = $current[$segment]
        }
        else {
            Write-Warning "Could not resolve ref segment: $segment in $Ref"
            return $null
        }
    }

    return $current
}

function Get-SchemaProperties {
    <#
    .SYNOPSIS
        Extracts all property names from a swagger schema, including nested properties.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Schema,

        [Parameter()]
        [hashtable]$Swagger,

        [Parameter()]
        [string]$Prefix = ''
    )

    $properties = @()

    if (-not $Schema) {
        return $properties
    }

    # Handle $ref
    if ($Schema.'$ref' -and $Swagger) {
        $Schema = Resolve-SwaggerRef -Swagger $Swagger -Ref $Schema.'$ref'
    }

    # Handle array type
    if ($Schema.type -eq 'array' -and $Schema.items) {
        $itemSchema = $Schema.items
        if ($itemSchema.'$ref' -and $Swagger) {
            $itemSchema = Resolve-SwaggerRef -Swagger $Swagger -Ref $itemSchema.'$ref'
        }
        if ($itemSchema.properties) {
            foreach ($propName in $itemSchema.properties.Keys) {
                $fullName = if ($Prefix) { "$Prefix.$propName" } else { $propName }
                $properties += $fullName
            }
        }
        return $properties
    }

    # Handle object type with properties
    if ($Schema.properties) {
        foreach ($propName in $Schema.properties.Keys) {
            $fullName = if ($Prefix) { "$Prefix.$propName" } else { $propName }
            $properties += $fullName
        }
    }

    # Handle allOf (combined schemas)
    if ($Schema.allOf) {
        foreach ($subSchema in $Schema.allOf) {
            $properties += Get-SchemaProperties -Schema $subSchema -Swagger $Swagger -Prefix $Prefix
        }
    }

    return $properties | Select-Object -Unique
}
