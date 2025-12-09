# Get-NMMAutoscaleProfile

Gets autoscale profiles.

## Syntax

```powershell
Get-NMMAutoscaleProfile
    [-AccountId <Int32>]
    -Scope <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMAutoscaleProfile` cmdlet retrieves autoscale profiles that define scaling behavior for host pools.

## Parameters

### -AccountId

The NMM account ID (required for Account scope).

| | |
|---|---|
| Type | Int32 |
| Required | False |
| Pipeline Input | True (ByPropertyName) |

### -Scope

The scope of profiles to retrieve.

| | |
|---|---|
| Type | String |
| Required | True |
| Valid Values | Account, Global |

## Examples

### Example 1: Get account profiles

```powershell
Get-NMMAutoscaleProfile -AccountId 123 -Scope Account
```

### Example 2: Get global profiles

```powershell
Get-NMMAutoscaleProfile -Scope Global
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| id | Int32 | Profile ID |
| name | String | Profile name |
| description | String | Profile description |
| scalingMode | String | Capacity or Schedule |
| minHosts | Int32 | Minimum hosts |
| maxHosts | Int32 | Maximum hosts |
| rampUpSchedule | Object | Ramp-up settings |
| rampDownSchedule | Object | Ramp-down settings |

## Related Links

- [Get-NMMHostPoolAutoscale](../hostpools/Get-NMMHostPoolAutoscale.md)
- [Set-NMMAutoscale](../hostpools/Set-NMMAutoscale.md)
