# New-NMMHostPool

Creates a new Azure Virtual Desktop host pool.

## Syntax

```powershell
New-NMMHostPool
    -AccountId <Int32>
    -Name <String>
    -ResourceGroup <String>
    -HostPoolType <String>
    [-Description <String>]
    [-MaxSessionLimit <Int32>]
    [-LoadBalancerType <String>]
    [<CommonParameters>]
```

## Description

The `New-NMMHostPool` cmdlet creates a new Azure Virtual Desktop host pool within an NMM account.

## Parameters

### -AccountId

The NMM account ID.

| | |
|---|---|
| Type | Int32 |
| Required | True |

### -Name

The name for the new host pool.

| | |
|---|---|
| Type | String |
| Required | True |

### -ResourceGroup

The Azure resource group for the host pool.

| | |
|---|---|
| Type | String |
| Required | True |

### -HostPoolType

The type of host pool.

| | |
|---|---|
| Type | String |
| Required | True |
| Valid Values | Pooled, Personal |

### -Description

Optional description for the host pool.

| | |
|---|---|
| Type | String |
| Required | False |

### -MaxSessionLimit

Maximum sessions per host (for pooled pools).

| | |
|---|---|
| Type | Int32 |
| Required | False |
| Default | 10 |

### -LoadBalancerType

Load balancing algorithm.

| | |
|---|---|
| Type | String |
| Required | False |
| Default | BreadthFirst |
| Valid Values | BreadthFirst, DepthFirst |

## Examples

### Example 1: Create a pooled host pool

```powershell
New-NMMHostPool -AccountId 123 -Name "hp-production" -ResourceGroup "rg-avd" -HostPoolType "Pooled"
```

### Example 2: Create with custom settings

```powershell
New-NMMHostPool -AccountId 123 -Name "hp-dev" -ResourceGroup "rg-avd" `
    -HostPoolType "Pooled" -MaxSessionLimit 5 -LoadBalancerType "DepthFirst"
```

## Outputs

**PSCustomObject**

Returns the created host pool object.

## Related Links

- [Get-NMMHostPool](Get-NMMHostPool.md)
- [Remove-NMMHostPool](Remove-NMMHostPool.md)
