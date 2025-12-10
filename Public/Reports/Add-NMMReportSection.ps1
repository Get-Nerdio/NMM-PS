function Add-NMMReportSection {
    <#
    .SYNOPSIS
        Adds a section to an NMM report.

    .DESCRIPTION
        Adds data sections with optional charts to an existing report builder.
        Supports tables, charts, summaries, and custom HTML content.
        The template is automatically selected based on the data's PSTypeName.

    .PARAMETER ReportBuilder
        The report builder object from New-NMMReport.

    .PARAMETER Title
        Section title displayed in the section header.

    .PARAMETER Description
        Optional section description displayed below the header.

    .PARAMETER Data
        The data for this section. Should be an array of objects.

    .PARAMETER ShowChart
        Include a chart visualization based on the data.

    .PARAMETER ChartType
        Chart type: 'bar', 'pie', 'donut', 'line', or 'area'.
        Default is 'bar'.

    .PARAMETER ChartConfig
        Custom chart configuration hashtable. Overrides template defaults.

    .PARAMETER HideTable
        Hide the data table (show only chart if enabled).

    .PARAMETER CustomHtml
        Custom HTML content to include in the section.

    .PARAMETER PassThru
        Returns the report builder for pipeline chaining.

    .EXAMPLE
        $report | Add-NMMReportSection -Title "Host Pools" -Data $pools -ShowChart

        Adds a Host Pools section with a table and default chart.

    .EXAMPLE
        $report | Add-NMMReportSection -Title "Devices" -Data $devices -ShowChart -ChartType pie -PassThru |
                  Add-NMMReportSection -Title "Users" -Data $users

        Adds multiple sections using pipeline chaining.

    .EXAMPLE
        $report | Add-NMMReportSection -Title "Summary" -CustomHtml "<div class='alert alert-info'>All systems operational</div>"

        Adds a section with custom HTML content.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [NMMReportBuilder]$ReportBuilder,

        [Parameter(Mandatory = $true)]
        [string]$Title,

        [Parameter()]
        [string]$Description,

        [Parameter()]
        [object]$Data,

        [Parameter()]
        [switch]$ShowChart,

        [Parameter()]
        [ValidateSet('bar', 'pie', 'donut', 'line', 'area')]
        [string]$ChartType = 'bar',

        [Parameter()]
        [hashtable]$ChartConfig,

        [Parameter()]
        [switch]$HideTable,

        [Parameter()]
        [string]$CustomHtml,

        [Parameter()]
        [switch]$PassThru
    )

    process {
        $section = [NMMReportSection]::new()
        $section.Title = $Title
        $section.ShowDataTable = -not $HideTable.IsPresent
        $section.ShowChart = $ShowChart.IsPresent
        $section.ChartType = $ChartType

        if ($Description) { $section.Description = $Description }
        if ($Data) { $section.Data = @($Data) }
        if ($CustomHtml) { $section.CustomHtml = $CustomHtml }

        if ($ChartConfig) {
            $section.ChartConfig = $ChartConfig
        }
        elseif ($ShowChart -and $Data) {
            # Auto-configure chart from template
            $dataArray = @($Data)
            if ($dataArray.Count -gt 0) {
                $templateInfo = Get-NMMReportTemplate -InputObject $dataArray[0]
                if ($templateInfo.Template.defaultChart) {
                    $section.ChartConfig = $templateInfo.Template.defaultChart
                }
            }
        }

        $ReportBuilder.AddSection($section)

        if ($PassThru) {
            return $ReportBuilder
        }
    }
}
