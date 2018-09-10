//
//  PrivateKeyManager.swift
//  Lumenshine
//
//  Created by Soneso on 07/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import stellarsdk

class PrivateKeyManager {
    private static var walletsKeyPairs: [String: KeyPair] = [:]

    static func getWalletsKeyPairs(fromMnemonic mnemonic: String?) {
        if let mnemonic = mnemonic {
            let bip39Seed = Mnemonic.createSeed(mnemonic: mnemonic)
            let masterPrivateKey = Ed25519Derivation(seed: bip39Seed)
            let purpose = masterPrivateKey.derived(at: 44)
            let coinType = purpose.derived(at: 148)
            
            for index in 0..<256 {
                let account = coinType.derived(at: UInt32(index))
                let stellarSeed = try! Seed(bytes: account.raw.bytes)
                let keyPair = KeyPair.init(seed: stellarSeed)
                walletsKeyPairs[keyPair.accountId] = keyPair
            }
        } else {
            walletsKeyPairs = [:]
        }
    }
    
    static func getKeyPair(forAccountID accountID: String) -> KeyPair? {
        return walletsKeyPairs.first(where: { (walletKeyPair) -> Bool in
            return walletKeyPair.key == accountID
        })?.value
    }
}
