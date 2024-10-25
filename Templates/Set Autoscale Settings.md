![image](https://github.com/Get-Nerdio/NMM-SE/assets/52416805/5c8dd05e-84a7-49f9-8218-64412fdaffaf)

# Set Autoscale Settings

Below is an example powershell snippet of how to set the autoscale settings for a hostpool.


```powershell
# Example scaling triggers
$scalingTriggers = [System.Collections.Generic.List[hashtable]]::new()

# CPU Usage trigger
$scalingTriggers.Add(@{
    triggerType = "CPUUsage"
    cpu = @{
        scaleOut = @{
            averageTimeRangeInMinutes = 5
            hostChangeCount = 1
            value = 65
        }
        scaleIn = @{
            averageTimeRangeInMinutes = 15
            hostChangeCount = 1
            value = 40
        }
    }
})

# VM Template
$vmTemplate = @{
    prefix             = "API{###}"
    size               = "Standard_D2s_v3"
    image              = "MicrosoftWindowsDesktop/Windows-11/win11-22h2-avd/latest"
    storageType        = "StandardSSD_LRS"
    resourceGroupId    = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/ExampleRG"
    networkId          = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/ExampleRG/providers/Microsoft.Network/virtualNetworks/ExampleVnet"
    diskSize           = 128
    hasEphemeralOSDisk = $false
}

# Set autoscale configuration
$autoScaleParams = @{
    AccountId            = "12345"
    SubscriptionId       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    ResourceGroup        = "ExampleRG"
    PoolName             = "Example-Hostpool"
    EnableAutoScale      = $false
    ScalingMode          = "Default"
    VmTemplate           = $vmTemplate
    HostPoolCapacity     = 1
    MinActiveHostsCount  = 0
    BurstCapacity        = 0
    ScalingTriggers      = $scalingTriggers
    Verbose              = $true
}

Set-AutoScale @autoScaleParams

```
Some other trigger examples are below.

```powershell
# User Driven trigger
$scalingTriggers.Add(@{
    triggerType = "UserDriven"
    userDriven = @{
        scaleOut = @{
            hostChangeCount = 1
            value = 2
        }
        scaleIn = @{
            hostChangeCount = 1
            value = 1
        }
    }
})

# AvgActiveSessions trigger example
$scalingTriggers.Add(@{
    triggerType = "AvgActiveSessions"
    averageActiveSessions = @{
        scaleOut = @{
            hostChangeCount = 1
            value = 10
        }
        scaleIn = @{
            hostChangeCount = 1
            value = 5
        }
    }
})
```