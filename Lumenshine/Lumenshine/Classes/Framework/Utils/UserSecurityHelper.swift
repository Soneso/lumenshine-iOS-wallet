//
//  UserSecurityHelper.swift
//  Lumenshine
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
            
            let mnemonic = stellarsdk.Wallet.generate24WordMnemonic()
            let mnemonicWords = mnemonic.components(separatedBy:" ")            
            var mnemonicBytes = Array<UInt8>()
            mnemonicWords.forEach {
                if let index = wordList.index(of: $0) {
                    mnemonicBytes.append(UInt8(index >> 8 & 0x00ff))
                    mnemonicBytes.append(UInt8(index & 0x00ff))
                }
            }

            let mnemonicEncryptionIV = CryptoUtil.generateIV()
            let encryptedMnemonic = try CryptoUtil.encryptValue(plainValue: mnemonicBytes, key: mnemonicMasterKey, iv: mnemonicEncryptionIV)
            
            // generate public keys
            let publicKeyIndex0 = try stellarsdk.Wallet.createKeyPair(mnemonic: mnemonic, passphrase: nil, index: 0).accountId
            let publicKeyIndex188 = try stellarsdk.Wallet.createKeyPair(mnemonic: mnemonic, passphrase: nil, index: 188).accountId
            
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
    
    static func decryptUserSecurity(_ userSecurity: UserSecurity, password: String) throws -> DecryptedUserData? {
        do {
            let derivedPassword = CryptoUtil.deriveKeyPbkdf2(password: password, salt: userSecurity.passwordKdfSalt)
            
            let wordListMasterKey = try CryptoUtil.decryptValue(encryptedValue: userSecurity.encryptedWordListMasterKey, key: derivedPassword, iv: userSecurity.wordListMasterKeyEncryptionIV)
            let wordListCsvBytes = try CryptoUtil.decryptValue(encryptedValue: userSecurity.encryptedWordList, key: wordListMasterKey, iv: userSecurity.wordListEncryptionIV)
            
            guard let wordList = String(data: Data(bytes: wordListCsvBytes), encoding: .utf8)?.trimmed.components(separatedBy: ",") else { return nil }
            
            let mnemonicMasterKey = try CryptoUtil.decryptValue(encryptedValue: userSecurity.encryptedMnemonicMasterKey, key: derivedPassword, iv: userSecurity.mnemonicMasterKeyEncryptionIV)
            let mnemonicBytes = try CryptoUtil.decryptValue(encryptedValue: userSecurity.encryptedMnemonic, key: mnemonicMasterKey, iv: userSecurity.mnemonicEncryptionIV)
            
            if mnemonicBytes.count != 48 { return nil }
            
            var mnemonic = ""
            for i in 0..<mnemonicBytes.count/2 {
                let a = UInt16(mnemonicBytes[i*2])
                let b = UInt16(mnemonicBytes[i*2+1])
                let index = Int((a << 8) + b)
                
                if index >= 0, index < wordList.count {
                    mnemonic.append(wordList[index] + " ")
                }
            }
            mnemonic.removeLast()
            
            let publicKeyIndex0 = try stellarsdk.Wallet.createKeyPair(mnemonic: mnemonic, passphrase: nil, index: 0).accountId
            if publicKeyIndex0 != userSecurity.publicKeyIndex0 { return nil }
            
            let publicKeyIndex188 = try stellarsdk.Wallet.createKeyPair(mnemonic: mnemonic, passphrase: nil, index: 188).accountId
            
//            print("Start public: \(Date())")
//            var publicKeys = Array<String>()
//            for index in 1...50 {
//                let publicKeyIndex = try stellarsdk.Wallet.createKeyPair(mnemonic: mnemonic, passphrase: nil, index: index).accountId
//                publicKeys.append(publicKeyIndex)
//            }
//
//            print("Finish public: \(Date())")
            
            return DecryptedUserData(mnemonic: mnemonic,
                                     publicKeyIndex188: publicKeyIndex188,
                                     wordListMasterKey: wordListMasterKey,
                                     mnemonicMasterKey: mnemonicMasterKey,
                                     publicKeys: nil)
            
        } catch {
            throw error
        }
    }
}
