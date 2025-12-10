#!/usr/bin/env swift
// ImportP12ToKeychain.swift
// Modern macOS keychain import using data protection keychain (iOS-style API)
// Usage: ImportP12ToKeychain <p12_path> <password>

import Foundation
import Security
import CommonCrypto

guard CommandLine.arguments.count >= 3 else {
    print("ERROR:Usage: ImportP12ToKeychain <p12_path> <password>")
    exit(1)
}

let p12Path = CommandLine.arguments[1]
let password = CommandLine.arguments[2]

guard let p12Data = FileManager.default.contents(atPath: p12Path) else {
    print("ERROR:Cannot read file: \(p12Path)")
    exit(1)
}

// Step 1: Parse PKCS12 with SecPKCS12Import
let importOptions: [String: Any] = [kSecImportExportPassphrase as String: password]
var items: CFArray?
let importStatus = SecPKCS12Import(p12Data as CFData, importOptions as CFDictionary, &items)

guard importStatus == errSecSuccess else {
    print("ERROR:SecPKCS12Import failed: \(importStatus)")
    exit(1)
}

guard let itemArray = items as? [[String: Any]],
      let firstItem = itemArray.first,
      let identity = firstItem[kSecImportItemIdentity as String] else {
    print("ERROR:No identity in P12")
    exit(1)
}

let secIdentity = identity as! SecIdentity

// Get certificate info for output
var certRef: SecCertificate?
SecIdentityCopyCertificate(secIdentity, &certRef)

var thumbprint = "UNKNOWN"
var subject = "Unknown"

if let cert = certRef {
    subject = SecCertificateCopySubjectSummary(cert) as String? ?? "Unknown"
    let certData = SecCertificateCopyData(cert) as Data
    var digest = [UInt8](repeating: 0, count: 20)
    _ = certData.withUnsafeBytes { CC_SHA1($0.baseAddress, CC_LONG(certData.count), &digest) }
    thumbprint = digest.map { String(format: "%02X", $0) }.joined()
}

// Step 2: Add identity to data protection keychain (modern API)
var addQuery: [String: Any] = [
    kSecClass as String: kSecClassIdentity,
    kSecValueRef as String: secIdentity,
    kSecAttrLabel as String: subject,
    kSecUseDataProtectionKeychain as String: true  // Modern data protection keychain
]

var addStatus = SecItemAdd(addQuery as CFDictionary, nil)

// If data protection keychain fails, try without it (file-based keychain)
if addStatus == errSecParam || addStatus == errSecMissingEntitlement {
    addQuery.removeValue(forKey: kSecUseDataProtectionKeychain as String)
    addStatus = SecItemAdd(addQuery as CFDictionary, nil)
}

switch addStatus {
case errSecSuccess:
    print("SUCCESS:\(thumbprint):\(subject)")
case errSecDuplicateItem:
    print("SUCCESS:\(thumbprint):\(subject)")  // Already exists is fine
default:
    // Try adding key and cert separately as fallback
    var keyAdded = false
    var certAdded = false

    // Extract and add private key
    var privateKey: SecKey?
    SecIdentityCopyPrivateKey(secIdentity, &privateKey)

    if let key = privateKey {
        let keyQuery: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecValueRef as String: key,
            kSecAttrLabel as String: subject,
            kSecAttrApplicationTag as String: thumbprint.data(using: .utf8)!
        ]
        let keyStatus = SecItemAdd(keyQuery as CFDictionary, nil)
        keyAdded = (keyStatus == errSecSuccess || keyStatus == errSecDuplicateItem)
    }

    // Add certificate
    if let cert = certRef {
        let certQuery: [String: Any] = [
            kSecClass as String: kSecClassCertificate,
            kSecValueRef as String: cert,
            kSecAttrLabel as String: subject
        ]
        let certStatus = SecItemAdd(certQuery as CFDictionary, nil)
        certAdded = (certStatus == errSecSuccess || certStatus == errSecDuplicateItem)
    }

    if keyAdded && certAdded {
        print("SUCCESS:\(thumbprint):\(subject)")
    } else {
        print("ERROR:\(thumbprint):\(subject):Failed to add (\(addStatus))")
        exit(1)
    }
}
