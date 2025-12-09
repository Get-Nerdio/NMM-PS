# Sync-NMMDevice

Forces an Intune sync for a device.

## Syntax

```powershell
Sync-NMMDevice
    -AccountId <Int32>
    -DeviceId <String>
    [<CommonParameters>]
```

## Description

The `Sync-NMMDevice` cmdlet triggers an immediate Intune policy sync for a device.

!!! warning "Beta API"
    This cmdlet uses the v1-beta API.

## Parameters

### -AccountId

The NMM account ID.

| | |
|---|---|
| Type | Int32 |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

### -DeviceId

The Intune device ID.

| | |
|---|---|
| Type | String |
| Required | True |
| Pipeline Input | True (ByPropertyName) |

## Examples

### Example 1: Sync a device

```powershell
Sync-NMMDevice -AccountId 123 -DeviceId "device-abc-123"
```

### Example 2: Sync all non-compliant devices

```powershell
Get-NMMDevice -AccountId 123 |
    Where-Object { $_.complianceState -eq 'NonCompliant' } |
    ForEach-Object { Sync-NMMDevice -AccountId 123 -DeviceId $_.deviceId }
```

## Outputs

**PSCustomObject**

| Property | Type | Description |
|----------|------|-------------|
| success | Boolean | Sync initiated |
| message | String | Status message |

## Notes

- Sync is asynchronous; use `Get-NMMDevice` to check updated status
- Rate limits may apply for bulk sync operations

## Related Links

- [Get-NMMDevice](Get-NMMDevice.md)
- [Get-NMMDeviceCompliance](Get-NMMDeviceCompliance.md)
