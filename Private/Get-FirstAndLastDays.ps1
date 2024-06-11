function Get-FirstAndLastDays {
    param (
        [datetime]$Date
    )
    $firstDay = Get-Date -Year $Date.Year -Month $Date.Month -Day 1
    $lastDay = $firstDay.AddMonths(1).AddDays(-1)

    return @{ FirstDay = $firstDay.ToString("MM/dd/yyyy"); LastDay = $lastDay.ToString("MM/dd/yyyy") }
}