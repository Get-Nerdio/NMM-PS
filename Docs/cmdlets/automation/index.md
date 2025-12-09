# Automation Cmdlets

Cmdlets for managing scripted actions, schedules, and autoscale profiles.

| Cmdlet | Description |
|--------|-------------|
| [Get-NMMScriptedAction](Get-NMMScriptedAction.md) | List scripted actions |
| [Get-NMMScriptedActionSchedule](Get-NMMScriptedActionSchedule.md) | Get scripted action schedules |
| [Get-NMMSchedule](Get-NMMSchedule.md) | List schedules |
| [Get-NMMScheduleConfig](Get-NMMScheduleConfig.md) | Get schedule configuration |
| [Get-NMMAutoscaleProfile](Get-NMMAutoscaleProfile.md) | Get autoscale profiles |

## Scope Parameter

Most automation cmdlets support the `-Scope` parameter:

- **Account**: Resources scoped to a specific account
- **Global**: Resources available across all accounts

```powershell
# Account-scoped scripted actions
Get-NMMScriptedAction -AccountId 123 -Scope Account

# Global scripted actions
Get-NMMScriptedAction -Scope Global
```
