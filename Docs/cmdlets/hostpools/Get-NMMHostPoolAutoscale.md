# Get-NMMHostPoolAutoscale

Gets autoscale configuration for a host pool.

## Syntax

```powershell
Get-NMMHostPoolAutoscale
    -AccountId <Int32>
    -SubscriptionId <String>
    -ResourceGroup <String>
    -PoolName <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMHostPoolAutoscale` cmdlet retrieves the autoscale configuration for a specific host pool, including scaling triggers, schedules, and host limits.

## Parameters

### -AccountId

The NMM account ID.

| | |
|---|---|
| Type | Int32 |
| Required | True |
| Pipeline Input | True (ByPropertyName) |
| Aliases | id |

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

### Example 1: Get autoscale config

```powershell
Get-NMMHostPoolAutoscale -AccountId 123 -SubscriptionId "sub-id" -ResourceGroup "rg-avd" -PoolName "hp-prod"
```

### Example 2: Pipeline usage

```powershell
Get-NMMHostPool -AccountId 123 | Get-NMMHostPoolAutoscale
```

## Outputs

**PSCustomObject**

| Property | Type | Description |
|----------|------|-------------|
| enabled | Boolean | Autoscale enabled |
| minActiveHosts | Int32 | Minimum running hosts |
| maxActiveHosts | Int32 | Maximum running hosts |
| scaleInThreshold | Int32 | CPU % to scale in |
| scaleOutThreshold | Int32 | CPU % to scale out |
| scheduleEnabled | Boolean | Schedule-based scaling |

## Related Links

- [Get-NMMHostPool](Get-NMMHostPool.md)
- [Set-NMMAutoscale](Set-NMMAutoscale.md)
- [Get-NMMAutoscaleProfile](../automation/Get-NMMAutoscaleProfile.md)
