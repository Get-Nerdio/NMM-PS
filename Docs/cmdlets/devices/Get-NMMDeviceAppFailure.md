# Get-NMMDeviceAppFailure

Gets failed app installations on a device.

## Syntax

```powershell
Get-NMMDeviceAppFailure
    -AccountId <Int32>
    -DeviceId <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMDeviceAppFailure` cmdlet retrieves applications that failed to install on an Intune-managed device.

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

### Example 1: Get failed installations

```powershell
Get-NMMDeviceAppFailure -AccountId 123 -DeviceId "device-abc-123"
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| appName | String | Application name |
| errorCode | String | Error code |
| errorMessage | String | Failure reason |
| attemptedOn | DateTime | Last attempt |

## Related Links

- [Get-NMMDevice](Get-NMMDevice.md)
- [Get-NMMDeviceApp](Get-NMMDeviceApp.md)
