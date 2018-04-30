//
//  AuthService.swift
//  Stellargate
//
//  Created by Istvan Elekes on 4/18/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import stellarsdk

public enum GenerateAccountResponseEnum {
    case success(response: RegistrationResponse)
    case failure(error: ServiceError)
}

public enum TFAResponseEnum {
    case success(response: TFAResponse)
    case failure(error: ServiceError)
}

public typealias GenerateAccountResponseClosure = (_ response:GenerateAccountResponseEnum) -> (Void)
public typealias TFAResponseClosure = (_ response:TFAResponseEnum) -> (Void)

public class AuthService: BaseService {
    
    open func sendTFA(code: String, response: @escaping TFAResponseClosure) {
        
        var params = Dictionary<String,String>()
        params["tfa_code"] = code
        
        let pathParams = params.stringFromHttpParameters()
        let bodyData = pathParams?.data(using: .utf8)
        
        POSTRequestWithPath(path: "/ico/auth/confirm_tfa_registration", body: bodyData, authRequired: true) { (result) -> (Void) in
            switch result {
            case .success(let data):
                do {
                    let tfaResponse = try self.jsonDecoder.decode(TFAResponse.self, from: data)
                    response(.success(response: tfaResponse))
                } catch {
                    response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                }
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    open func generateAccount(email: String, password: String, response: @escaping GenerateAccountResponseClosure) {
        DispatchQueue.global(qos: .userInitiated).async {
            var account: Account!
            do {
                account = try self.createAccountForPassword(password)
            } catch {
                response(.failure(error: .encryptionFailed(message: error.localizedDescription)))
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
            
            self.POSTRequestWithPath(path: "/ico/register_user", body: bodyData) { (result) -> (Void) in
                switch result {
                case .success(let data):
                    do {
                        let registrationResponse = try self.jsonDecoder.decode(RegistrationResponse.self, from: data)
                        response(.success(response: registrationResponse))
                    } catch {
                        response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                    }
                case .failure(let error):
                    response(.failure(error: error))
                }
            }
        }
    }
    
    private func createAccountForPassword(_ password: String) throws -> Account {
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
            let mnemonic16bytes = CryptoUtil.applyPadding(blockSize: 16, source: mnemonic.bytes)
            let encryptedMnemonic = try CryptoUtil.encryptValue(plainValue: mnemonic16bytes, key: masterKey, iv: mnemonicIV)
            
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
            throw error
        }
    }
}
