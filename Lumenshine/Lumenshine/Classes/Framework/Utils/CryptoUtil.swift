//
//  CryptoUtil.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 4/18/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import stellarsdk

public class CryptoUtil {
    
    private static let KEY_LENGTH = 256 / 8
    private static let IV_LENGTH = 16
    private static var SALT_LENGTH: Int {
        return KEY_LENGTH
    }
    private static let PBE_ITERATION_COUNT = 65000
    private static let PBKDF2_DERIVATION_ALGORITHM = "PBKDF2WithHmacSHA1"
    private static let CIPHER_ALGORITHM = "AES/CBC/NoPadding"
    
    static func decryptValue(encryptedValue: Array<UInt8>, key: Array<UInt8>, iv: Array<UInt8>) throws -> Array<UInt8> {
        
        var result = Array<UInt8>()
        let aes = try AES(key: key, blockMode: .CBC(iv: iv), padding: .noPadding)
        result = try aes.decrypt(encryptedValue)
        return result
    }
    
    public static func encryptValue(plainValue: Array<UInt8>, key: Array<UInt8>, iv: Array<UInt8>) throws -> Array<UInt8> {
        
        var result = Array<UInt8>()
        let aes = try AES(key: key, blockMode: .CBC(iv: iv), padding: .noPadding)
        result = try aes.encrypt(plainValue)
        return result
    }
    
    static func generateIV() -> Array<UInt8> {
        var randomIV: Array<UInt8> = Array<UInt8>()
        randomIV.reserveCapacity(IV_LENGTH)
        for randomByte in RandomBytesSequence(size: IV_LENGTH) {
            randomIV.append(randomByte)
        }
        return randomIV
    }
    
    static func generateSalt() -> Array<UInt8> {
        var randomSalt: Array<UInt8> = Array<UInt8>()
        randomSalt.reserveCapacity(SALT_LENGTH)
        for randomByte in RandomBytesSequence(size: SALT_LENGTH) {
            randomSalt.append(randomByte)
        }
        return randomSalt
    }
    
    static func generateMasterKey() -> Array<UInt8> {
        
        let byteCount = KEY_LENGTH
        var bytes = Data(count: byteCount)
        _ = bytes.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, byteCount, $0) }
        
        return bytes.bytes
    }
    
    static func deriveKeyPbkdf2(password: String, salt: Array<UInt8>) -> Array<UInt8> {
        let output: [UInt8]
        do {
            // TODO: check variant param
            output = try PKCS5.PBKDF2(password: password.bytes, salt: salt, iterations: PBE_ITERATION_COUNT, keyLength: KEY_LENGTH, variant: .sha1).calculate()
        } catch let error {
            fatalError("PKCS5.PBKDF2 faild: \(error.localizedDescription)")
        }
        
        return output
    }
    
    public static func padToBlocks(blockSize: Int = 16, source: String) -> String {
        var result = source
        
        var extensionLength = 0
        if result.count % blockSize != 0 {
            extensionLength = (result.count/blockSize + 1) * blockSize - result.count
        }
        
        if extensionLength > 0 {
            for _ in 1...extensionLength {
                result.append(" ")
            }
        }
        return result
    }
    
    static func applyPadding(blockSize: Int, source: Array<UInt8>) -> Array<UInt8> {
        var result = source
        result.append(0x80)
        
        var extensionLength = 0
        if result.count % blockSize != 0 {
            extensionLength = (result.count/blockSize + 1) * blockSize - result.count
        }
        
        if extensionLength > 0 {
            for _ in 1...extensionLength {
                result.append(0x00)
            }
        }
        return result
    }
}
