//
//  DecryptedUserData.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 8/8/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public struct DecryptedUserData {
    let mnemonic: String
    let wordListMasterKey: Array<UInt8>
    let mnemonicMasterKey: Array<UInt8>
    let publicKeys: Array<String>?
}
