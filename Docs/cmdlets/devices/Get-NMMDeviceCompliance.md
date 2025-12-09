# Get-NMMDeviceCompliance

Gets device compliance status.

## Syntax

```powershell
Get-NMMDeviceCompliance
    -AccountId <Int32>
    -DeviceId <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMDeviceCompliance` cmdlet retrieves Intune compliance policy status for a device.

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

### Example 1: Get compliance status

```powershell
Get-NMMDeviceCompliance -AccountId 123 -DeviceId "device-abc-123"
```

## Outputs

**PSCustomObject**

| Property | Type | Description |
|----------|------|-------------|
| overallStatus | String | Compliant, NonCompliant |
| policies | Object[] | Applied policies |
| lastEvaluated | DateTime | Last evaluation |

## Related Links

- [Get-NMMDevice](Get-NMMDevice.md)
