#!/usr/bin/env swift
// ExportIdentity.swift - Export identity from keychain to temp PFX
// Usage: ExportIdentity <thumbprint> <output_pfx_path> <password>

import Foundation
import Security
import CommonCrypto

guard CommandLine.arguments.count >= 4 else {
    print("ERROR:Usage: ExportIdentity <thumbprint> <output_path> <password>")
    exit(1)
}

let thumbprintToFind = CommandLine.arguments[1].uppercased()
let outputPath = CommandLine.arguments[2]
let password = CommandLine.arguments[3]

// Query all identities from keychain
let query: [String: Any] = [
    kSecClass as String: kSecClassIdentity,
    kSecMatchLimit as String: kSecMatchLimitAll,
    kSecReturnRef as String: true
]

var result: CFTypeRef?
let status = SecItemCopyMatching(query as CFDictionary, &result)

guard status == errSecSuccess, let identities = result as? [SecIdentity] else {
    print("ERROR:No identities found or query failed (\(status))")
    exit(1)
}

// Find matching identity by thumbprint
var matchedIdentity: SecIdentity?
var matchedCert: SecCertificate?

for identity in identities {
    var certRef: SecCertificate?
    SecIdentityCopyCertificate(identity, &certRef)

    if let cert = certRef {
        let certData = SecCertificateCopyData(cert) as Data
        var digest = [UInt8](repeating: 0, count: 20)
        _ = certData.withUnsafeBytes { CC_SHA1($0.baseAddress, CC_LONG(certData.count), &digest) }
        let thumbprint = digest.map { String(format: "%02X", $0) }.joined()

        if thumbprint == thumbprintToFind {
            matchedIdentity = identity
            matchedCert = cert
            break
        }
    }
}

guard let identity = matchedIdentity, let cert = matchedCert else {
    print("ERROR:Identity with thumbprint \(thumbprintToFind) not found")
    exit(1)
}

// Get certificate subject for output
let subject = SecCertificateCopySubjectSummary(cert) as String? ?? "Unknown"

// Export to PKCS12 using the identity's private key and certificate
// We'll manually build PKCS12 data
var privateKey: SecKey?
SecIdentityCopyPrivateKey(identity, &privateKey)

guard let key = privateKey else {
    print("ERROR:Could not extract private key from identity")
    exit(1)
}

// Use SecItemExport for the identity
var exportData: CFData?
var exportParams = SecItemImportExportKeyParameters()
exportParams.passphrase = Unmanaged.passRetained(password as CFString)

let exportStatus = SecItemExport(
    identity,
    .formatPKCS12,
    [],
    &exportParams,
    &exportData
)

if exportStatus == errSecSuccess, let data = exportData as Data? {
    do {
        try data.write(to: URL(fileURLWithPath: outputPath))
        print("SUCCESS:\(thumbprintToFind):\(subject)")
    } catch {
        print("ERROR:Failed to write file: \(error)")
        exit(1)
    }
} else {
    print("ERROR:SecItemExport failed (\(exportStatus))")
    exit(1)
}
