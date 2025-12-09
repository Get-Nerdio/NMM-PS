# PSScriptAnalyzer settings for NMM-PS module
# https://docs.microsoft.com/en-us/powershell/utility-modules/psscriptanalyzer/using-scriptanalyzer

@{
    # Rules to exclude globally
    ExcludeRules = @(
        # ConvertTo-SecureString is required for OAuth client credentials flow
        # The secrets come from config files/environment, not hardcoded
        'PSAvoidUsingConvertToSecureStringWithPlainText',

        # Write-Host is intentionally used for colored console output in interactive cmdlets
        # (Get-NMMCommand, Connect-NMMHiddenApi, New-NMMApiCertificate, etc.)
        'PSAvoidUsingWriteHost',

        # Some plural nouns are intentional (Get-NMMUsers searches multiple users)
        'PSUseSingularNouns',

        # BOM encoding is not required for UTF-8 files
        'PSUseBOMForUnicodeEncodedFile',

        # ShouldProcess would require significant refactoring of New-*/Set-* cmdlets
        # Many are simple API wrappers or in-memory operations (New-JwtAssertion)
        # Deferring this improvement to avoid breaking changes
        'PSUseShouldProcessForStateChangingFunctions',

        # CredentialSource in Add-PartnerCenterAccounts is credential SOURCE selector, not password
        'PSAvoidUsingPlainTextForPassword',

        # ConvertTo-StructuredData pipeline support is complex to add safely
        # Reserved parameters ($Force) are common PowerShell patterns
        'PSUseProcessBlockForPipelineCommand',
        'PSReviewUnusedParameter'
    )

    # Severity levels to check
    Severity = @(
        'Error',
        'Warning'
    )

    # Rules with specific settings
    Rules = @{
        # Allow positional parameters for commonly used cmdlets
        PSAvoidUsingPositionalParameters = @{
            Enable = $true
            CommandAllowList = @(
                'Write-Output',
                'Write-Verbose',
                'Write-Warning',
                'Write-Error'
            )
        }

        # Require compatible syntax for PowerShell 7.0+
        PSUseCompatibleSyntax = @{
            Enable = $true
            TargetVersions = @('7.0')
        }
    }
}
