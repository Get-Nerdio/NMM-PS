![image](https://github.com/Get-Nerdio/NMM-SE/assets/52416805/5c8dd05e-84a7-49f9-8218-64412fdaffaf)

# Bulk Enroll PartnerCenter

This function will allow you to bulk enroll customers from Partner Center to the Nerdio Manager for MSP. Keep in mind that currently the customers are only added in with Entra ID as domain and Intune/Modern Work as Desktop deployment model.

## Pre-Requisites

- Powershell 7.4 or higher
- Create a service account that is Global Admin in the tenant and add it as a member of the "Admin Agents" in the Entra Portal.
- Next make sure to login the first time with that account and setup MFA.
- Make sure all customers you want to onboard are  added in Partner Center to the "Customer List" (https://partner.microsoft.com/dashboard/v2/customers/list) and you have the correct GDAP roles rolled out (https://partner.microsoft.com/dashboard/v2/customers/granularadminaccess/list).

    Currently the assigned GDAP roles where i tested where are the ones below, keep in mind probably that consent with less permissions will work.
    - Application administrator, 
    - Authentication policy administrator, 
    - Cloud app security administrator, 
    - Cloud device administrator, 
    - Exchange administrator, 
    - Intune administrator, 
    - Privileged authentication administrator, 
    - Privileged role administrator, 
    - Security administrator, 
    - SharePoint administrator
    - Teams administrator, 
    - User administrator

- If you don't have a existing Secure Application, please create a new one with the following permissions, to make this process easier you can use the EasySAM module see the readme in the link below for instructions.

    Link to the module: https://github.com/freezscholte/EasySAM

    Needed permissions:

  - Azure Service Management
    - user_impersonation - Delegated

  - Microsoft Partner Center
    - user_impersonation - Delegated

  - Microsoft Graph
    - Application.ReadWrite.All - Delegated
    - Directory.ReadWrite.All - Delegated
    - Directory.AccessAsUser.All - Delegated

- Once the Application is created make sure to go to the application in the entra portal and Grant Admin Consent in the API permissions tab for the API permissions you have selected.
- Next is saving the output of the secure application model to the ConfigData.json in the SAM part of the json file in the Private/Data folder


## How to use

Once all prerequisites are met, you can use the Add-NerdioPartnerCenterCustomer cmdlet to add a customer to the Partner Center.

- Next import the NMM-PS module - `.\Import-Module NMM-PS.psm1`
- Run the following command to add the customers to the Partner Center.

Command for adding all customers in Partner Center (if GDAP roles are assigned properly):
```powershell
Import-Module NMM-PS
Add-PartnerCenterAccounts -Verbose
```
Command for adding a single customer to the Partner Center:

```powershell
$customers = [PSCustomObject]@{
    customerId = "8821ff3c-8b0d-4dd4-8813-39fca432cd19"
    displayName = "Skrok Lab Tenant 2"
}
Import-Module NMM-PS
Add-PartnerCenterAccounts -Customers $customers -Verbose
```
- Tip import the EasySAM and NMM-PS module in the same powershell session to make sure the global:SAMConfig variable is available. that way you can onboard all customers with you new app registration with the following command:

```powershell
Add-PartnerCenterAccounts -CredentialSource SAMConfig -SAMCredentials $samconfig -verbose

# the $samconfig is the output of the EasySAM module
```

 
