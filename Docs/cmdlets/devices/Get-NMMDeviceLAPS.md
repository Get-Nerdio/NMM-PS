# Get-NMMDeviceLAPS

Gets the local administrator password for a device.

## Syntax

```powershell
Get-NMMDeviceLAPS
    -AccountId <Int32>
    -DeviceId <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMDeviceLAPS` cmdlet retrieves the Local Administrator Password Solution (LAPS) password for an Intune-managed device.

!!! warning "Beta API"
    This cmdlet uses the v1-beta API.

!!! danger "Sensitive Data"
    This cmdlet returns sensitive credential information. Ensure proper access controls and audit logging.

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

### Example 1: Get LAPS password

```powershell
Get-NMMDeviceLAPS -AccountId 123 -DeviceId "device-abc-123"
```

## Outputs

**PSCustomObject**

| Property | Type | Description |
|----------|------|-------------|
| password | SecureString | Admin password |
| passwordExpirationTime | DateTime | Password expiry |
| accountName | String | Admin account name |

## Notes

- Requires appropriate permissions to access LAPS data
- Password retrieval is typically audited

## Related Links

- [Get-NMMDevice](Get-NMMDevice.md)
- [Get-NMMDeviceBitLocker](Get-NMMDeviceBitLocker.md)
