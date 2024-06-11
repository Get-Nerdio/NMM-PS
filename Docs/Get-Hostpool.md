---
external help file: NMM-PS-help.xml
Module Name: NMM-PS
online version:
schema: 2.0.0
---

# Get-Hostpool

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### None (Default)
```
Get-Hostpool -Id <Int32> -HostpoolName <String> [-Subscription <String>] [-ResourceGroup <String>]
 [-AutoScaleEnabled <Boolean>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Details
```
Get-Hostpool -Id <Int32> [-AutoScaleSettings <Boolean>] [-AutoScaleConfiguration <Boolean>]
 [-ActiveDirectory <Boolean>] [-FSLogixConfig <Boolean>] [-RDPSettings <Boolean>] [-AssignedUsers <Boolean>]
 [-HostPoolProperties <Boolean>] [-VMDeploymentSettings <Boolean>] [-SessionTimouts <Boolean>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### All
```
Get-Hostpool -Id <Int32> [-All <Boolean>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
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

### -ActiveDirectory
{{ Fill ActiveDirectory Description }}

```yaml
Type: Boolean
Parameter Sets: Details
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -All
{{ Fill All Description }}

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

### -AssignedUsers
{{ Fill AssignedUsers Description }}

```yaml
Type: Boolean
Parameter Sets: Details
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AutoScaleConfiguration
{{ Fill AutoScaleConfiguration Description }}

```yaml
Type: Boolean
Parameter Sets: Details
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AutoScaleEnabled
{{ Fill AutoScaleEnabled Description }}

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

### -AutoScaleSettings
{{ Fill AutoScaleSettings Description }}

```yaml
Type: Boolean
Parameter Sets: Details
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FSLogixConfig
{{ Fill FSLogixConfig Description }}

```yaml
Type: Boolean
Parameter Sets: Details
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HostpoolName
{{ Fill HostpoolName Description }}

```yaml
Type: String
Parameter Sets: None
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HostPoolProperties
{{ Fill HostPoolProperties Description }}

```yaml
Type: Boolean
Parameter Sets: Details
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
{{ Fill Id Description }}

```yaml
Type: Int32
Parameter Sets: (All)
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

### -RDPSettings
{{ Fill RDPSettings Description }}

```yaml
Type: Boolean
Parameter Sets: Details
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceGroup
{{ Fill ResourceGroup Description }}

```yaml
Type: String
Parameter Sets: None
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SessionTimouts
{{ Fill SessionTimouts Description }}

```yaml
Type: Boolean
Parameter Sets: Details
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Subscription
{{ Fill Subscription Description }}

```yaml
Type: String
Parameter Sets: None
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VMDeploymentSettings
{{ Fill VMDeploymentSettings Description }}

```yaml
Type: Boolean
Parameter Sets: Details
Aliases:

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
