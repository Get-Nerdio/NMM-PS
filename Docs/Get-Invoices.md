---
external help file: NMM-PS-help.xml
Module Name: NMM-PS
online version:
schema: 2.0.0
---

# Get-Invoices

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### None (Default)
```
Get-Invoices [-All <Boolean>] [-HidePaid <Boolean>] [-HideUnpaid <Boolean>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### ById
```
Get-Invoices -id <Int32> [-HidePaid <Boolean>] [-HideUnpaid <Boolean>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### ByDate
```
Get-Invoices -periodStart <DateTime> -periodEnd <DateTime> [-HidePaid <Boolean>] [-HideUnpaid <Boolean>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -All
{{ Fill All Description }}

```yaml
Type: Boolean
Parameter Sets: None
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HidePaid
{{ Fill HidePaid Description }}

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HideUnpaid
{{ Fill HideUnpaid Description }}

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -id
{{ Fill id Description }}

```yaml
Type: Int32
Parameter Sets: ById
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -periodEnd
{{ Fill periodEnd Description }}

```yaml
Type: DateTime
Parameter Sets: ByDate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -periodStart
{{ Fill periodStart Description }}

```yaml
Type: DateTime
Parameter Sets: ByDate
Aliases:

Required: True
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
