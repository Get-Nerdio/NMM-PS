# Get-NMMHostPoolSettings

Gets AVD settings for a host pool.

## Syntax

```powershell
Get-NMMHostPoolSettings
    -AccountId <Int32>
    -SubscriptionId <String>
    -ResourceGroup <String>
    -PoolName <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMHostPoolSettings` cmdlet retrieves Azure Virtual Desktop settings for a specific host pool, including max session limits, load balancing algorithm, and validation environment settings.

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
| Aliases | subscription |

### -ResourceGroup

The Azure resource group name.

| | |
|---|---|
| Type | String |
| Required | True |
| Pipeline Input | True (ByPropertyName) |
| Aliases | resourceGroup |

### -PoolName

The host pool name.

| | |
|---|---|
| Type | String |
| Required | True |
| Pipeline Input | True (ByPropertyName) |
| Aliases | hostPoolName |

## Examples

### Example 1: Get settings for a host pool

```powershell
Get-NMMHostPoolSettings -AccountId 123 -SubscriptionId "sub-id" -ResourceGroup "rg-avd" -PoolName "hp-prod"
```

### Example 2: Pipeline from Get-NMMHostPool

```powershell
Get-NMMAccount -AccountId 123 | Get-NMMHostPool | Get-NMMHostPoolSettings
```

## Outputs

**PSCustomObject**

| Property | Type | Description |
|----------|------|-------------|
| maxSessionLimit | Int32 | Max sessions per host |
| loadBalancerType | String | BreadthFirst or DepthFirst |
| validationEnvironment | Boolean | Is validation pool |
| preferredAppGroupType | String | Desktop or RemoteApp |

## Related Links

- [Get-NMMHostPool](Get-NMMHostPool.md)
- [Get-NMMHostPoolAutoscale](Get-NMMHostPoolAutoscale.md)
