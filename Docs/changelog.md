# Changelog

All notable changes to NMM-PS will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Certificate-based authentication support
  - `New-NMMApiCertificate` cmdlet for creating self-signed certificates
  - Certificate thumbprint and PFX file authentication in `Connect-NMMApi`
  - Cross-platform support (Windows and macOS)
- MkDocs documentation site with Nerdio branding
- 60+ cmdlets for NMM API operations

### Changed

- Renamed `Upload-CertificateToAzureAD` to `Publish-CertificateToAzureAD` for PowerShell verb compliance

### Fixed

- Cross-platform certificate handling on macOS/.NET Core
- RSA private key extraction compatibility across platforms

## [1.0.0] - Initial Release

### Added

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
| Unreleased | - | Certificate auth, documentation site |
| 1.0.0 | - | Initial release with 60+ cmdlets |
