![image](https://github.com/Get-Nerdio/NMM-SE/assets/52416805/5c8dd05e-84a7-49f9-8218-64412fdaffaf)

# Create Hostpool

Beneath is a powershell snippet where you can create a hostpool using the NMM-PS module.

```powershell

$usersToAssign = [System.Collections.Generic.List[string]]::new()
$usersToAssign.Add("00000000-0000-0000-0000-000000000000") # Example User

$groupsToAssign = [System.Collections.Generic.List[string]]::new()
$groupsToAssign.Add("11111111-1111-1111-1111-111111111111")  # Example Group

# Create the VM template hashtable Publisher: microsoftwindowsdesktop Offer: windows-11 SKU: win11-22h2-avd
$vmTemplate = @{
    prefix             = "API{###}"
    size               = "Standard_D2s_v3"
    image              = "MicrosoftWindowsDesktop/Windows-11/win11-22h2-avd/latest"
    storageType        = "StandardSSD_LRS"
    resourceGroupId    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/ExampleRG"
    networkId          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/ExampleNetworkRG/providers/Microsoft.Network/virtualNetworks/ExampleVNet"
    diskSize           = 128
    hasEphemeralOSDisk = $false
}

# Create the AD configuration hashtable
$adConfiguration = @{
    Type = 0  # Default
}

# Create the FSLogix configuration hashtable
$fsLogixConfiguration = @{
    Type               = 0  # Predefined
    #PredefinedConfigId = "22222222-2222-2222-2222-222222222222"  # Example GUID
}

# Create the parameter splat
$hostpoolParams = @{
    AccountId             = "00"
    Name                  = "Example-Hostpool"
    Description           = "Hostpool created using the NMM-PS module"
    WvdPoolUserExperience = "PooledMultiUserDesktop"
    # Remove AssignmentType for PooledMultiUserDesktop
    TimeZoneId            = "UTC"
    WorkspaceId           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/ExampleRG/providers/Microsoft.DesktopVirtualization/workspaces/Example Workspace"
    UsersToAssign         = $usersToAssign
    GroupsToAssign        = $groupsToAssign
    VmTemplate            = $vmTemplate
    AdConfiguration       = $adConfiguration
    FsLogixConfiguration  = $fsLogixConfiguration
    UseTrustedLaunch      = $true
}

# Call the function using splatting
New-Hostpool @hostpoolParams

```