# Get-NMMAccount

Lists or retrieves NMM accounts.

## Syntax

```powershell
Get-NMMAccount
    [-AccountId <Int32>]
    [-Name <String>]
    [<CommonParameters>]
```

## Description

The `Get-NMMAccount` cmdlet retrieves NMM accounts. Without parameters, it returns all accounts. Use `-AccountId` to get a specific account or `-Name` to filter by name pattern.

## Parameters

### -AccountId

The ID of a specific account to retrieve.

| | |
|---|---|
| Type | Int32 |
| Required | False |
| Aliases | id |

### -Name

Filter accounts by name (supports wildcards).

| | |
|---|---|
| Type | String |
| Required | False |

## Examples

### Example 1: Get all accounts

```powershell
Get-NMMAccount
```

Returns all NMM accounts.

### Example 2: Get specific account by ID

```powershell
Get-NMMAccount -AccountId 123
```

### Example 3: Filter by name

```powershell
Get-NMMAccount -Name "Contoso*"
```

Returns accounts with names starting with "Contoso".

## Outputs

**PSCustomObject[]**

| Property | Type | Description |
|----------|------|-------------|
| id | Int32 | Account ID |
| name | String | Account name |
| tenantId | String | Azure AD tenant ID |
| subscriptionId | String | Azure subscription ID |

## Notes

- This cmdlet is typically the starting point for pipeline operations
- Account IDs are required for most other cmdlets

## Related Links

- [Get-NMMHostPool](../hostpools/Get-NMMHostPool.md)
