//
//  UserSecurity.swift
//  Stellargate
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
