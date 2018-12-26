//
//  PrivateKeyManager.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import stellarsdk

public enum GetKeyPairEnum {
    case success(keyPair: KeyPair?)
    case failure(error: String)
}

public typealias GetKeyPairClosure = (_ completion: GetKeyPairEnum) -> (Void)

class PrivateKeyManager {
    private static var walletsKeyPairsIndexes: [String: Int] = [:]

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
                walletsKeyPairsIndexes[keyPair.accountId] = index
            }
        } else {
            walletsKeyPairsIndexes = [:]
        }
    }
    
    static func hasPublicKey(accountId: String) -> Bool {
        if let _ = getIndexInMnemonic(forAccountID: accountId) {
            return true
        }
        return false
    }
    
    static func getPublicKey(forIndex index: Int) -> String {
        return walletsKeyPairsIndexes.first(where: { (wallet) -> Bool in
            return wallet.value == index
        })?.key ?? ""
    }
    
    static func getIndexInMnemonic(forAccountID accountID: String) -> Int? {
        return walletsKeyPairsIndexes.first(where: { (walletKeyPair) -> Bool in
            return walletKeyPair.key == accountID
        })?.value
    }
    
    static func getKeyPair(forAccountID accountID: String, fromMnemonic mnemonic: String? = nil, completion: @escaping GetKeyPairClosure) {
        var keyPair: KeyPair? = nil
        if let index = getIndexInMnemonic(forAccountID: accountID) {
            if let mnemonic = mnemonic {
                keyPair = try? stellarsdk.Wallet.createKeyPair(mnemonic: mnemonic, passphrase: nil, index: index)
                DispatchQueue.main.async {
                    completion(.success(keyPair: keyPair))
                }
            } else {
                BiometricHelper.getMnemonic { (response) -> (Void) in
                    
                    switch response {
                    case .success(mnemonic: let mnemonic):
                        keyPair = try? stellarsdk.Wallet.createKeyPair(mnemonic: mnemonic, passphrase: nil, index: index)
                        DispatchQueue.main.async {
                            completion(.success(keyPair: keyPair))
                        }
                    case .failure(error: let error):
                        print(error)
                        DispatchQueue.main.async {
                            completion(.failure(error: error))
                        }
                    }
                }
            }
        }
    }
}
