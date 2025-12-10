function Get-NMMReportHtmlTemplate {
    <#
    .SYNOPSIS
        Generates the complete HTML report from a report builder.
    .DESCRIPTION
        Renders all sections into a self-contained HTML document with
        embedded CSS, JavaScript libraries (via CDN), and Nerdio branding.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [NMMReportBuilder]$ReportBuilder,

        [Parameter(Mandatory = $true)]
        [hashtable]$Assets
    )

    $colors = $ReportBuilder.GetBrandColors()

    # Generate sections HTML
    $sectionsHtml = foreach ($section in ($ReportBuilder.Sections | Sort-Object Order)) {
        Get-NMMSectionHtml -Section $section -Colors $colors
    }

    # Logo handling
    $logoHtml = if ($ReportBuilder.LogoSource -eq 'url' -and $ReportBuilder.LogoData) {
        "<img src=`"$([System.Web.HttpUtility]::HtmlAttributeEncode($ReportBuilder.LogoData))`" alt=`"Logo`" class=`"nmm-logo`">"
    }
    elseif ($Assets.Logo) {
        "<img src=`"data:image/png;base64,$($Assets.Logo)`" alt=`"Nerdio`" class=`"nmm-logo`">"
    }
    else {
        ""
    }

    # Timestamp
    $timestampHtml = if ($ReportBuilder.IncludeTimestamp) {
        "<p class='text-white-50 mb-0 small'>Generated: $($ReportBuilder.GeneratedAt.ToString('yyyy-MM-dd HH:mm:ss'))</p>"
    }
    else { "" }

    # Subtitle
    $subtitleHtml = if ($ReportBuilder.Subtitle) {
        "<p class='lead mb-2'>$([System.Web.HttpUtility]::HtmlEncode($ReportBuilder.Subtitle))</p>"
    }
    else { "" }

    # Theme class
    $themeClass = if ($ReportBuilder.Theme -eq 'dark') { 'nmm-dark' } else { '' }

    return @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$([System.Web.HttpUtility]::HtmlEncode($ReportBuilder.Title))</title>

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- DataTables Bootstrap 5 -->
    <link href="https://cdn.datatables.net/1.13.7/css/dataTables.bootstrap5.min.css" rel="stylesheet">

    <!-- Poppins Font -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <style>
$($Assets.CSS)
    </style>
</head>
<body class="$themeClass">
    <header class="nmm-header">
        <div class="container">
            $logoHtml
            <h1>$([System.Web.HttpUtility]::HtmlEncode($ReportBuilder.Title))</h1>
            $subtitleHtml
            $timestampHtml
        </div>
    </header>

    <main class="container">
        $($sectionsHtml -join "`n")
    </main>

    <footer class="nmm-footer">
        <div class="container">
            <p>$([System.Web.HttpUtility]::HtmlEncode($ReportBuilder.FooterText))</p>
            <p class="text-muted small mb-0">Powered by NMM-PS Module | <a href="https://github.com/Get-Nerdio/NMM-PS" target="_blank" class="text-muted">GitHub</a></p>
        </div>
    </footer>

    <!-- Scripts -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.7/js/dataTables.bootstrap5.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>

    <script>
$($Assets.JavaScript)
    </script>
</body>
</html>
"@
}

function Get-NMMSectionHtml {
    <#
    .SYNOPSIS
        Generates HTML for a single report section.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [NMMReportSection]$Section,

        [Parameter(Mandatory = $true)]
        [hashtable]$Colors
    )

    $sectionId = "section-$($Section.Order)"
    $chartId = "chart-$($Section.Order)"

    # Description HTML
    $descriptionHtml = if ($Section.Description) {
        "<div class='nmm-section-description'>$([System.Web.HttpUtility]::HtmlEncode($Section.Description))</div>"
    }
    else { "" }

    # Chart HTML
    $chartHtml = ""
    $chartScript = ""
    if ($Section.ShowChart -and $Section.Data) {
        $chartData = Get-NMMChartData -Data $Section.Data -ChartType $Section.ChartType -ChartConfig $Section.ChartConfig
        if ($chartData) {
            $chartHtml = "<div id='$chartId' class='nmm-chart-container'></div>"
            $chartScript = @"
<script>
document.addEventListener('DOMContentLoaded', function() {
    initNMMChart('$chartId', $chartData);
});
</script>
"@
        }
    }

    # Table HTML
    $tableHtml = ""
    if ($Section.ShowDataTable -and $Section.Data) {
        $tableHtml = ConvertTo-NMMTableHtml -Data $Section.Data
    }

    # Custom HTML
    $customHtml = if ($Section.CustomHtml) { $Section.CustomHtml } else { "" }

    return @"
<section class="nmm-section" id="$sectionId">
    <div class="nmm-section-header">$([System.Web.HttpUtility]::HtmlEncode($Section.Title))</div>
    $descriptionHtml
    <div class="nmm-section-body">
        $chartHtml
        $tableHtml
        $customHtml
    </div>
</section>
$chartScript
"@
}

function ConvertTo-NMMTableHtml {
    <#
    .SYNOPSIS
        Converts data to an HTML table with DataTables support.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Data
    )

    if (-not $Data) { return "" }

    # Ensure array
    $dataArray = @($Data)
    if ($dataArray.Count -eq 0) { return "<p class='text-muted'>No data available.</p>" }

    # Get template for column configuration
    $templateInfo = Get-NMMReportTemplate -InputObject $dataArray[0]
    $template = $templateInfo.Template

    $columns = $template.tableColumns
    $headers = $template.columnHeaders

    # Build header row
    $headerCells = foreach ($col in $columns) {
        $headerText = if ($headers -and $headers.ContainsKey($col)) { $headers[$col] } else { $col }
        "<th>$([System.Web.HttpUtility]::HtmlEncode($headerText))</th>"
    }

    # Build data rows
    $dataRows = foreach ($item in $dataArray) {
        $cells = foreach ($col in $columns) {
            $value = $item.$col
            $displayValue = if ($null -eq $value) {
                '-'
            }
            elseif ($value -is [datetime]) {
                $value.ToString('yyyy-MM-dd HH:mm:ss')
            }
            elseif ($value -is [bool]) {
                if ($value) { '<span class="badge bg-success">Yes</span>' } else { '<span class="badge bg-secondary">No</span>' }
            }
            else {
                [System.Web.HttpUtility]::HtmlEncode($value.ToString())
            }
            "<td>$displayValue</td>"
        }
        "<tr>$($cells -join '')</tr>"
    }

    return @"
<div class="table-responsive">
    <table class="table table-hover nmm-table nmm-datatable">
        <thead>
            <tr>$($headerCells -join '')</tr>
        </thead>
        <tbody>
            $($dataRows -join "`n            ")
        </tbody>
    </table>
</div>
"@
}

function Get-NMMChartData {
    <#
    .SYNOPSIS
        Generates ApexCharts configuration JSON from data.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Data,

        [Parameter(Mandatory = $true)]
        [string]$ChartType,

        [Parameter()]
        [hashtable]$ChartConfig
    )

    $dataArray = @($Data)
    if ($dataArray.Count -eq 0) { return $null }

    # Get template for chart configuration
    $templateInfo = Get-NMMReportTemplate -InputObject $dataArray[0]
    $defaultChart = $templateInfo.Template.defaultChart

    # Merge with provided config
    $config = if ($ChartConfig -and $ChartConfig.Count -gt 0) { $ChartConfig } else { $defaultChart }

    if (-not $config -or -not $config.enabled) { return $null }

    $chartTitle = if ($config.title) { $config.title } else { "" }

    switch ($ChartType) {
        { $_ -in @('pie', 'donut') } {
            # Group data by field
            $groupField = $config.groupField
            if (-not $groupField) { return $null }

            $grouped = $dataArray | Group-Object -Property $groupField
            $labels = @($grouped | ForEach-Object { if ($_.Name) { $_.Name } else { '(Empty)' } })
            $series = @($grouped | ForEach-Object { $_.Count })

            $labelsJson = $labels | ConvertTo-Json -Compress
            $seriesJson = $series | ConvertTo-Json -Compress

            return @"
{
    chart: {
        type: '$ChartType',
        height: 350
    },
    series: $seriesJson,
    labels: $labelsJson,
    title: {
        text: '$([System.Web.HttpUtility]::JavaScriptStringEncode($chartTitle))',
        align: 'center'
    },
    plotOptions: {
        pie: {
            donut: {
                size: '$( if ($ChartType -eq 'donut') { '55%' } else { '0%' } )'
            }
        }
    },
    responsive: [{
        breakpoint: 480,
        options: {
            chart: { width: 300 },
            legend: { position: 'bottom' }
        }
    }]
}
"@
        }

        { $_ -in @('bar', 'line', 'area') } {
            # Use label and value fields
            $labelField = $config.labelField
            $valueField = $config.valueField

            if (-not $labelField -or -not $valueField) {
                # Try to use first string and first numeric property
                $firstItem = $dataArray[0]
                $props = $firstItem.PSObject.Properties
                $labelField = ($props | Where-Object { $_.Value -is [string] } | Select-Object -First 1).Name
                $valueField = ($props | Where-Object { $_.Value -is [int] -or $_.Value -is [double] } | Select-Object -First 1).Name

                if (-not $labelField -or -not $valueField) { return $null }
            }

            $categories = @($dataArray | ForEach-Object { $_.$labelField })
            $values = @($dataArray | ForEach-Object { $_.$valueField })

            $categoriesJson = $categories | ConvertTo-Json -Compress
            $valuesJson = $values | ConvertTo-Json -Compress

            return @"
{
    chart: {
        type: '$ChartType',
        height: 350
    },
    series: [{
        name: '$([System.Web.HttpUtility]::JavaScriptStringEncode($valueField))',
        data: $valuesJson
    }],
    xaxis: {
        categories: $categoriesJson,
        labels: {
            rotate: -45,
            rotateAlways: false
        }
    },
    title: {
        text: '$([System.Web.HttpUtility]::JavaScriptStringEncode($chartTitle))',
        align: 'center'
    },
    plotOptions: {
        bar: {
            borderRadius: 4,
            horizontal: false
        }
    },
    dataLabels: {
        enabled: false
    }
}
"@
        }

        default {
            return $null
        }
    }
}
