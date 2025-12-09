# Get-NMMFSLogixConfig

Gets FSLogix configurations for an account.

## Syntax

```powershell
Get-NMMFSLogixConfig
    -AccountId <Int32>
    [<CommonParameters>]
```

## Description

The `Get-NMMFSLogixConfig` cmdlet retrieves FSLogix profile container configurations available for an account.

## Parameters

### -AccountId

The NMM account ID.

| | |
|---|---|
| Type | Int32 |
| Required | True |
| Pipeline Input | True (ByPropertyName) |
| Aliases | id |

## Examples

### Example 1: Get FSLogix configs

```powershell
Get-NMMFSLogixConfig -AccountId 123
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| id | Int32 | Config ID |
| name | String | Config name |
| vhdLocations | String[] | Storage paths |
| profileType | String | VHD or VHDX |
| sizeInGB | Int32 | Default size |
| cloudCacheEnabled | Boolean | Cloud Cache |

## Related Links

- [Get-NMMHostPoolFSLogix](../hostpools/Get-NMMHostPoolFSLogix.md)
