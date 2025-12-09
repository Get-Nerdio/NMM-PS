# Get-NMMDeviceBitLocker

Gets BitLocker recovery keys for a device.

## Syntax

```powershell
Get-NMMDeviceBitLocker
    -AccountId <Int32>
    -DeviceId <String>
    [<CommonParameters>]
```

## Description

The `Get-NMMDeviceBitLocker` cmdlet retrieves BitLocker recovery keys for an Intune-managed device.

!!! warning "Beta API"
    This cmdlet uses the v1-beta API.

!!! danger "Sensitive Data"
    This cmdlet returns sensitive recovery keys. Ensure proper access controls and audit logging.

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

### Example 1: Get BitLocker keys

```powershell
Get-NMMDeviceBitLocker -AccountId 123 -DeviceId "device-abc-123"
```

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| keyId | String | Key identifier |
| recoveryKey | String | Recovery key value |
| driveLetter | String | Associated drive |
| createdDateTime | DateTime | Key creation date |

## Notes

- Requires appropriate permissions to access BitLocker data
- Key retrieval is typically audited

## Related Links

- [Get-NMMDevice](Get-NMMDevice.md)
- [Get-NMMDeviceLAPS](Get-NMMDeviceLAPS.md)
