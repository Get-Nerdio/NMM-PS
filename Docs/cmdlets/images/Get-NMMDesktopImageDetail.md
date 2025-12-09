# Get-NMMDesktopImageDetail

Gets detailed configuration for a desktop image.

## Syntax

```powershell
Get-NMMDesktopImageDetail
    -AccountId <Int32>
    -ImageId <Int32>
    [<CommonParameters>]
```

## Description

The `Get-NMMDesktopImageDetail` cmdlet retrieves detailed configuration for a specific desktop image, including VM settings, installed applications, and build configuration.

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

### Example 1: Get image details

```powershell
Get-NMMDesktopImageDetail -AccountId 123 -ImageId 456
```

### Example 2: Pipeline from Get-NMMDesktopImage

```powershell
Get-NMMDesktopImage -AccountId 123 | Get-NMMDesktopImageDetail
```

## Outputs

**PSCustomObject**

| Property | Type | Description |
|----------|------|-------------|
| id | Int32 | Image ID |
| name | String | Image name |
| vmSize | String | Azure VM SKU |
| osDiskSize | Int32 | OS disk size (GB) |
| galleryImage | String | Source gallery image |
| scriptedActions | Object[] | Post-build scripts |
| installedApps | String[] | Installed applications |

## Related Links

- [Get-NMMDesktopImage](Get-NMMDesktopImage.md)
- [Get-NMMDesktopImageLog](Get-NMMDesktopImageLog.md)
