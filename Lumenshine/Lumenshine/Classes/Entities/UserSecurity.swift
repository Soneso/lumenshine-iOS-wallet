//
//  UserSecurity.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 4/18/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public struct UserSecurity {
    let username: String
    let publicKeyIndex0: String
    let publicKeyIndex188: String
    let passwordKdfSalt: Array<UInt8>
    let encryptedMnemonicMasterKey: Array<UInt8>
    let mnemonicMasterKeyEncryptionIV: Array<UInt8>
    let encryptedMnemonic: Array<UInt8>
    let mnemonicEncryptionIV: Array<UInt8>
    let encryptedWordListMasterKey: Array<UInt8>
    let wordListMasterKeyEncryptionIV: Array<UInt8>
    let encryptedWordList: Array<UInt8>
    let wordListEncryptionIV: Array<UInt8>
    let mnemonic24Word: String
    
}

extension UserSecurity {
    
    init?(from loginResponse: LoginStep1Response) {
        username = ""
        publicKeyIndex188 = ""
        mnemonic24Word = ""
        
        publicKeyIndex0 = loginResponse.publicKeyIndex0
        
        guard let kdfSaltData = Data(base64Encoded: loginResponse.kdfPasswordSalt) else { return nil }
        passwordKdfSalt = kdfSaltData.bytes
        
        guard let encryptedMnemonicMasterKeyData = Data(base64Encoded: loginResponse.encryptedMnemonicMasterKey) else { return nil }
        encryptedMnemonicMasterKey = encryptedMnemonicMasterKeyData.bytes
        
        guard let mnemonicMasterKeyEncryptionIVData = Data(base64Encoded: loginResponse.mnemonicMasterKeyEncryptionIV) else { return nil }
        mnemonicMasterKeyEncryptionIV = mnemonicMasterKeyEncryptionIVData.bytes
        
        guard let encryptedMnemonicData = Data(base64Encoded: loginResponse.encryptedMnemonic) else { return nil }
        encryptedMnemonic = encryptedMnemonicData.bytes
        
        guard let mnemonicEncryptionIVData = Data(base64Encoded: loginResponse.mnemonicEncryptionIV) else { return nil }
        mnemonicEncryptionIV = mnemonicEncryptionIVData.bytes
        
        guard let encryptedWordListMasterKeyData = Data(base64Encoded: loginResponse.encryptedWordlistMasterKey) else { return nil }
        encryptedWordListMasterKey = encryptedWordListMasterKeyData.bytes
        
        guard let wordListMasterKeyEncryptionIVData = Data(base64Encoded: loginResponse.wordlistMasterKeyEncryptionIV) else { return nil }
        wordListMasterKeyEncryptionIV = wordListMasterKeyEncryptionIVData.bytes
        
        guard let encryptedWordListData = Data(base64Encoded: loginResponse.encryptedWordlist) else { return nil }
        encryptedWordList = encryptedWordListData.bytes
        
        guard let wordListEncryptionIVData = Data(base64Encoded: loginResponse.wordlistEncryptionIV) else { return nil }
        wordListEncryptionIV = wordListEncryptionIVData.bytes
    }
}
