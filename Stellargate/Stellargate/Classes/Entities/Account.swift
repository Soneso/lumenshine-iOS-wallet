//
//  Account.swift
//  Stellargate
//
//  Created by Istvan Elekes on 4/18/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public struct Account {
    let publicKeyIndex0: String
    let publicKeyIndex188: String
    public let passwordSalt: Array<UInt8>
    public let encryptedMasterKey: Array<UInt8>
    public let masterKeyIV: Array<UInt8>
    public let encryptedMnemonic: Array<UInt8>
    public let mnemonicIV: Array<UInt8>
}
