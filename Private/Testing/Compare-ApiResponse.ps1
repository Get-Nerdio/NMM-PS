function Compare-ApiResponse {
    <#
    .SYNOPSIS
        Compares function output against raw API response.
    .DESCRIPTION
        Performs a deep comparison of two objects to identify differences
        in structure and values. Useful for validating that NMM-PS functions
        correctly process API responses.
    .PARAMETER FunctionOutput
        The output from the NMM-PS function.
    .PARAMETER RawApiOutput
        The raw output from Invoke-APIRequest.
    .PARAMETER IgnoreProperties
        Properties to ignore during comparison (e.g., PSTypeName additions).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $FunctionOutput,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $RawApiOutput,

        [Parameter()]
        [string[]]$IgnoreProperties = @()
    )

    $differences = [System.Collections.Generic.List[PSCustomObject]]::new()

    # Handle null cases
    if ($null -eq $FunctionOutput -and $null -eq $RawApiOutput) {
        return [PSCustomObject]@{
            AreEqual    = $true
            Differences = @()
        }
    }

    if ($null -eq $FunctionOutput -or $null -eq $RawApiOutput) {
        $differences.Add([PSCustomObject]@{
                Path           = '$root'
                Type           = 'NullMismatch'
                FunctionValue  = if ($null -eq $FunctionOutput) { '<null>' } else { '<has value>' }
                RawApiValue    = if ($null -eq $RawApiOutput) { '<null>' } else { '<has value>' }
            })
        return [PSCustomObject]@{
            AreEqual    = $false
            Differences = $differences.ToArray()
        }
    }

    # Compare arrays
    $funcArray = @($FunctionOutput)
    $rawArray = @($RawApiOutput)

    if ($funcArray.Count -ne $rawArray.Count) {
        $differences.Add([PSCustomObject]@{
                Path           = '$root'
                Type           = 'CountMismatch'
                FunctionValue  = $funcArray.Count
                RawApiValue    = $rawArray.Count
            })
    }

    # Compare first item's properties (for schema comparison)
    if ($funcArray.Count -gt 0 -and $rawArray.Count -gt 0) {
        $funcItem = $funcArray[0]
        $rawItem = $rawArray[0]

        # Get properties (excluding PSTypeName-related)
        $funcProps = @($funcItem.PSObject.Properties | Where-Object { $_.Name -notin $IgnoreProperties }).Name | Sort-Object
        $rawProps = @($rawItem.PSObject.Properties | Where-Object { $_.Name -notin $IgnoreProperties }).Name | Sort-Object

        # Find missing properties in function output
        $missingInFunc = $rawProps | Where-Object { $_ -notin $funcProps }
        foreach ($prop in $missingInFunc) {
            $differences.Add([PSCustomObject]@{
                    Path           = $prop
                    Type           = 'MissingInFunction'
                    FunctionValue  = '<missing>'
                    RawApiValue    = $rawItem.$prop
                })
        }

        # Find extra properties in function output (usually PSTypeName additions)
        $extraInFunc = $funcProps | Where-Object { $_ -notin $rawProps }
        foreach ($prop in $extraInFunc) {
            $differences.Add([PSCustomObject]@{
                    Path           = $prop
                    Type           = 'ExtraInFunction'
                    FunctionValue  = $funcItem.$prop
                    RawApiValue    = '<not present>'
                })
        }

        # Compare values of common properties
        $commonProps = $funcProps | Where-Object { $_ -in $rawProps }
        foreach ($prop in $commonProps) {
            $funcValue = $funcItem.$prop
            $rawValue = $rawItem.$prop

            # Skip complex objects for now (arrays, nested objects)
            if ($funcValue -is [array] -or $rawValue -is [array]) {
                continue
            }

            # Compare simple values
            if ($funcValue -ne $rawValue) {
                # Handle type differences (e.g., string vs int)
                if ($funcValue.ToString() -eq $rawValue.ToString()) {
                    continue
                }

                $differences.Add([PSCustomObject]@{
                        Path           = $prop
                        Type           = 'ValueMismatch'
                        FunctionValue  = $funcValue
                        RawApiValue    = $rawValue
                    })
            }
        }
    }

    return [PSCustomObject]@{
        AreEqual       = ($differences.Count -eq 0)
        Differences    = $differences.ToArray()
        FunctionCount  = $funcArray.Count
        RawApiCount    = $rawArray.Count
        FunctionProps  = if ($funcArray.Count -gt 0) { @($funcArray[0].PSObject.Properties.Name) } else { @() }
        RawApiProps    = if ($rawArray.Count -gt 0) { @($rawArray[0].PSObject.Properties.Name) } else { @() }
    }
}

function Get-PropertyDiff {
    <#
    .SYNOPSIS
        Gets a simple property difference summary between two objects.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Object1,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Object2,

        [Parameter()]
        [string[]]$IgnoreProperties = @()
    )

    $obj1Props = @()
    $obj2Props = @()

    if ($Object1) {
        $items = @($Object1)
        if ($items.Count -gt 0) {
            $obj1Props = @($items[0].PSObject.Properties | Where-Object { $_.Name -notin $IgnoreProperties }).Name
        }
    }

    if ($Object2) {
        $items = @($Object2)
        if ($items.Count -gt 0) {
            $obj2Props = @($items[0].PSObject.Properties | Where-Object { $_.Name -notin $IgnoreProperties }).Name
        }
    }

    return [PSCustomObject]@{
        OnlyInFirst  = @($obj1Props | Where-Object { $_ -notin $obj2Props })
        OnlyInSecond = @($obj2Props | Where-Object { $_ -notin $obj1Props })
        InBoth       = @($obj1Props | Where-Object { $_ -in $obj2Props })
    }
}
