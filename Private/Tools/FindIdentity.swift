#!/usr/bin/env swift
// FindIdentity.swift - Query identities from keychain (including data protection keychain)

import Foundation
import Security
import CommonCrypto

let thumbprintToFind = CommandLine.arguments.count > 1 ? CommandLine.arguments[1].uppercased() : nil

// Query all identities
let query: [String: Any] = [
    kSecClass as String: kSecClassIdentity,
    kSecMatchLimit as String: kSecMatchLimitAll,
    kSecReturnRef as String: true
]

var result: CFTypeRef?
let status = SecItemCopyMatching(query as CFDictionary, &result)

if status == errSecSuccess, let identities = result as? [SecIdentity] {
    print("Found \(identities.count) identity/identities:")

    for (index, identity) in identities.enumerated() {
        var certRef: SecCertificate?
        SecIdentityCopyCertificate(identity, &certRef)

        if let cert = certRef {
            let subject = SecCertificateCopySubjectSummary(cert) as String? ?? "Unknown"
            let certData = SecCertificateCopyData(cert) as Data
            var digest = [UInt8](repeating: 0, count: 20)
            _ = certData.withUnsafeBytes { CC_SHA1($0.baseAddress, CC_LONG(certData.count), &digest) }
            let thumbprint = digest.map { String(format: "%02X", $0) }.joined()

            let marker = (thumbprintToFind != nil && thumbprint == thumbprintToFind) ? " <-- MATCH" : ""
            print("  \(index + 1)) \(thumbprint) \"\(subject)\"\(marker)")
        }
    }
} else if status == errSecItemNotFound {
    print("No identities found in keychain")
} else {
    print("Error querying keychain: \(status)")
}
