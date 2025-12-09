# Get-NMMDirectory

Gets AD directories.

## Syntax

```powershell
Get-NMMDirectory
    [-AccountId <Int32>]
    -Scope <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMDirectory` cmdlet retrieves Active Directory configurations.

## Parameters

### -AccountId

The NMM account ID (required for Account scope).

| | |
|---|---|
| Type | Int32 |
| Required | False |
| Pipeline Input | True (ByPropertyName) |

### -Scope

The scope of directories to retrieve.

| | |
|---|---|
| Type | String |
| Required | True |
| Valid Values | Account, Global |

## Examples

### Example 1: Get account directories

```powershell
Get-NMMDirectory -AccountId 123 -Scope Account
```

### Example 2: Get global directories

```powershell
Get-NMMDirectory -Scope Global
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| id | Int32 | Directory ID |
| name | String | Directory name |
| domainName | String | AD domain |
| domainType | String | AD, Azure AD |
| ouPath | String | Default OU |

## Related Links

- [Get-NMMHostPoolAD](../hostpools/Get-NMMHostPoolAD.md)
