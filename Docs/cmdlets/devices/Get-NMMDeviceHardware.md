# Get-NMMDeviceHardware

Gets hardware information for a device.

## Syntax

```powershell
Get-NMMDeviceHardware
    -AccountId <Int32>
    -DeviceId <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMDeviceHardware` cmdlet retrieves hardware specifications for an Intune-managed device.

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

### Example 1: Get hardware info

```powershell
Get-NMMDeviceHardware -AccountId 123 -DeviceId "device-abc-123"
```

## Outputs

**PSCustomObject**

| Property | Type | Description |
|----------|------|-------------|
| manufacturer | String | Device manufacturer |
| model | String | Device model |
| serialNumber | String | Serial number |
| totalMemory | Int64 | RAM in bytes |
| totalStorage | Int64 | Storage in bytes |
| processorType | String | CPU model |

## Related Links

- [Get-NMMDevice](Get-NMMDevice.md)
