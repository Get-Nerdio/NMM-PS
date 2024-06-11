function ConvertTo-StructuredData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$String
    )

   
    if ([string]::IsNullOrWhiteSpace($String)) {
        Write-LogError "Provided String is null or empty."
        return
    }
    
    try {
        $parts = $String.TrimStart('/').Split('/')
        $result = New-Object -TypeName PSObject

        # Process each part and assume alternating parts are key-value pairs
        for ($i = 0; $i -lt $parts.Length; $i += 2) {
            $key = $parts[$i] -replace 's$', ''  # Normalize key names by removing trailing 's'
            $value = $parts[$i + 1]

            # Handle the last part if it doesn't have a corresponding value
            if (-not $value -and $i -eq $parts.Length - 1) {
                $value = "Not applicable or end of string"
            }

            if ($result.psobject.Properties.Name -contains $key) {
                $j = 1
                # Ensure unique key names by appending a number if duplicated
                while ($result.psobject.Properties.Name -contains ($key + "_$j")) {
                    $j++
                }
                $key = $key + "_$j"
            }

            $result | Add-Member -MemberType NoteProperty -Name $key -Value $value
        }

        return $result
    }
    catch {
        Write-LogError -Message "Failed to convert string to structured data: $($_.Exception.Message)"
    }
    finally {
        Write-Verbose "Conversion completed."
    }
}

