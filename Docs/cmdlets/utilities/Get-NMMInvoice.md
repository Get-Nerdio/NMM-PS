# Get-NMMInvoice

Gets invoices.

## Syntax

```powershell
Get-NMMInvoice
    [-AccountId <Int32>]
    [-StartDate <DateTime>]
    [-EndDate <DateTime>]
    [<CommonParameters>]
```

## Description

The `Get-NMMInvoice` cmdlet retrieves billing invoices.

## Parameters

### -AccountId

Filter by account ID.

| | |
|---|---|
| Type | Int32 |
| Required | False |
| Pipeline Input | True (ByPropertyName) |

### -StartDate

Filter invoices from this date.

| | |
|---|---|
| Type | DateTime |
| Required | False |

### -EndDate

Filter invoices until this date.

| | |
|---|---|
| Type | DateTime |
| Required | False |

## Examples

### Example 1: Get all invoices

```powershell
Get-NMMInvoice
```

### Example 2: Get invoices for date range

```powershell
Get-NMMInvoice -StartDate "2024-01-01" -EndDate "2024-12-31"
```

### Example 3: Get invoices for specific account

```powershell
Get-NMMInvoice -AccountId 123
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| invoiceId | String | Invoice identifier |
| invoiceDate | DateTime | Invoice date |
| amount | Decimal | Total amount |
| currency | String | Currency code |
| status | String | Paid, Pending |

## Related Links

- [Get-NMMCostEstimator](Get-NMMCostEstimator.md)
