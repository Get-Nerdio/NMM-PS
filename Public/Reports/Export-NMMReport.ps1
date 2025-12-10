function Export-NMMReport {
    <#
    .SYNOPSIS
        Generates the final HTML report from a report builder.

    .DESCRIPTION
        Renders all sections into a self-contained HTML file with
        embedded CSS, JavaScript libraries (via CDN), and Nerdio branding.
        The generated report includes interactive tables (DataTables) and
        charts (ApexCharts).

    .PARAMETER ReportBuilder
        The report builder object with sections from New-NMMReport.

    .PARAMETER OutputPath
        Path to save the HTML file. Required unless using -ReturnHtml.

    .PARAMETER ReturnHtml
        Return HTML string instead of saving to file.

    .PARAMETER OpenInBrowser
        Open the generated report in the default browser after saving.

    .EXAMPLE
        $report | Export-NMMReport -OutputPath "./report.html"

        Exports the report to an HTML file.

    .EXAMPLE
        $report | Export-NMMReport -OutputPath "./report.html" -OpenInBrowser

        Exports and opens the report in the default browser.

    .EXAMPLE
        $html = $report | Export-NMMReport -ReturnHtml

        Returns the HTML content as a string.

    .OUTPUTS
        If -ReturnHtml: [string] - The HTML content.
        Otherwise: [PSCustomObject] - Report metadata with Path, Title, SectionCount, GeneratedAt.
    #>
    [CmdletBinding(DefaultParameterSetName = 'File')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [NMMReportBuilder]$ReportBuilder,

        [Parameter(Mandatory = $true, ParameterSetName = 'File')]
        [string]$OutputPath,

        [Parameter(Mandatory = $true, ParameterSetName = 'String')]
        [switch]$ReturnHtml,

        [Parameter(ParameterSetName = 'File')]
        [switch]$OpenInBrowser
    )

    process {
        # Get embedded assets
        $assets = Get-NMMReportAssets -AssetType 'All'

        # Build HTML
        $html = Get-NMMReportHtmlTemplate -ReportBuilder $ReportBuilder -Assets $assets

        if ($ReturnHtml) {
            return $html
        }

        # Resolve path
        $resolvedDir = Split-Path $OutputPath -Parent
        if ($resolvedDir -and -not (Test-Path $resolvedDir)) {
            New-Item -ItemType Directory -Path $resolvedDir -Force | Out-Null
        }

        # Save to file
        $html | Out-File -FilePath $OutputPath -Encoding UTF8
        $resolvedPath = (Resolve-Path $OutputPath).Path

        Write-Verbose "Report saved to: $resolvedPath"

        if ($OpenInBrowser) {
            Write-Verbose "Opening report in browser..."
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
            Path         = $resolvedPath
            Title        = $ReportBuilder.Title
            SectionCount = $ReportBuilder.Sections.Count
            GeneratedAt  = $ReportBuilder.GeneratedAt
        }
    }
}
