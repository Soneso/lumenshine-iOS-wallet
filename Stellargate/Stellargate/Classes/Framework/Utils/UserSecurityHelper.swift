//
//  UserSecurityHelper.swift
//  Stellargate
//
//  Created by Istvan Elekes on 5/10/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import stellarsdk

struct UserSecurityHelper {
    static func generateUserSecurity(email: String, password: String) throws -> UserSecurity {
        do {
            // generate 256 bit password and salt
            let passwordSalt = CryptoUtil.generateSalt()
            let derivedPassword = CryptoUtil.deriveKeyPbkdf2(password: password, salt: passwordSalt)
            
            let wordListMasterKey = CryptoUtil.generateMasterKey()
            let wordListMasterKeyEncryptionIV = CryptoUtil.generateIV()
            let encryptedWordListMasterKey = try CryptoUtil.encryptValue(plainValue: wordListMasterKey, key: derivedPassword, iv: wordListMasterKeyEncryptionIV)
            
            let wordList = WordList.english.words.shuffled()
            
            let mnemonicMasterKey = CryptoUtil.generateMasterKey()
            let mnemonicMasterKeyEncryptionIV = CryptoUtil.generateIV()
            let encryptedMnemonicMasterKey = try CryptoUtil.encryptValue(plainValue: mnemonicMasterKey, key: derivedPassword, iv: mnemonicMasterKeyEncryptionIV)
            
            let mnemonic = Wallet.generate24WordMnemonic()
            let mnemonicWords = mnemonic.components(separatedBy:" ")
            let mnemonicIndices = mnemonicWords.map { (word) -> UInt16 in
                if let index = wordList.index(of: word) {
                    return UInt16(index)
                }
                return UInt16(0)
            }
            let mnemonicData = Data(bytes: UnsafePointer(mnemonicIndices), count: 2*mnemonicIndices.count)

            let mnemonicEncryptionIV = CryptoUtil.generateIV()
            let encryptedMnemonic = try CryptoUtil.encryptValue(plainValue: mnemonicData.bytes, key: mnemonicMasterKey, iv: mnemonicEncryptionIV)
            
            // generate public keys
            let publicKeyIndex0 = try Wallet.createKeyPair(mnemonic: mnemonic, passphrase: nil, index: 0).accountId
            let publicKeyIndex188 = try Wallet.createKeyPair(mnemonic: mnemonic, passphrase: nil, index: 188).accountId
            
            let words = wordList.joined(separator: ",")
            
            let wordListEncryptionIV = CryptoUtil.generateIV()
            let wordListBytes = CryptoUtil.padToBlocks(source: words).bytes
            let encryptedWordList = try CryptoUtil.encryptValue(plainValue: wordListBytes, key: wordListMasterKey, iv: wordListEncryptionIV)
            
            return UserSecurity(username: email,
                                publicKeyIndex0: publicKeyIndex0,
                                publicKeyIndex188: publicKeyIndex188,
                                passwordKdfSalt: passwordSalt,
                                encryptedMnemonicMasterKey: encryptedMnemonicMasterKey,
                                mnemonicMasterKeyEncryptionIV: mnemonicMasterKeyEncryptionIV,
                                encryptedMnemonic: encryptedMnemonic,
                                mnemonicEncryptionIV: mnemonicEncryptionIV,
                                encryptedWordListMasterKey: encryptedWordListMasterKey,
                                wordListMasterKeyEncryptionIV: wordListMasterKeyEncryptionIV,
                                encryptedWordList: encryptedWordList,
                                wordListEncryptionIV: wordListEncryptionIV,
                                mnemonic24Word: mnemonic)
        } catch {
            throw error
        }
    }
    
    static func decryptUserSecurity(_ userSecurity: UserSecurity, password: String) throws -> String? {
        do {
            let derivedPassword = CryptoUtil.deriveKeyPbkdf2(password: password, salt: userSecurity.passwordKdfSalt)
            
            let wordListMasterKey = try CryptoUtil.decryptValue(encryptedValue: userSecurity.encryptedWordListMasterKey, key: derivedPassword, iv: userSecurity.wordListMasterKeyEncryptionIV)
            let wordListCsvBytes = try CryptoUtil.decryptValue(encryptedValue: userSecurity.encryptedWordList, key: wordListMasterKey, iv: userSecurity.wordListEncryptionIV)
            
            guard let wordList = String(data: Data(bytes: wordListCsvBytes), encoding: .utf8)?.trimmed.components(separatedBy: ",") else { return nil }
            
            let mnemonicMasterKey = try CryptoUtil.decryptValue(encryptedValue: userSecurity.encryptedMnemonicMasterKey, key: derivedPassword, iv: userSecurity.mnemonicMasterKeyEncryptionIV)
            let mnemonicBytes = try CryptoUtil.decryptValue(encryptedValue: userSecurity.encryptedMnemonic, key: mnemonicMasterKey, iv: userSecurity.mnemonicEncryptionIV)
            
            if mnemonicBytes.count != 48 { return nil }
            
            let mnemonicIndices: Array<UInt16> = Data(bytes: mnemonicBytes).toArray(type: UInt16.self)
            
            var mnemonic = ""
            mnemonicIndices.forEach {
                let index = Int($0)
                if index >= 0, index < wordList.count {
                    mnemonic.append(wordList[index] + " ")
                }
            }
            mnemonic.removeLast()
            
            let publicKeyIndex0 = try Wallet.createKeyPair(mnemonic: mnemonic, passphrase: nil, index: 0).accountId
            if publicKeyIndex0 != userSecurity.publicKeyIndex0 { return nil }
            
            let publicKeyIndex188 = try Wallet.createKeyPair(mnemonic: mnemonic, passphrase: nil, index: 188).accountId
            
            return publicKeyIndex188
            
        } catch {
            throw error
        }
    }
}

extension Data {
    
    func toArray<T>(type: T.Type) -> [T] {
        return self.withUnsafeBytes {
            [T](UnsafeBufferPointer(start: $0, count: self.count/MemoryLayout<T>.stride))
        }
    }
}
