---
external help file: NMM-PS-help.xml
Module Name: NMM-PS
online version:
schema: 2.0.0
---

# Get-CostEstimator

## SYNOPSIS
Retrieves cost estimates either by ID or lists all saved estimates.

## SYNTAX

### ById (Default)
```
Get-CostEstimator [-id <Int32>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### All
```
Get-CostEstimator [-All <Boolean>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function retrieves cost estimates from an API either by specifying an ID or listing all saved estimates.

## EXAMPLES

### Example 1: Retrieve by ID
```powershell
Get-CostEstimator -id 123
```

### Example 2: Retrieve all CE's
```powershell
Get-CostEstimator -All $true
```

## PARAMETERS

### -All
Use -All $true to list all saved estimates

```yaml
Type: Boolean
Parameter Sets: All
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -id
Search for an estimate by ID

```yaml
Type: Int32
Parameter Sets: ById
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
