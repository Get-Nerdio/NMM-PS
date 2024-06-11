---
external help file: NMM-PS-help.xml
Module Name: NMM-PS
online version:
schema: 2.0.0
---

# Get-Backups

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### Item
```
Get-Backups -AccountId <String> -ProtectedItemId <String> [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### List
```
Get-Backups -AccountId <String> [-ListProtected] [-FriendlyName <String>] [-ProtectedItemType <String>]
 [-ProtectionState <String>] [-LastBackupStatus <String>] [-LastRestorePoint <DateTime>]
 [-SoftDeleted <Boolean>] [-RecoveryVault <String>] [-PolicyName <String>] [-VaultIsManaged <Boolean>]
 [-IsBackupInProgress <Boolean>] [-ResourceGroupName <String>] [-ReturnRecoveryPoints <Boolean>]
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

### -AccountId
{{ Fill AccountId Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FriendlyName
{{ Fill FriendlyName Description }}

```yaml
Type: String
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IsBackupInProgress
{{ Fill IsBackupInProgress Description }}

```yaml
Type: Boolean
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LastBackupStatus
{{ Fill LastBackupStatus Description }}

```yaml
Type: String
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LastRestorePoint
{{ Fill LastRestorePoint Description }}

```yaml
Type: DateTime
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ListProtected
{{ Fill ListProtected Description }}

```yaml
Type: SwitchParameter
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PolicyName
{{ Fill PolicyName Description }}

```yaml
Type: String
Parameter Sets: List
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

### -ProtectedItemId
{{ Fill ProtectedItemId Description }}

```yaml
Type: String
Parameter Sets: Item
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProtectedItemType
{{ Fill ProtectedItemType Description }}

```yaml
Type: String
Parameter Sets: List
Aliases:
Accepted values: AzureFileShare, VM

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProtectionState
{{ Fill ProtectionState Description }}

```yaml
Type: String
Parameter Sets: List
Aliases:
Accepted values: Protected, ProtectionStopped, IRPending, ProtectionPaused

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RecoveryVault
{{ Fill RecoveryVault Description }}

```yaml
Type: String
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceGroupName
{{ Fill ResourceGroupName Description }}

```yaml
Type: String
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReturnRecoveryPoints
{{ Fill ReturnRecoveryPoints Description }}

```yaml
Type: Boolean
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SoftDeleted
{{ Fill SoftDeleted Description }}

```yaml
Type: Boolean
Parameter Sets: List
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VaultIsManaged
{{ Fill VaultIsManaged Description }}

```yaml
Type: Boolean
Parameter Sets: List
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
