# Get-NMMDesktopImage

Lists desktop images for an account.

## Syntax

```powershell
Get-NMMDesktopImage
    -AccountId <Int32>
    [-ImageId <Int32>]
    [<CommonParameters>]
```

## Description

The `Get-NMMDesktopImage` cmdlet retrieves desktop golden images configured for an NMM account.

## Parameters

### -AccountId

The NMM account ID.

| | |
|---|---|
| Type | Int32 |
| Required | True |
| Pipeline Input | True (ByPropertyName) |
| Aliases | id |

### -ImageId

Filter by specific image ID.

| | |
|---|---|
| Type | Int32 |
| Required | False |

## Examples

### Example 1: Get all images

```powershell
Get-NMMDesktopImage -AccountId 123
```

### Example 2: Pipeline from accounts

```powershell
Get-NMMAccount | Get-NMMDesktopImage
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| id | Int32 | Image ID |
| name | String | Image name |
| resourceGroup | String | Azure resource group |
| status | String | Ready, Building, Failed |
| osType | String | Windows 10, Windows 11 |
| lastUpdated | DateTime | Last modification |

## Related Links

- [Get-NMMDesktopImageDetail](Get-NMMDesktopImageDetail.md)
- [Get-NMMImageTemplate](Get-NMMImageTemplate.md)
