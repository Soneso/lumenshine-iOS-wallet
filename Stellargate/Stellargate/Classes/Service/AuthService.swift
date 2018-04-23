//
//  AuthService.swift
//  Stellargate
//
//  Created by Istvan Elekes on 4/18/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import stellarsdk

class AuthService: BaseService {
    
    func generateAccount(email: String, password: String, response: @escaping (Account?) -> Void) {
        guard let account = createAccountForPassword(password) else {
            response(nil)
            return
        }
        
        var params = Dictionary<String,String>()
        params["email"] = email
        params["kdf_salt"] = account.passwordSalt.toBase64()
        params["master_key"] = account.encryptedMasterKey.toBase64()
        params["master_iv"] = account.masterKeyIV.toBase64()
        params["mnemonic"] = account.encryptedMnemonic.toBase64()
        params["mnemonic_iv"] = account.mnemonicIV.toBase64()
        params["public_key_0"] = account.publicKeyIndex0
        params["public_key_188"] = account.publicKeyIndex188
        
        let pathParams = params.stringFromHttpParameters()
        let bodyData = pathParams?.data(using: .utf8)
        
        POSTRequestWithPath(path: "/ico/register_user", body: bodyData) { result in
            switch result {
            case .success(let data):
                break
            case .failure(let error):
                break
            }
        }
        
    }
    
    private func createAccountForPassword(_ password: String) -> Account? {
        do {
            // generate 256 bit password and salt
            let passwordSalt = CryptoUtil.generateSalt()
            let derivedPassword = CryptoUtil.deriveKeyPbkdf2(password: password, salt: passwordSalt)
            
            // generate master key
            let masterKey = CryptoUtil.generateMasterKey()
            
            // encrypt master key
            let masterKeyIV = CryptoUtil.generateIV()
            let encryptedMasterKey = try CryptoUtil.encryptValue(plainValue: masterKey, key: derivedPassword, iv: masterKeyIV)
            
            // generate mnemonic
            let mnemonic = Wallet.generate24WordMnemonic()
            
            // encrypt the mnemonic
            let mnemonicIV = CryptoUtil.generateIV()
            let mnemonic16bytes = CryptoUtil.padCharsTo16BytesFormat(source: mnemonic)
            let encryptedMnemonic = try CryptoUtil.encryptValue(plainValue: mnemonic16bytes.bytes, key: masterKey, iv: mnemonicIV)
            
            // generate public keys
            let publicKeyIndex0 = try Wallet.createKeyPair(mnemonic: mnemonic, passphrase: nil, index: 0).accountId
            let publicKeyIndex188 = try Wallet.createKeyPair(mnemonic: mnemonic, passphrase: nil, index: 188).accountId
            
            return Account(publicKeyIndex0: publicKeyIndex0,
                           publicKeyIndex188: publicKeyIndex188,
                           passwordSalt: passwordSalt,
                           encryptedMasterKey: encryptedMasterKey,
                           masterKeyIV: masterKeyIV,
                           encryptedMnemonic: encryptedMnemonic,
                           mnemonicIV: mnemonicIV)
        } catch {
//            fatalError(error.localizedDescription)
            return nil
        }
    }
}
