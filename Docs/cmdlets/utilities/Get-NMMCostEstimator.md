# Get-NMMCostEstimator

Gets cost estimates.

## Syntax

```powershell
Get-NMMCostEstimator
    -AccountId <Int32>
    [<CommonParameters>]
```

## Description

The `Get-NMMCostEstimator` cmdlet retrieves cost estimation data for an account's Azure resources.

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

### Example 1: Get cost estimates

```powershell
Get-NMMCostEstimator -AccountId 123
```

## Outputs

**PSCustomObject**

| Property | Type | Description |
|----------|------|-------------|
| estimatedMonthlyCost | Decimal | Monthly estimate |
| currency | String | Currency code |
| breakdown | Object[] | Cost by resource |
| lastUpdated | DateTime | Estimate date |

## Related Links

- [Get-NMMInvoice](Get-NMMInvoice.md)
