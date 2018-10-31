//
//  AuthenticationResponse.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 5/10/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public class AuthenticationResponse: Decodable {
    
    let status: String?
    let kdfPasswordSalt: String
    let encryptedMnemonicMasterKey: String
    let mnemonicMasterKeyEncryptionIV: String
    let encryptedMnemonic: String
    let mnemonicEncryptionIV: String
    let encryptedWordlistMasterKey: String
    let wordlistMasterKeyEncryptionIV: String
    let encryptedWordlist: String
    let wordlistEncryptionIV: String
    let publicKeyIndex0: String
    let sep10TransactionEnvelopeXDR: String
    
    private enum CodingKeys: String, CodingKey {
        
        case status = "login_step1_status"
        case kdfPasswordSalt = "kdf_password_salt"
        case encryptedMnemonicMasterKey = "encrypted_mnemonic_master_key"
        case mnemonicMasterKeyEncryptionIV = "mnemonic_master_key_encryption_iv"
        case encryptedMnemonic = "encrypted_mnemonic"
        case mnemonicEncryptionIV = "mnemonic_encryption_iv"
        case encryptedWordlistMasterKey = "encrypted_wordlist_master_key"
        case wordlistMasterKeyEncryptionIV = "wordlist_master_key_encryption_iv"
        case encryptedWordlist = "encrypted_wordlist"
        case wordlistEncryptionIV = "wordlist_encryption_iv"
        case publicKeyIndex0 = "public_key_index0"
        case sep10TransactionEnvelopeXDR = "sep10_transaction_challenge"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        kdfPasswordSalt = try values.decode(String.self, forKey: .kdfPasswordSalt)
        encryptedMnemonicMasterKey = try values.decode(String.self, forKey: .encryptedMnemonicMasterKey)
        mnemonicMasterKeyEncryptionIV = try values.decode(String.self, forKey: .mnemonicMasterKeyEncryptionIV)
        encryptedMnemonic = try values.decode(String.self, forKey: .encryptedMnemonic)
        mnemonicEncryptionIV = try values.decode(String.self, forKey: .mnemonicEncryptionIV)
        encryptedWordlistMasterKey = try values.decode(String.self, forKey: .encryptedWordlistMasterKey)
        wordlistMasterKeyEncryptionIV = try values.decode(String.self, forKey: .wordlistMasterKeyEncryptionIV)
        encryptedWordlist = try values.decode(String.self, forKey: .encryptedWordlist)
        wordlistEncryptionIV = try values.decode(String.self, forKey: .wordlistEncryptionIV)
        publicKeyIndex0 = try values.decode(String.self, forKey: .publicKeyIndex0)
        sep10TransactionEnvelopeXDR = try values.decode(String.self, forKey: .sep10TransactionEnvelopeXDR)
    }
}
