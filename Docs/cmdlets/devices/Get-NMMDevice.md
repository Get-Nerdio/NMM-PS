# Get-NMMDevice

Lists Intune-enrolled devices.

## Syntax

```powershell
Get-NMMDevice
    -AccountId <Int32>
    [-DeviceId <String>]
    [<CommonParameters>]
```

## Description

The `Get-NMMDevice` cmdlet retrieves Intune-enrolled devices for an NMM account.

!!! warning "Beta API"
    This cmdlet uses the v1-beta API and may change without notice.

## Parameters

### -AccountId

The NMM account ID.

| | |
|---|---|
| Type | Int32 |
| Required | True |
| Pipeline Input | True (ByPropertyName) |
| Aliases | id |

### -DeviceId

Filter by specific device ID.

| | |
|---|---|
| Type | String |
| Required | False |

## Examples

### Example 1: Get all devices

```powershell
Get-NMMDevice -AccountId 123
```

### Example 2: Get specific device

```powershell
Get-NMMDevice -AccountId 123 -DeviceId "device-abc-123"
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| deviceId | String | Intune device ID |
| deviceName | String | Device name |
| osVersion | String | Operating system |
| enrollmentDate | DateTime | Enrollment date |
| lastSyncDateTime | DateTime | Last Intune sync |
| complianceState | String | Compliant, NonCompliant |

## Related Links

- [Get-NMMDeviceCompliance](Get-NMMDeviceCompliance.md)
- [Sync-NMMDevice](Sync-NMMDevice.md)
