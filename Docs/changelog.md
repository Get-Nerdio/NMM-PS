# Changelog

All notable changes to NMM-PS will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2025-12-10

### Added

- **HTML Report System** - Comprehensive reporting framework with professional Nerdio branding
  - `New-NMMReport` - Initialize multi-section report builder
  - `Add-NMMReportSection` - Add data sections with optional charts
  - `Export-NMMReport` - Generate final HTML output
  - `ConvertTo-NMMHtmlReport` - Simple pipeline to HTML conversion
  - `Add-NMMTypeName` - Tag custom data with PSTypeName for template matching
  - `Invoke-NMMReport` - Pre-built reports with interactive menu (AccountOverview, DeviceInventory, SecurityCompliance, Infrastructure)
  - Built-in templates: HostPool, Host, Device, Account, User, Backup, DesktopImage
  - ApexCharts integration (bar, pie, donut, line, area)
  - DataTables.js for searchable, sortable tables
  - Responsive design with dark/light theme support

- **API Endpoint Testing Framework** - Automated testing against Swagger specs
  - `Test-NMMApiEndpoint` - Test API endpoints with schema validation
  - Configurable endpoint list via `TestEndpoints.json`
  - Colored console output with Pass/Warning/Fail status
  - JSON export for CI/CD integration
  - Prepared for future PUT/POST/DELETE testing

- **macOS Keychain Certificate Support** - Native Swift-based keychain access
  - Support for `Source: Keychain` in configuration
  - Swift helper tools for proper data protection keychain access
  - `ImportP12ToKeychain.swift` - Import P12 using modern SecItem API
  - `ExportIdentity.swift` - Export identity by thumbprint
  - `FindIdentity.swift` - Query identities from keychain
  - Works with both file-based and data protection keychains
  - Automatic fallback to PFX file when Swift unavailable

### Changed

- Documentation site CSS adjustments for better readability
  - Wider content area (70rem max-width)
  - Narrower TOC sidebar
  - Fixed header logo visibility on dark background

### Fixed

- macOS Keychain certificate authentication now fully functional
- Resolved data protection vs file-based keychain access issues
- `security find-identity` limitations bypassed with native Swift APIs

## [0.2.0] - 2025-12-08

### Added

- Certificate-based authentication support
  - `New-NMMApiCertificate` cmdlet for creating self-signed certificates
  - Certificate thumbprint and PFX file authentication in `Connect-NMMApi`
  - Cross-platform support (Windows and macOS)
- MkDocs documentation site with Nerdio branding
- CI/CD workflows for GitHub Actions
  - Automated testing on Windows, Ubuntu, and macOS
  - PSScriptAnalyzer code quality checks
  - PowerShell Gallery publishing on release
- `Get-NMMCommand` cmdlet for discovering available commands
- 60+ cmdlets for NMM API operations

### Changed

- Renamed `Upload-CertificateToAzureAD` to `Publish-CertificateToAzureAD` for PowerShell verb compliance

### Fixed

- Cross-platform certificate handling on macOS/.NET Core
- RSA private key extraction compatibility across platforms
- Invalid `ExternalModuleHelpFile` manifest key removed
- PSScriptAnalyzer warnings resolved

## [0.1.0] - 2024-05-01

### Added

- Initial module structure
- Core authentication with `Connect-NMMApi`
- Account management cmdlets
- Host pool management cmdlets
- Session host cmdlets
- Desktop image cmdlets
- User and group cmdlets
- Device management cmdlets (Beta API)
- Backup cmdlets
- Automation and scheduling cmdlets
- Pipeline support for chained operations
- Partner Center bulk enrollment support

---

## Version History Summary

| Version | Date | Highlights |
|---------|------|------------|
| 0.3.0 | 2025-12-10 | HTML reports, API testing framework, macOS Keychain support |
| 0.2.0 | 2025-12-08 | Certificate auth, documentation site, CI/CD |
| 0.1.0 | 2024-05-01 | Initial release with 60+ cmdlets |
