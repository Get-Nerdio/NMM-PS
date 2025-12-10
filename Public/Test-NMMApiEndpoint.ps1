function Test-NMMApiEndpoint {
    <#
    .SYNOPSIS
        Tests NMM-PS functions against their API endpoints and swagger schemas.
    .DESCRIPTION
        Automated testing framework that validates:
        - NMM-PS function output against raw API responses
        - Response properties against swagger schema definitions
        - Detects API changes and schema mismatches

        Requires authentication via Connect-NMMApi before running.
    .PARAMETER FunctionName
        Name of a specific function to test (e.g., "Get-NMMHostPool").
    .PARAMETER All
        Test all enabled endpoints in the configuration.
    .PARAMETER AccountId
        Account ID to use for testing endpoints that require it.
    .PARAMETER ValidateSchema
        Validate responses against swagger schema definitions.
    .PARAMETER ShowDiff
        Show detailed differences between function and raw API output.
    .PARAMETER ExportPath
        Path to export test results as JSON.
    .PARAMETER Quiet
        Suppress console output, only return results object.
    .EXAMPLE
        Test-NMMApiEndpoint -FunctionName "Get-NMMHostPool" -AccountId 67
    .EXAMPLE
        Test-NMMApiEndpoint -All -AccountId 67 -ValidateSchema
    .EXAMPLE
        Test-NMMApiEndpoint -All -AccountId 67 -ExportPath "./test-results.json"
    #>
    [CmdletBinding(DefaultParameterSetName = 'Single')]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Single')]
        [string]$FunctionName,

        [Parameter(Mandatory = $true, ParameterSetName = 'All')]
        [switch]$All,

        [Parameter()]
        [int]$AccountId,

        [Parameter()]
        [switch]$ValidateSchema,

        [Parameter()]
        [switch]$ShowDiff,

        [Parameter()]
        [string]$ExportPath,

        [Parameter()]
        [switch]$Quiet
    )

    # Verify authentication
    if (-not $script:CachedToken) {
        throw "Not authenticated. Run Connect-NMMApi first."
    }

    # Load endpoint configuration
    $configPath = Join-Path $PSScriptRoot ".." "Private" "Data" "TestEndpoints.json"
    if (-not (Test-Path $configPath)) {
        throw "TestEndpoints.json not found at: $configPath"
    }

    $config = Get-Content $configPath -Raw | ConvertFrom-Json

    # Determine which endpoints to test
    $endpointsToTest = @()
    if ($All) {
        $endpointsToTest = $config.endpoints.PSObject.Properties |
            Where-Object { $_.Value.enabled -eq $true } |
            ForEach-Object { $_.Name }
    }
    else {
        if (-not $config.endpoints.$FunctionName) {
            throw "Function '$FunctionName' not found in TestEndpoints.json"
        }
        $endpointsToTest = @($FunctionName)
    }

    # Results collection
    $results = [System.Collections.Generic.List[PSCustomObject]]::new()
    $totalTests = $endpointsToTest.Count
    $passCount = 0
    $warnCount = 0
    $failCount = 0

    # Console output header
    if (-not $Quiet) {
        Write-Host ""
        Write-Host "Testing NMM API Endpoints..." -ForegroundColor Cyan
        Write-Host ("=" * 60) -ForegroundColor DarkGray
        Write-Host ""
    }

    $testIndex = 0
    foreach ($funcName in $endpointsToTest) {
        $testIndex++
        $endpointConfig = $config.endpoints.$funcName
        $startTime = Get-Date

        $testResult = [PSCustomObject]@{
            FunctionName   = $funcName
            Endpoint       = $endpointConfig.endpoint
            Method         = $endpointConfig.method
            ApiVersion     = $endpointConfig.apiVersion
            Status         = 'Unknown'
            SchemaValid    = $null
            PropertyMatch  = $null
            FunctionOutput = $null
            RawApiOutput   = $null
            FunctionCount  = 0
            RawApiCount    = 0
            MissingProps   = @()
            ExtraProps     = @()
            ErrorMessage   = $null
            Duration       = $null
        }

        if (-not $Quiet) {
            Write-Host "[$testIndex/$totalTests] " -ForegroundColor DarkGray -NoNewline
            Write-Host $funcName -ForegroundColor White
            Write-Host "      Endpoint: $($endpointConfig.endpoint -replace '\{accountId\}', $AccountId)" -ForegroundColor DarkGray
        }

        try {
            # Check required parameters
            $requiredParams = $endpointConfig.requiredParams
            if ($requiredParams -contains 'AccountId' -and -not $AccountId) {
                throw "AccountId is required for this endpoint"
            }

            # Build function parameters
            $funcParams = @{}
            if ($requiredParams -contains 'AccountId') {
                $funcParams['AccountId'] = $AccountId
            }

            # Handle endpoints that need additional context
            switch ($endpointConfig.requiresContext) {
                'HostPool' {
                    # Get first host pool for context
                    $pools = (Get-NMMHostPool -AccountId $AccountId).HostPool
                    if ($pools -and $pools.Count -gt 0) {
                        $pool = $pools[0]
                        $funcParams['SubscriptionId'] = $pool.subscription
                        $funcParams['ResourceGroup'] = $pool.resourceGroup
                        $funcParams['PoolName'] = $pool.hostPoolName
                    }
                    else {
                        throw "No host pools available for context"
                    }
                }
                'Device' {
                    # Get first device for context
                    $devices = Get-NMMDevice -AccountId $AccountId
                    if ($devices -and @($devices).Count -gt 0) {
                        $funcParams['DeviceId'] = $devices[0].id
                    }
                    else {
                        throw "No devices available for context"
                    }
                }
                'User' {
                    # Get first user for context
                    $users = Get-NMMUsers -AccountId $AccountId
                    if ($users -and @($users).Count -gt 0) {
                        $funcParams['UserId'] = $users[0].entraId
                    }
                    else {
                        throw "No users available for context"
                    }
                }
                'DesktopImage' {
                    # Get first desktop image for context
                    $images = Get-NMMDesktopImage -AccountId $AccountId
                    if ($images -and @($images).Count -gt 0) {
                        $img = $images[0]
                        $funcParams['SubscriptionId'] = $img.subscriptionId
                        $funcParams['ResourceGroup'] = $img.resourceGroup
                        $funcParams['ImageName'] = $img.name
                    }
                    else {
                        throw "No desktop images available for context"
                    }
                }
                'ProtectedItem' {
                    # Get first protected item for context
                    $items = Get-NMMProtectedItem -AccountId $AccountId
                    if ($items -and @($items).Count -gt 0) {
                        $funcParams['ProtectedItemId'] = $items[0].protectedItemId
                    }
                    else {
                        throw "No protected items available for context"
                    }
                }
                'Group' {
                    # Groups require specific GroupId - skip for now
                    throw "Group context requires specific GroupId - test manually"
                }
                'Schedule' {
                    # Get first schedule for context
                    $schedules = Get-NMMSchedule -Scope Global
                    if ($schedules -and @($schedules).Count -gt 0) {
                        $funcParams['ScheduleId'] = $schedules[0].id
                        $funcParams['Scope'] = 'Global'
                    }
                    else {
                        throw "No schedules available for context"
                    }
                }
                'ScriptedAction' {
                    # Get first scripted action for context
                    $actions = Get-NMMScriptedAction -Scope Global
                    if ($actions -and @($actions).Count -gt 0) {
                        $funcParams['ScriptedActionId'] = $actions[0].id
                        $funcParams['Scope'] = 'Global'
                    }
                    else {
                        throw "No scripted actions available for context"
                    }
                }
            }

            # Add any extra function parameters from config
            if ($endpointConfig.functionParams) {
                $endpointConfig.functionParams.PSObject.Properties | ForEach-Object {
                    $value = $_.Value
                    # Replace placeholder values with actual values
                    if ($value -eq '{AccountId}') {
                        $value = $AccountId
                    }
                    $funcParams[$_.Name] = $value
                }
            }

            # Call the NMM-PS function
            $funcOutput = & $funcName @funcParams
            $testResult.FunctionOutput = $funcOutput
            $testResult.FunctionCount = @($funcOutput).Count

            # Build raw API endpoint - replace all placeholders with actual values
            $rawEndpoint = $endpointConfig.endpoint -replace '\{accountId\}', $AccountId
            if ($funcParams.ContainsKey('SubscriptionId')) {
                $rawEndpoint = $rawEndpoint -replace '\{subscriptionId\}', $funcParams['SubscriptionId']
            }
            if ($funcParams.ContainsKey('ResourceGroup')) {
                $rawEndpoint = $rawEndpoint -replace '\{resourceGroup\}', $funcParams['ResourceGroup']
            }
            if ($funcParams.ContainsKey('PoolName')) {
                $rawEndpoint = $rawEndpoint -replace '\{poolName\}', $funcParams['PoolName']
            }
            if ($funcParams.ContainsKey('DeviceId')) {
                $rawEndpoint = $rawEndpoint -replace '\{deviceId\}', $funcParams['DeviceId']
            }
            if ($funcParams.ContainsKey('UserId')) {
                $rawEndpoint = $rawEndpoint -replace '\{userId\}', $funcParams['UserId']
            }
            if ($funcParams.ContainsKey('ImageName')) {
                $rawEndpoint = $rawEndpoint -replace '\{imageName\}', $funcParams['ImageName']
            }
            if ($funcParams.ContainsKey('ProtectedItemId')) {
                $rawEndpoint = $rawEndpoint -replace '\{protectedItemId\}', $funcParams['ProtectedItemId']
            }
            if ($funcParams.ContainsKey('ScheduleId')) {
                $rawEndpoint = $rawEndpoint -replace '\{scheduleId\}', $funcParams['ScheduleId']
            }
            if ($funcParams.ContainsKey('ScriptedActionId')) {
                $rawEndpoint = $rawEndpoint -replace '\{scriptedActionId\}', $funcParams['ScriptedActionId']
            }

            # Call raw API
            $apiParams = @{
                Method     = $endpointConfig.method
                Endpoint   = $rawEndpoint
                ApiVersion = $endpointConfig.apiVersion
            }

            if ($endpointConfig.requestBody) {
                $apiParams['Body'] = $endpointConfig.requestBody
            }

            $rawOutput = Invoke-APIRequest @apiParams

            # Handle response wrapper
            if ($endpointConfig.responseWrapper -and $rawOutput.$($endpointConfig.responseWrapper)) {
                $rawOutput = $rawOutput.$($endpointConfig.responseWrapper)
            }

            $testResult.RawApiOutput = $rawOutput
            $testResult.RawApiCount = @($rawOutput).Count

            if (-not $Quiet) {
                Write-Host "      " -NoNewline
                Write-Host "[OK]" -ForegroundColor Green -NoNewline
                Write-Host " API Call: $($testResult.RawApiCount) items" -ForegroundColor Gray
            }

            # Compare outputs
            $comparison = Compare-ApiResponse -FunctionOutput $funcOutput -RawApiOutput $rawOutput
            $testResult.PropertyMatch = $comparison.AreEqual

            if ($comparison.Differences.Count -gt 0) {
                $testResult.MissingProps = @($comparison.Differences | Where-Object { $_.Type -eq 'MissingInFunction' }).Path
                $testResult.ExtraProps = @($comparison.Differences | Where-Object { $_.Type -eq 'ExtraInFunction' }).Path
            }

            # Schema validation
            if ($ValidateSchema) {
                $swaggerSchema = Get-SwaggerSchema -SwaggerPath $endpointConfig.swaggerPath -Method $endpointConfig.method -ApiVersion $endpointConfig.apiVersion
                $schemaResult = Test-ResponseSchema -Response $rawOutput -SwaggerSchema $swaggerSchema -ApiVersion $endpointConfig.apiVersion
                $testResult.SchemaValid = $schemaResult.IsValid

                if (-not $Quiet) {
                    if ($schemaResult.IsValid) {
                        Write-Host "      " -NoNewline
                        Write-Host "[OK]" -ForegroundColor Green -NoNewline
                        Write-Host " Schema: $($schemaResult.MatchingProps.Count)/$($schemaResult.TotalExpected) properties match" -ForegroundColor Gray
                    }
                    else {
                        Write-Host "      " -NoNewline
                        Write-Host "[WARN]" -ForegroundColor Yellow -NoNewline
                        Write-Host " Schema: $($schemaResult.Message)" -ForegroundColor Gray
                    }
                }
            }

            # Determine status
            if ($testResult.FunctionCount -eq $testResult.RawApiCount -and $testResult.PropertyMatch) {
                $testResult.Status = 'Pass'
                $passCount++
            }
            elseif ($testResult.MissingProps.Count -gt 0) {
                $testResult.Status = 'Warning'
                $warnCount++
            }
            else {
                $testResult.Status = 'Pass'
                $passCount++
            }

            if (-not $Quiet) {
                Write-Host "      " -NoNewline
                Write-Host "[OK]" -ForegroundColor Green -NoNewline
                Write-Host " Function: $($testResult.FunctionCount) items returned" -ForegroundColor Gray

                $statusColor = switch ($testResult.Status) {
                    'Pass' { 'Green' }
                    'Warning' { 'Yellow' }
                    'Fail' { 'Red' }
                    default { 'Gray' }
                }
                Write-Host "      Status: " -NoNewline
                Write-Host $testResult.Status.ToUpper() -ForegroundColor $statusColor
            }

            # Show diff if requested
            if ($ShowDiff -and $comparison.Differences.Count -gt 0) {
                Write-Host ""
                Write-Host "      Differences:" -ForegroundColor Yellow
                foreach ($diff in $comparison.Differences) {
                    Write-Host "        - $($diff.Path): $($diff.Type)" -ForegroundColor DarkGray
                }
            }
        }
        catch {
            $testResult.Status = 'Fail'
            $testResult.ErrorMessage = $_.Exception.Message
            $failCount++

            if (-not $Quiet) {
                Write-Host "      " -NoNewline
                Write-Host "[FAIL]" -ForegroundColor Red -NoNewline
                Write-Host " $($_.Exception.Message)" -ForegroundColor Gray
                Write-Host "      Status: " -NoNewline
                Write-Host "FAIL" -ForegroundColor Red
            }
        }

        $testResult.Duration = (Get-Date) - $startTime
        $results.Add($testResult)

        if (-not $Quiet) {
            Write-Host ""
        }
    }

    # Summary
    if (-not $Quiet) {
        Write-Host ("=" * 60) -ForegroundColor DarkGray
        Write-Host "Summary: " -NoNewline
        Write-Host "$passCount Pass" -ForegroundColor Green -NoNewline
        Write-Host " | " -NoNewline
        Write-Host "$warnCount Warning" -ForegroundColor Yellow -NoNewline
        Write-Host " | " -NoNewline
        Write-Host "$failCount Fail" -ForegroundColor Red
        Write-Host ("=" * 60) -ForegroundColor DarkGray
    }

    # Export to JSON if requested
    if ($ExportPath) {
        $exportData = @{
            TestRun      = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            TotalTests   = $totalTests
            PassCount    = $passCount
            WarningCount = $warnCount
            FailCount    = $failCount
            Results      = $results | ForEach-Object {
                @{
                    FunctionName  = $_.FunctionName
                    Endpoint      = $_.Endpoint
                    Method        = $_.Method
                    ApiVersion    = $_.ApiVersion
                    Status        = $_.Status
                    SchemaValid   = $_.SchemaValid
                    PropertyMatch = $_.PropertyMatch
                    FunctionCount = $_.FunctionCount
                    RawApiCount   = $_.RawApiCount
                    MissingProps  = $_.MissingProps
                    ExtraProps    = $_.ExtraProps
                    ErrorMessage  = $_.ErrorMessage
                    DurationMs    = $_.Duration.TotalMilliseconds
                }
            }
        }

        $exportData | ConvertTo-Json -Depth 10 | Out-File -FilePath $ExportPath -Encoding UTF8
        Write-Host ""
        Write-Host "Results exported to: $ExportPath" -ForegroundColor Cyan
    }

    return $results.ToArray()
}
