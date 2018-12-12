//
//  DecryptedUserData.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public struct DecryptedUserData {
    let mnemonic: String
    let wordListMasterKey: Array<UInt8>
    let mnemonicMasterKey: Array<UInt8>
    let publicKeys: Array<String>?
}
