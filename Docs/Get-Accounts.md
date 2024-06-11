---
external help file: NMM-PS-help.xml
Module Name: NMM-PS
online version:
schema: 2.0.0
---

# Get-Accounts

## SYNOPSIS
Retrieves all accounts in the NMM portal.

## SYNTAX

```
Get-Accounts [[-id] <Int32[]>] [[-Name] <String[]>] [[-TenantId] <String[]>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function retrieves all accounts in the NMM portal.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Get-Accounts }}
```

{{ Retrieves all accounts in the NMM portal.}}

### Example 2
```powershell
PS C:\> {{ Get-Accounts -id 2 }}
```

{{ Retrieves the account with the specified id.}}

### Example 3
```powershell
PS C:\> {{ Get-Accounts -id 2 -Name "Airplane" }}
```

{{ Retrieves the accounts with the specified id and name, it will use Regex and match the name. This expample will retrun all accounts with the name "Airplane" in it and all accounts that match -id 2.}} 
```


## PARAMETERS

### -id
{{ Fill id Description }}

```yaml
Type: Int32[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
{{ Fill Name Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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

### -TenantId
{{ Fill TenantId Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
