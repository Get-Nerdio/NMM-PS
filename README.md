![image](https://github.com/Get-Nerdio/NMM-SE/assets/52416805/5c8dd05e-84a7-49f9-8218-64412fdaffaf)

# NMM-PS Module

## This module is not yet available on the PowerShell Gallery, use at your own risk.

### How to use

1. Manually download the zip from this repository and extract it to a folder of your choice.
2. Or run the following command in a Powershell 7.4+ terminal: ``` iex ($(irm https://raw.githubusercontent.com/Get-Nerdio/NMM-PS/main/Install.ps1?v=1)) ```

**Keep in mind that this will extract the module to the current directory and import it.**

(Module will be available in the near future on the PowerShell Gallery)

## Quick start how to setup and use the API

- Getting started with the NMM API check the official docs here [NMM API Docs](https://nmmhelp.getnerdio.com/hc/en-us/articles/26125597051277-Nerdio-Manager-Distributor-API-Getting-Started)
- Make sure you save the API credentials here: Private/Data/ConfigData.json

  **Setup Config file -> ConfigData.json**

```json
{
    "BaseUri": "https://api.yournmmdomain.com",
    "TenantId": "your-tenant-id",
    "ClientId": "your-client-id",
    "Scope": "111111-111-1111-11111-1111111111/.default",
    "Secret": "your-secret"
}
```
More details will be provided in the future.. like better credential storage in Azurekeyvault

For bulk enrollment of customers in Partner Center see the documentation in the [Bulk Enroll PartnerCenter.md](Bulk%20Enroll%20PartnerCenter.md) file.


### What You Can Find Here

This repository contains a PowerShell module that provides cmdlets to interact with the Nerdio Manager for MSP API. The module is designed to help automate various tasks and operations within the Nerdio Manager for MSP platform. The cmdlets can be used to perform a wide range of functions, such as managing users, groups, policies, and resources, as well as retrieving data and generating reports.

**Please Note:**

This repository is a collaborative space and not a product with a defined roadmap or delivery schedule. There is no commitment to develop specific solutions or scripts, and what is available has been shared to potentially assist with various needs. The contributions are spontaneous and based on individual insights and experiences of our Sales Engineers. As such, new additions will appear as they are developed without a predefined timeline or obligation to provide updates.

### Disclaimer
While we strive to provide valuable and workable solutions, please note the following:

- **Best Effort Maintenance:** The scripts and documents in this repository are maintained on a best-effort basis by the contributing Sales Engineers. Updates and improvements may be made periodically, subject to the availability and capacity of the contributors.

- **No Official Support:** This repository is not an officially supported service of Nerdio. As such, Nerdio does not offer formal support for the tools and scripts shared here. Users are encouraged to review and test scripts thoroughly before deployment.

- **Limitation of Liability:** Nerdio is not responsible for any damages, issues, or negative outcomes that may result from the use of scripts from this repository. Users assume all risks associated with the use of these scripts.

### Contributing
We highly encourage contributions from the community! If you have a script or a tool that has been effective in your environment and you believe it could benefit others, please consider contributing. Here’s how you can do it:

- **Fork the Repository:** Start by forking the repository and making your modifications or additions.
- **Submit a Pull Request:** After you've made your changes, submit a pull request to the main branch. Please provide a detailed description of what the script does and any other information that might be helpful.
- **Code Review:** One of our Sales Engineers will review the submission. If everything checks out, it will be merged into the main repository.

### Getting Help

If you have questions or need assistance with any of the scripts found in this repository, please use the Issues section of this GitHub repository. This platform allows for community-driven support where users can interact, provide feedback, and suggest improvements.

**Please Be Aware:**

- **Unofficial Support:** This repository is not an officially supported product of Nerdio. Support and responses are provided on a best-effort basis by the community and the Sales Engineers who contribute.
- **Response Times:** Due to the unofficial nature of this repository, responses to support requests may take longer than typical professional support channels. We appreciate your patience and understanding.

We encourage you to actively participate in the community by sharing your experiences, solutions, and enhancements. Your contributions not only help others but also foster a collaborative environment for everyone’s benefit.

Thank you for visiting the NMM-SE repository. We look forward to seeing your contributions and hope you find the resources helpful!


