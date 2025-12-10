function Invoke-NMMReport {
    <#
    .SYNOPSIS
        Generate pre-built HTML reports for NMM accounts.
    .DESCRIPTION
        Invoke-NMMReport provides ready-to-use report templates that automatically fetch
        data from multiple NMM API endpoints and generate comprehensive HTML reports.

        When called without -ReportType, displays an interactive menu for report selection.
        When called with -ReportType, generates the report directly (suitable for automation).
    .PARAMETER ReportType
        The type of report to generate. Available types:
        - AccountOverview: Host pools, session hosts, images, and users
        - DeviceInventory: Intune devices with compliance, hardware, and apps
        - SecurityCompliance: Device compliance, backup status, and users
        - Infrastructure: Complete AVD infrastructure configuration

        If not specified, displays an interactive selection menu.
    .PARAMETER AccountId
        The NMM account ID to generate the report for.
    .PARAMETER OutputPath
        Path for the output HTML file. Defaults to ./NMM-{ReportType}_{timestamp}.html
    .PARAMETER OpenInBrowser
        Automatically open the generated report in the default browser.
    .PARAMETER Theme
        Report theme: 'light' (default) or 'dark'.
    .EXAMPLE
        Invoke-NMMReport -AccountId 67

        Shows interactive menu to select a report type, then generates the selected report.
    .EXAMPLE
        Invoke-NMMReport -ReportType AccountOverview -AccountId 67 -OpenInBrowser

        Generates an Account Overview report and opens it in the browser.
    .EXAMPLE
        Invoke-NMMReport -ReportType SecurityCompliance -AccountId 67 -Theme dark -OutputPath "./reports/security.html"

        Generates a Security Compliance report with dark theme to a custom path.
    .NOTES
        Pre-built reports are defined in Private/Data/PrebuiltReports.json
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet('AccountOverview', 'DeviceInventory', 'SecurityCompliance', 'Infrastructure')]
        [string]$ReportType,

        [Parameter(Mandatory = $true)]
        [int]$AccountId,

        [Parameter()]
        [string]$OutputPath,

        [Parameter()]
        [switch]$OpenInBrowser,

        [Parameter()]
        [ValidateSet('light', 'dark')]
        [string]$Theme = 'light'
    )

    begin {
        # Load report definitions
        $configPath = Join-Path $PSScriptRoot "../../Private/Data/PrebuiltReports.json"
        if (-not (Test-Path $configPath)) {
            throw "PrebuiltReports.json not found at: $configPath"
        }

        $reportDefinitions = Get-Content $configPath -Raw | ConvertFrom-Json
        $reportTypes = @($reportDefinitions.PSObject.Properties.Name)
    }

    process {
        # Interactive menu if no ReportType specified
        if (-not $ReportType) {
            Write-Host "`n" -NoNewline
            Write-Host "  NMM Pre-built Reports" -ForegroundColor Cyan
            Write-Host "  " + ("=" * 40) -ForegroundColor DarkGray
            Write-Host ""

            for ($i = 0; $i -lt $reportTypes.Count; $i++) {
                $type = $reportTypes[$i]
                $def = $reportDefinitions.$type
                Write-Host "  [$($i + 1)] " -ForegroundColor Yellow -NoNewline
                Write-Host "$type" -ForegroundColor White
                Write-Host "      $($def.subtitle)" -ForegroundColor DarkGray
            }

            Write-Host ""
            Write-Host "  [0] Cancel" -ForegroundColor DarkGray
            Write-Host ""

            $selection = Read-Host "  Select report type (1-$($reportTypes.Count))"

            if ($selection -eq '0' -or [string]::IsNullOrWhiteSpace($selection)) {
                Write-Host "  Cancelled." -ForegroundColor Yellow
                return
            }

            $index = [int]$selection - 1
            if ($index -lt 0 -or $index -ge $reportTypes.Count) {
                Write-Error "Invalid selection. Please enter a number between 1 and $($reportTypes.Count)."
                return
            }

            $ReportType = $reportTypes[$index]
            Write-Host ""
            Write-Host "  Selected: $ReportType" -ForegroundColor Green
            Write-Host ""
        }

        # Get report definition
        $reportDef = $reportDefinitions.$ReportType
        if (-not $reportDef) {
            throw "Report type '$ReportType' not found in configuration."
        }

        # Set default output path
        if (-not $OutputPath) {
            $timestamp = Get-Date -Format 'yyyy-MM-dd_HHmm'
            $OutputPath = "./NMM-${ReportType}_${timestamp}.html"
        }

        # Initialize report builder
        Write-Host "Generating $($reportDef.title)..." -ForegroundColor Cyan
        Write-Host ""

        $reportParams = @{
            Title    = $reportDef.title
            Subtitle = $reportDef.subtitle
            Theme    = $Theme
        }
        $report = New-NMMReport @reportParams

        # Process each section
        $sectionCount = $reportDef.sections.Count
        $currentSection = 0

        foreach ($section in $reportDef.sections) {
            $currentSection++
            $percentComplete = [math]::Round(($currentSection / $sectionCount) * 100)

            Write-Progress -Activity "Generating Report" -Status "Fetching: $($section.title)" -PercentComplete $percentComplete
            Write-Host "  [$currentSection/$sectionCount] Fetching $($section.title)..." -ForegroundColor Gray

            try {
                # Fetch data using the specified function
                $functionName = $section.function
                $data = $null

                # Handle functions that need special context
                switch ($section.functionRequiresContext) {
                    'Device' {
                        # Get all devices first, then fetch detail for each
                        $devices = Get-NMMDevice -AccountId $AccountId
                        if ($devices) {
                            $allData = [System.Collections.Generic.List[object]]::new()
                            foreach ($device in $devices) {
                                try {
                                    $deviceData = & $functionName -AccountId $AccountId -DeviceId $device.id -ErrorAction SilentlyContinue
                                    if ($deviceData) {
                                        # Add device name for context (suppress output)
                                        foreach ($item in @($deviceData)) {
                                            $item | Add-Member -NotePropertyName 'DeviceName' -NotePropertyValue $device.deviceName -Force
                                            $allData.Add($item)
                                        }
                                    }
                                }
                                catch {
                                    # Some devices may not have all data, continue silently
                                }
                            }
                            $data = $allData.ToArray()
                        }
                    }
                    'HostPool' {
                        # Get hosts from all host pools
                        $pools = Get-NMMHostPool -AccountId $AccountId
                        if ($pools) {
                            $allData = @()
                            foreach ($poolWrapper in $pools) {
                                # Unwrap pool data (Get-NMMHostPool wraps in {HostPool: {...}, Details: {...}})
                                $pool = if ($poolWrapper.HostPool) { $poolWrapper.HostPool } else { $poolWrapper }
                                try {
                                    $hostParams = @{
                                        AccountId      = $AccountId
                                        SubscriptionId = $pool.subscription
                                        ResourceGroup  = $pool.resourceGroup
                                        PoolName       = $pool.hostPoolName
                                    }
                                    $hostData = & $functionName @hostParams
                                    if ($hostData) {
                                        $allData += $hostData
                                    }
                                }
                                catch {
                                    # Some pools may have no hosts
                                }
                            }
                            $data = $allData
                        }
                    }
                    default {
                        # Standard function call - check for custom parameter name
                        $paramName = if ($section.parameterName) { $section.parameterName } else { 'AccountId' }
                        $params = @{ $paramName = $AccountId }
                        $data = & $functionName @params
                    }
                }

                # Assign PSTypeName based on function for template matching
                $typeMapping = @{
                    'Get-NMMProtectedItem' = 'NMM.Backup'
                    'Get-NMMBackup'        = 'NMM.Backup'
                    'Get-NMMDevice'        = 'NMM.Device'
                    'Get-NMMUsers'         = 'NMM.User'
                    'Get-NMMUser'          = 'NMM.User'
                    'Get-NMMHostPool'      = 'NMM.HostPool'
                    'Get-NMMHost'          = 'NMM.Host'
                    'Get-NMMAccount'       = 'NMM.Account'
                    'Get-NMMDesktopImage'  = 'NMM.DesktopImage'
                    'Get-NMMImageTemplate' = 'NMM.DesktopImage'
                }
                if ($data -and $typeMapping.ContainsKey($functionName)) {
                    $typeName = $typeMapping[$functionName]
                    foreach ($item in @($data)) {
                        if ($item.PSObject.TypeNames[0] -ne $typeName) {
                            $item.PSObject.TypeNames.Insert(0, $typeName)
                        }
                    }
                }

                # Flatten wrapped data (e.g., Get-NMMHostPool returns {HostPool: {...}, Details: {...}})
                if ($data -and @($data).Count -gt 0) {
                    $firstItem = @($data)[0]
                    # Check if data is wrapped (has HostPool property with nested object)
                    if ($firstItem.PSObject.Properties.Name -contains 'HostPool' -and
                        $firstItem.HostPool -is [PSCustomObject]) {
                        $data = $data | ForEach-Object { $_.HostPool }
                    }

                    # Flatten nested array properties to summaries (for table display)
                    $data = $data | ForEach-Object {
                        $item = $_
                        foreach ($prop in $item.PSObject.Properties) {
                            if ($prop.Value -is [System.Array] -and $prop.Value.Count -gt 0) {
                                # Check if array of objects
                                if ($prop.Value[0] -is [PSCustomObject] -or $prop.Value[0] -is [hashtable]) {
                                    # Summarize: count items, or extract key field if available
                                    if ($prop.Value[0].PSObject.Properties.Name -contains 'state') {
                                        # Compliance states - group by state
                                        $grouped = $prop.Value | Group-Object state
                                        $summary = ($grouped | ForEach-Object { "$($_.Count) $($_.Name)" }) -join ', '
                                        $item | Add-Member -NotePropertyName $prop.Name -NotePropertyValue $summary -Force
                                    }
                                    elseif ($prop.Value[0].PSObject.Properties.Name -contains 'displayName') {
                                        # Apps - show count
                                        $item | Add-Member -NotePropertyName $prop.Name -NotePropertyValue "$($prop.Value.Count) items" -Force
                                    }
                                    else {
                                        # Generic: show count
                                        $item | Add-Member -NotePropertyName $prop.Name -NotePropertyValue "$($prop.Value.Count) items" -Force
                                    }
                                }
                                else {
                                    # Array of primitives - join as string
                                    $item | Add-Member -NotePropertyName $prop.Name -NotePropertyValue ($prop.Value -join ', ') -Force
                                }
                            }
                        }
                        $item
                    }
                }

                # Add section to report
                $sectionParams = @{
                    Title       = $section.title
                    Description = $section.description
                    Data        = $data
                    PassThru    = $true
                }

                if ($section.showChart -and $data -and @($data).Count -gt 0) {
                    $sectionParams['ShowChart'] = $true
                    $sectionParams['ChartType'] = $section.chartType

                    if ($section.chartConfig) {
                        $sectionParams['ChartConfig'] = @{
                            groupField = $section.chartConfig.groupField
                        }
                    }
                }

                $report = $report | Add-NMMReportSection @sectionParams

                $itemCount = if ($data) { @($data).Count } else { 0 }
                Write-Host "      Retrieved $itemCount items" -ForegroundColor DarkGray
            }
            catch {
                Write-Warning "Failed to fetch $($section.title): $_"
                # Add empty section with error note
                $report = $report | Add-NMMReportSection -Title $section.title -Description "Error: $_" -Data @() -PassThru
            }
        }

        Write-Progress -Activity "Generating Report" -Completed

        # Export report
        Write-Host ""
        Write-Host "Exporting report..." -ForegroundColor Cyan

        $exportParams = @{
            OutputPath = $OutputPath
        }

        if ($OpenInBrowser) {
            $exportParams['OpenInBrowser'] = $true
        }

        $result = $report | Export-NMMReport @exportParams

        Write-Host ""
        Write-Host "Report generated successfully!" -ForegroundColor Green
        Write-Host "  Path: $($result.Path)" -ForegroundColor White
        Write-Host "  Sections: $($result.SectionCount)" -ForegroundColor DarkGray
        Write-Host "  Generated: $($result.GeneratedAt)" -ForegroundColor DarkGray
        Write-Host ""

        return $result
    }
}
