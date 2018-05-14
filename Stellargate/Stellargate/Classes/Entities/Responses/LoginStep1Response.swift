//
//  LoginStep1Response.swift
//  Stellargate
//
//  Created by Istvan Elekes on 5/10/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public class LoginStep1Response: Decodable {
    
    let status: String
    let kdfPasswordSalt: String
    let encryptedMasterKey: String
    let masterKeyIV: String
    let encryptedMnemonic: String
    let mnemonicIV: String
    let publicKeyIndex0: String
    
    private enum CodingKeys: String, CodingKey {
        
        case status = "login_step1_status"
        case kdfPasswordSalt = "kdf_password_salt"
        case encryptedMasterKey = "encrypted_master_key"
        case masterKeyIV = "master_key_encryption_iv"
        case encryptedMnemonic = "encrypted_mnemonic"
        case mnemonicIV = "mnemonic_encryption_iv"
        case publicKeyIndex0 = "public_key_index0"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decode(String.self, forKey: .status)
        kdfPasswordSalt = try values.decode(String.self, forKey: .kdfPasswordSalt)
        encryptedMasterKey = try values.decode(String.self, forKey: .encryptedMasterKey)
        masterKeyIV = try values.decode(String.self, forKey: .masterKeyIV)
        encryptedMnemonic = try values.decode(String.self, forKey: .encryptedMnemonic)
        mnemonicIV = try values.decode(String.self, forKey: .mnemonicIV)
        publicKeyIndex0 = try values.decode(String.self, forKey: .publicKeyIndex0)
    }
}
