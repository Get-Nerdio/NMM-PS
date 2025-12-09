# Get-NMMDesktopImageSchedule

Gets maintenance schedules for a desktop image.

## Syntax

```powershell
Get-NMMDesktopImageSchedule
    -AccountId <Int32>
    -ImageId <Int32>
    [<CommonParameters>]
```

## Description

The `Get-NMMDesktopImageSchedule` cmdlet retrieves scheduled maintenance tasks for a desktop image, such as automatic updates or rebuilds.

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

### Example 1: Get image schedules

```powershell
Get-NMMDesktopImageSchedule -AccountId 123 -ImageId 456
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| id | Int32 | Schedule ID |
| name | String | Schedule name |
| scheduleType | String | Update, Rebuild |
| enabled | Boolean | Schedule enabled |
| recurrence | String | Daily, Weekly, Monthly |
| nextRun | DateTime | Next execution |

## Related Links

- [Get-NMMDesktopImage](Get-NMMDesktopImage.md)
- [Get-NMMSchedule](../automation/Get-NMMSchedule.md)
