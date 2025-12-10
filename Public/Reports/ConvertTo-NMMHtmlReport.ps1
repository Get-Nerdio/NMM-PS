function ConvertTo-NMMHtmlReport {
    <#
    .SYNOPSIS
        Converts pipeline data to a self-contained HTML report.

    .DESCRIPTION
        Simple pipeline converter that creates a single-section HTML report
        from piped data. Uses PSTypeName for automatic template selection.
        For multi-section reports, use New-NMMReport with Add-NMMReportSection.

    .PARAMETER InputObject
        The data to convert to HTML report. Accepts pipeline input.

    .PARAMETER Title
        Report title. Default is "NMM Report".

    .PARAMETER OutputPath
        Path to save the HTML file. If not specified, returns HTML string.

    .PARAMETER ShowChart
        Include a chart visualization based on template defaults.

    .PARAMETER ChartType
        Chart type: 'bar', 'pie', 'donut', 'line', or 'area'.
        Overrides the template default.

    .PARAMETER LogoUrl
        Optional URL for a custom logo (uses embedded base64 by default).

    .PARAMETER Theme
        Report theme: 'light' or 'dark'. Default is 'light'.

    .PARAMETER OpenInBrowser
        Open the generated report in the default browser.

    .EXAMPLE
        Get-NMMHostPool -AccountId 123 | ForEach-Object { $_.HostPool } |
            ConvertTo-NMMHtmlReport -Title "Host Pool Inventory" -OutputPath "./hostpools.html"

        Creates a host pool report and saves it to a file.

    .EXAMPLE
        Get-NMMDevice -AccountId 123 |
            ConvertTo-NMMHtmlReport -Title "Device Report" -ShowChart -ChartType pie -OpenInBrowser

        Creates a device report with a pie chart and opens it in the browser.

    .EXAMPLE
        $html = Get-NMMAccount | ConvertTo-NMMHtmlReport -Title "Accounts"

        Returns the HTML content as a string.

    .OUTPUTS
        If -OutputPath is specified: [PSCustomObject] with Path, Title, RecordCount.
        Otherwise: [string] - The HTML content.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object[]]$InputObject,

        [Parameter()]
        [string]$Title = "NMM Report",

        [Parameter()]
        [string]$OutputPath,

        [Parameter()]
        [switch]$ShowChart,

        [Parameter()]
        [ValidateSet('bar', 'pie', 'donut', 'line', 'area')]
        [string]$ChartType,

        [Parameter()]
        [string]$LogoUrl,

        [Parameter()]
        [ValidateSet('light', 'dark')]
        [string]$Theme = 'light',

        [Parameter()]
        [switch]$OpenInBrowser
    )

    begin {
        $allData = [System.Collections.Generic.List[object]]::new()
    }

    process {
        foreach ($item in $InputObject) {
            $allData.Add($item)
        }
    }

    end {
        if ($allData.Count -eq 0) {
            Write-Warning "No data to generate report."
            return
        }

        # Create report builder
        $report = [NMMReportBuilder]::new($Title)
        $report.Theme = $Theme

        # Set logo
        if ($LogoUrl) {
            $report.SetLogo('url', $LogoUrl)
        }
        else {
            $logoBase64 = Get-NMMReportAssets -AssetType 'Logo'
            $report.SetLogo('base64', $logoBase64)
        }

        # Get template for data
        $templateInfo = Get-NMMReportTemplate -InputObject $allData[0]

        # Create section
        $section = [NMMReportSection]::new($templateInfo.Template.displayName, $allData.ToArray())
        $section.ShowDataTable = $true
        $section.ShowChart = $ShowChart.IsPresent

        if ($ChartType) {
            $section.ChartType = $ChartType
        }
        elseif ($templateInfo.Template.defaultChart -and $templateInfo.Template.defaultChart.type) {
            $section.ChartType = $templateInfo.Template.defaultChart.type
        }

        if ($ShowChart -and $templateInfo.Template.defaultChart) {
            $section.ChartConfig = $templateInfo.Template.defaultChart
        }

        $report.AddSection($section)

        # Generate HTML
        $assets = Get-NMMReportAssets -AssetType 'All'
        $html = Get-NMMReportHtmlTemplate -ReportBuilder $report -Assets $assets

        if ($OutputPath) {
            # Resolve path
            $resolvedDir = Split-Path $OutputPath -Parent
            if ($resolvedDir -and -not (Test-Path $resolvedDir)) {
                New-Item -ItemType Directory -Path $resolvedDir -Force | Out-Null
            }

            $html | Out-File -FilePath $OutputPath -Encoding UTF8
            $resolvedPath = (Resolve-Path $OutputPath).Path

            Write-Verbose "Report saved to: $resolvedPath"

            if ($OpenInBrowser) {
                if ($IsWindows -or $PSVersionTable.PSEdition -eq 'Desktop') {
                    Start-Process $resolvedPath
                }
                elseif ($IsMacOS) {
                    & open $resolvedPath
                }
                elseif ($IsLinux) {
                    & xdg-open $resolvedPath
                }
            }

            return [PSCustomObject]@{
                Path        = $resolvedPath
                Title       = $Title
                RecordCount = $allData.Count
            }
        }
        else {
            return $html
        }
    }
}
