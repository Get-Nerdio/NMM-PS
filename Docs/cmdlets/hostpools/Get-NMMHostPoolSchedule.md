# Get-NMMHostPoolSchedule

Gets scheduled jobs for a host pool.

## Syntax

```powershell
Get-NMMHostPoolSchedule
    -AccountId <Int32>
    -SubscriptionId <String>
    -ResourceGroup <String>
    -PoolName <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMHostPoolSchedule` cmdlet retrieves scheduled tasks and jobs configured for a host pool, including maintenance windows, scaling schedules, and scripted actions.

## Parameters

### -AccountId

The NMM account ID.

| | |
|---|---|
| Type | Int32 |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

### -SubscriptionId

The Azure subscription ID.

| | |
|---|---|
| Type | String |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

### -ResourceGroup

The Azure resource group name.

| | |
|---|---|
| Type | String |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

### -PoolName

The host pool name.

| | |
|---|---|
| Type | String |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

## Examples

### Example 1: Get schedules

```powershell
Get-NMMHostPoolSchedule -AccountId 123 -SubscriptionId "sub-id" -ResourceGroup "rg-avd" -PoolName "hp-prod"
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| id | Int32 | Schedule ID |
| name | String | Schedule name |
| scheduleType | String | Type of schedule |
| enabled | Boolean | Schedule enabled |
| nextRun | DateTime | Next execution time |

## Related Links

- [Get-NMMHostPool](Get-NMMHostPool.md)
- [Get-NMMSchedule](../automation/Get-NMMSchedule.md)
