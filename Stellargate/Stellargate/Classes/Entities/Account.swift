//
//  Account.swift
//  Stellargate
//
//  Created by Istvan Elekes on 4/18/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

struct Account {
    let publicKeyIndex0: String
    let publicKeyIndex188: String
    let passwordSalt: Array<UInt8>
    let encryptedMasterKey: Array<UInt8>
    let masterKeyIV: Array<UInt8>
    let encryptedMnemonic: Array<UInt8>
    let mnemonicIV: Array<UInt8>
}
