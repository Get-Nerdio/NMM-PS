# Get-NMMImageTemplate

Lists image templates for an account.

## Syntax

```powershell
Get-NMMImageTemplate
    -AccountId <Int32>
    [<CommonParameters>]
```

## Description

The `Get-NMMImageTemplate` cmdlet retrieves available image templates that can be used to create new desktop images.

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

### Example 1: Get image templates

```powershell
Get-NMMImageTemplate -AccountId 123
```

### Example 2: Pipeline usage

```powershell
Get-NMMAccount | Get-NMMImageTemplate
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| id | Int32 | Template ID |
| name | String | Template name |
| osType | String | Windows 10, Windows 11 |
| publisher | String | Image publisher |
| sku | String | Image SKU |
| version | String | Image version |

## Related Links

- [Get-NMMDesktopImage](Get-NMMDesktopImage.md)
