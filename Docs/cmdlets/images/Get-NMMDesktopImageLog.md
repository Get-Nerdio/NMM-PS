# Get-NMMDesktopImageLog

Gets change history for a desktop image.

## Syntax

```powershell
Get-NMMDesktopImageLog
    -AccountId <Int32>
    -ImageId <Int32>
    [<CommonParameters>]
```

## Description

The `Get-NMMDesktopImageLog` cmdlet retrieves the build and modification history for a desktop image.

## Parameters

### -AccountId

The NMM account ID.

| | |
|---|---|
| Type | Int32 |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

### -ImageId

The desktop image ID.

| | |
|---|---|
| Type | Int32 |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

## Examples

### Example 1: Get image logs

```powershell
Get-NMMDesktopImageLog -AccountId 123 -ImageId 456
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| timestamp | DateTime | Event time |
| action | String | Build, Update, Delete |
| status | String | Success, Failed |
| message | String | Log message |
| initiatedBy | String | User who triggered |

## Related Links

- [Get-NMMDesktopImage](Get-NMMDesktopImage.md)
- [Get-NMMDesktopImageDetail](Get-NMMDesktopImageDetail.md)
