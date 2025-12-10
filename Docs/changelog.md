# Changelog

All notable changes to NMM-PS will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2025-12-10

### Added

- **HTML Report System** - Comprehensive reporting framework with professional Nerdio branding
  - `New-NMMReport` - Generate HTML reports from any NMM data
  - `New-NMMReportSection` - Create report sections with tables, cards, and lists
  - `Get-NMMReportTemplate` - List available report templates
  - `Export-NMMReportData` - Export report data to JSON/CSV
  - `Invoke-NMMCompleteReport` - Generate complete environment reports
  - Built-in templates: HostPool, Device, Account, Custom
  - Executive summary with key metrics
  - Responsive design with dark/light theme support

- **API Endpoint Testing Framework** - Automated testing against Swagger specs
  - `Test-NMMApiEndpoint` - Test API endpoints with schema validation
  - Configurable endpoint list via `TestEndpoints.json`
  - Colored console output with Pass/Warning/Fail status
  - JSON export for CI/CD integration
  - Prepared for future PUT/POST/DELETE testing

- **macOS Keychain Certificate Support** - Enhanced certificate authentication
  - Support for `Source: Keychain` in configuration
  - Fallback to PFX when Keychain private key association fails (common macOS issue)
  - Improved error messages with troubleshooting guidance

### Changed

- Documentation site CSS adjustments for better readability
  - Wider content area (70rem max-width)
  - Narrower TOC sidebar
  - Fixed header logo visibility on dark background

### Fixed

- macOS certificate import private key association detection
- Keychain identity lookup with helpful fallback mechanism

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
