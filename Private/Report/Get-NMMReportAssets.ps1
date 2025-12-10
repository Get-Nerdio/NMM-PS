function Get-NMMReportAssets {
    <#
    .SYNOPSIS
        Retrieves embedded assets for HTML reports.
    .DESCRIPTION
        Returns CSS, JavaScript initialization code, and logo as embedded content
        for self-contained HTML reports.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet('Logo', 'CSS', 'JavaScript', 'All')]
        [string]$AssetType = 'All'
    )

    $result = @{}

    # Logo
    if ($AssetType -in @('Logo', 'All')) {
        $logoPath = Join-Path $PSScriptRoot '..\Data\NerdioLogo.base64'
        if (Test-Path $logoPath) {
            $result.Logo = (Get-Content -Path $logoPath -Raw).Trim()
        }
        else {
            Write-Warning "Logo file not found at: $logoPath"
            $result.Logo = ''
        }
    }

    # CSS
    if ($AssetType -in @('CSS', 'All')) {
        $result.CSS = Get-NMMReportCss
    }

    # JavaScript
    if ($AssetType -in @('JavaScript', 'All')) {
        $result.JavaScript = Get-NMMReportJavaScript
    }

    if ($AssetType -eq 'All') {
        return $result
    }
    else {
        return $result[$AssetType]
    }
}

function Get-NMMReportCss {
    <#
    .SYNOPSIS
        Returns embedded CSS with Nerdio branding.
    #>
    return @'
/* Nerdio Report Styles - Bootstrap 5 Extensions */
:root {
    --nmm-navy-orbit: #042838;
    --nmm-nerdio-blue: #1E9DB8;
    --nmm-white: #FFFFFF;
    --nmm-green-galaxy: #CDFF4E;
    --nmm-proton-purple: #A795C7;
}

body {
    font-family: 'Poppins', -apple-system, BlinkMacSystemFont, sans-serif;
    background-color: #f8f9fa;
    color: #333;
}

.nmm-header {
    background: linear-gradient(135deg, var(--nmm-navy-orbit) 0%, #0a4a5c 100%);
    color: white;
    padding: 2rem 0;
    margin-bottom: 2rem;
}

.nmm-header h1 {
    font-weight: 600;
    margin-bottom: 0.5rem;
    font-size: 2rem;
}

.nmm-header .lead {
    opacity: 0.9;
    font-weight: 400;
}

.nmm-logo {
    max-height: 45px;
    margin-bottom: 1rem;
}

.nmm-section {
    background: white;
    border-radius: 12px;
    box-shadow: 0 2px 12px rgba(0,0,0,0.08);
    margin-bottom: 2rem;
    overflow: hidden;
}

.nmm-section-header {
    background: var(--nmm-navy-orbit);
    color: white;
    padding: 1rem 1.5rem;
    font-weight: 600;
    font-size: 1.1rem;
}

.nmm-section-description {
    padding: 1rem 1.5rem 0;
    color: #666;
    font-size: 0.9rem;
}

.nmm-section-body {
    padding: 1.5rem;
}

.nmm-chart-container {
    min-height: 350px;
    margin-bottom: 1.5rem;
}

.nmm-table {
    width: 100%;
    font-size: 0.9rem;
}

.nmm-table thead th {
    background: var(--nmm-navy-orbit);
    color: white;
    font-weight: 500;
    border: none;
    padding: 0.75rem 1rem;
    white-space: nowrap;
}

.nmm-table tbody td {
    padding: 0.75rem 1rem;
    vertical-align: middle;
}

.nmm-table tbody tr:hover {
    background-color: rgba(30, 157, 184, 0.08);
}

.nmm-table tbody tr:nth-child(even) {
    background-color: #f8f9fa;
}

.nmm-table tbody tr:nth-child(even):hover {
    background-color: rgba(30, 157, 184, 0.12);
}

.nmm-footer {
    text-align: center;
    padding: 1.5rem;
    color: #6c757d;
    border-top: 1px solid #dee2e6;
    margin-top: 2rem;
    background: white;
}

.nmm-footer p {
    margin-bottom: 0.25rem;
}

.nmm-badge {
    background: var(--nmm-nerdio-blue);
    color: white;
    padding: 0.25rem 0.75rem;
    border-radius: 20px;
    font-size: 0.8rem;
    font-weight: 500;
}

.nmm-stat-card {
    background: linear-gradient(135deg, var(--nmm-nerdio-blue), #157a91);
    color: white;
    border-radius: 12px;
    padding: 1.5rem;
    text-align: center;
    height: 100%;
}

.nmm-stat-value {
    font-size: 2.5rem;
    font-weight: 700;
    line-height: 1.2;
}

.nmm-stat-label {
    font-size: 0.9rem;
    opacity: 0.9;
    margin-top: 0.5rem;
}

.nmm-summary-row {
    display: flex;
    gap: 1rem;
    margin-bottom: 1.5rem;
    flex-wrap: wrap;
}

.nmm-summary-row .nmm-stat-card {
    flex: 1;
    min-width: 150px;
}

/* Dark theme */
.nmm-dark {
    background-color: #0d1117;
    color: #e0e7ee;
}

.nmm-dark .nmm-section {
    background: #161b22;
    box-shadow: 0 2px 12px rgba(0,0,0,0.3);
}

.nmm-dark .nmm-table tbody tr:nth-child(even) {
    background-color: #1c2128;
}

.nmm-dark .nmm-table tbody tr:hover {
    background-color: rgba(30, 157, 184, 0.2);
}

.nmm-dark .nmm-footer {
    background: #161b22;
    border-color: #30363d;
}

/* DataTables customization */
.dataTables_wrapper {
    padding-top: 0.5rem;
}

.dataTables_wrapper .dataTables_length,
.dataTables_wrapper .dataTables_filter {
    margin-bottom: 1rem;
}

.dataTables_wrapper .dataTables_filter input {
    border: 1px solid #dee2e6;
    border-radius: 6px;
    padding: 0.5rem 1rem;
    margin-left: 0.5rem;
}

.dataTables_wrapper .dataTables_paginate .paginate_button {
    border-radius: 4px !important;
    margin: 0 2px;
}

.dataTables_wrapper .dataTables_paginate .paginate_button.current {
    background: var(--nmm-nerdio-blue) !important;
    border-color: var(--nmm-nerdio-blue) !important;
    color: white !important;
}

.dataTables_wrapper .dataTables_paginate .paginate_button:hover {
    background: var(--nmm-navy-orbit) !important;
    border-color: var(--nmm-navy-orbit) !important;
    color: white !important;
}

.dataTables_wrapper .dataTables_info {
    padding-top: 1rem;
    color: #6c757d;
}

/* ApexCharts customization */
.apexcharts-tooltip {
    border-radius: 8px !important;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15) !important;
}

.apexcharts-legend-text {
    font-family: 'Poppins', sans-serif !important;
}

/* Responsive adjustments */
@media (max-width: 768px) {
    .nmm-header {
        padding: 1.5rem 0;
    }

    .nmm-header h1 {
        font-size: 1.5rem;
    }

    .nmm-section-body {
        padding: 1rem;
    }

    .nmm-chart-container {
        min-height: 250px;
    }
}
'@
}

function Get-NMMReportJavaScript {
    <#
    .SYNOPSIS
        Returns JavaScript initialization code for the report.
    #>
    return @'
// Initialize DataTables
document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.nmm-datatable').forEach(function(table) {
        new DataTable(table, {
            pageLength: 25,
            lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
            responsive: true,
            dom: '<"row"<"col-sm-12 col-md-6"l><"col-sm-12 col-md-6"f>>rtip',
            language: {
                search: "_INPUT_",
                searchPlaceholder: "Search...",
                lengthMenu: "Show _MENU_ entries",
                info: "Showing _START_ to _END_ of _TOTAL_ entries",
                paginate: {
                    first: "First",
                    last: "Last",
                    next: "Next",
                    previous: "Previous"
                }
            },
            order: [[0, 'asc']]
        });
    });
});

// Chart initialization helper
function initNMMChart(elementId, options) {
    var defaultOptions = {
        chart: {
            fontFamily: 'Poppins, sans-serif',
            toolbar: {
                show: true,
                tools: {
                    download: true,
                    selection: false,
                    zoom: false,
                    zoomin: false,
                    zoomout: false,
                    pan: false,
                    reset: false
                }
            }
        },
        colors: ['#042838', '#1E9DB8', '#CDFF4E', '#A795C7', '#0a4a5c', '#157a91'],
        dataLabels: {
            style: {
                fontFamily: 'Poppins, sans-serif'
            }
        },
        legend: {
            fontFamily: 'Poppins, sans-serif',
            position: 'bottom'
        },
        tooltip: {
            style: {
                fontFamily: 'Poppins, sans-serif'
            }
        }
    };

    // Merge options
    var mergedOptions = Object.assign({}, defaultOptions, options);
    mergedOptions.chart = Object.assign({}, defaultOptions.chart, options.chart || {});

    var chart = new ApexCharts(document.querySelector('#' + elementId), mergedOptions);
    chart.render();
    return chart;
}

// Utility function to format numbers
function formatNumber(num) {
    if (num === null || num === undefined) return '-';
    return num.toLocaleString();
}

// Utility function to format dates
function formatDate(dateStr) {
    if (!dateStr) return '-';
    var date = new Date(dateStr);
    if (isNaN(date.getTime())) return dateStr;
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
}
'@
}
