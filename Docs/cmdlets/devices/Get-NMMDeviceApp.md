# Get-NMMDeviceApp

Gets installed applications on a device.

## Syntax

```powershell
Get-NMMDeviceApp
    -AccountId <Int32>
    -DeviceId <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMDeviceApp` cmdlet retrieves applications installed on an Intune-managed device.

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

### Example 1: Get installed apps

```powershell
Get-NMMDeviceApp -AccountId 123 -DeviceId "device-abc-123"
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| appName | String | Application name |
| version | String | Installed version |
| publisher | String | App publisher |
| installState | String | Installed, Pending |

## Related Links

- [Get-NMMDevice](Get-NMMDevice.md)
- [Get-NMMDeviceAppFailure](Get-NMMDeviceAppFailure.md)
