# Set-NMMAutoscale

Configures autoscale settings for a host pool.

## Syntax

```powershell
Set-NMMAutoscale
    -AccountId <Int32>
    -SubscriptionId <String>
    -ResourceGroup <String>
    -PoolName <String>
    [-Enabled <Boolean>]
    [-MinActiveHosts <Int32>]
    [-MaxActiveHosts <Int32>]
    [-ScaleInThreshold <Int32>]
    [-ScaleOutThreshold <Int32>]
    [<CommonParameters>]
```

## Description

The `Set-NMMAutoscale` cmdlet configures the autoscale settings for a host pool, allowing automatic scaling based on demand or schedule.

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

### -Enabled

Enable or disable autoscale.

| | |
|---|---|
| Type | Boolean |
| Required | False |

### -MinActiveHosts

Minimum number of running hosts.

| | |
|---|---|
| Type | Int32 |
| Required | False |

### -MaxActiveHosts

Maximum number of running hosts.

| | |
|---|---|
| Type | Int32 |
| Required | False |

### -ScaleInThreshold

CPU percentage threshold to scale in.

| | |
|---|---|
| Type | Int32 |
| Required | False |

### -ScaleOutThreshold

CPU percentage threshold to scale out.

| | |
|---|---|
| Type | Int32 |
| Required | False |

## Examples

### Example 1: Enable autoscale

```powershell
Set-NMMAutoscale -AccountId 123 -SubscriptionId "sub-id" -ResourceGroup "rg-avd" `
    -PoolName "hp-prod" -Enabled $true -MinActiveHosts 2 -MaxActiveHosts 10
```

### Example 2: Configure thresholds

```powershell
Set-NMMAutoscale -AccountId 123 -SubscriptionId "sub-id" -ResourceGroup "rg-avd" `
    -PoolName "hp-prod" -ScaleInThreshold 20 -ScaleOutThreshold 80
```

## Related Links

- [Get-NMMHostPoolAutoscale](Get-NMMHostPoolAutoscale.md)
- [Get-NMMAutoscaleProfile](../automation/Get-NMMAutoscaleProfile.md)
