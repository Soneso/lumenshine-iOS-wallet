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
    case success(response: RegistrationResponse, mnemonic: String)
    case failure(error: ServiceError)
}

public enum TFAResponseEnum {
    case success(response: TFAResponse)
    case failure(error: ServiceError)
}

public enum EmptyResponseEnum {
    case success
    case failure(error: ServiceError)
}

public enum Login1ResponseEnum {
    case success(response: LoginStep1Response)
    case failure(error: ServiceError)
}

public enum Login2ResponseEnum {
    case success(response: LoginStep2Response)
    case failure(error: ServiceError)
}

public typealias GenerateAccountResponseClosure = (_ response:GenerateAccountResponseEnum) -> (Void)
public typealias TFAResponseClosure = (_ response:TFAResponseEnum) -> (Void)
public typealias EmptyResponseClosure = (_ response:EmptyResponseEnum) -> (Void)
public typealias Login1ResponseClosure = (_ response:Login1ResponseEnum) -> (Void)
public typealias Login2ResponseClosure = (_ response:Login2ResponseEnum) -> (Void)

public class AuthService: BaseService {
    
    open func loginStep2(publicKeyIndex188: String, response: @escaping Login2ResponseClosure) {
        
        do {
            var params = Dictionary<String,String>()
            params["key"] = publicKeyIndex188
            
            let bodyData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        
            POSTRequestWithPath(path: "/portal/user/auth/login_step2", body: bodyData, authRequired: true) { (result) -> (Void) in
                switch result {
                case .success(let data):
                    do {
                        let loginResponse = try self.jsonDecoder.decode(LoginStep2Response.self, from: data)
                        response(.success(response: loginResponse))
                    } catch {
                        response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                    }
                case .failure(let error):
                    response(.failure(error: error))
                }
            }
        } catch {
            response(.failure(error: .parsingFailed(message: error.localizedDescription)))
        }
    }
    
    open func loginStep1(email: String, tfaCode:String?, response: @escaping Login1ResponseClosure) {
        
        do {
            var params = Dictionary<String,String>()
            params["email"] = email
            if let tfa = tfaCode {
                params["tfa_code"] = tfa
            }
            
            let bodyData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        
            POSTRequestWithPath(path: "/portal/user/login_step1", body: bodyData) { (result) -> (Void) in
                switch result {
                case .success(let data):
                    do {
                        let loginResponse = try self.jsonDecoder.decode(LoginStep1Response.self, from: data)
                        response(.success(response: loginResponse))
                    } catch {
                        response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                    }
                case .failure(let error):
                    response(.failure(error: error))
                }
            }
        } catch {
            response(.failure(error: .parsingFailed(message: error.localizedDescription)))
        }
    }
    
    open func confirmMnemonic(response: @escaping EmptyResponseClosure) {
        GETRequestWithPath(path: "/portal/user/dashboard/confirm_mnemonic", authRequired: true) { (result) -> (Void) in
            switch result {
            case .success:
                response(.success)
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    open func resendMailConfirmation(email: String, response: @escaping EmptyResponseClosure) {
        
        do {
            var params = Dictionary<String,String>()
            params["email"] = email
            
            let bodyData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        
            POSTRequestWithPath(path: "/portal/user/auth/resend_confirmation_mail", body: bodyData) { (result) -> (Void) in
                switch result {
                case .success:
                    response(.success)
                case .failure(let error):
                    response(.failure(error: error))
                }
            }
        } catch {
            response(.failure(error: .parsingFailed(message: error.localizedDescription)))
        }
    }
    
    open func registrationStatus(response: @escaping TFAResponseClosure) {
        
        GETRequestWithPath(path: "/portal/auth/get_user_registration_status", authRequired: true) { (result) -> (Void) in
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
    
    open func sendTFA(code: String, response: @escaping TFAResponseClosure) {
        
        do {
            var params = Dictionary<String,String>()
            params["tfa_code"] = code
            
            let bodyData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        
            POSTRequestWithPath(path: "/portal/user/auth/confirm_tfa_registration", body: bodyData, authRequired: true) { (result) -> (Void) in
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
        } catch {
            response(.failure(error: .parsingFailed(message: error.localizedDescription)))
        }
    }
    
    open func generateAccount(email: String, password: String, response: @escaping GenerateAccountResponseClosure) {
        DispatchQueue.global(qos: .userInitiated).async {
            var userSecurity: UserSecurity!
            do {
                userSecurity = try UserSecurityHelper.generateUserSecurity(email: email, password: password)
            } catch {
                response(.failure(error: .encryptionFailed(message: error.localizedDescription)))
            }
        
            var params = Dictionary<String,String>()
            params["email"] = email
            params["kdf_salt"] = userSecurity.passwordKdfSalt.toBase64()
            params["mnemonic_master_key"] = userSecurity.encryptedMnemonicMasterKey.toBase64()
            params["mnemonic_master_iv"] = userSecurity.mnemonicMasterKeyEncryptionIV.toBase64()
            params["wordlist_master_key"] = userSecurity.encryptedWordListMasterKey.toBase64()
            params["wordlist_master_iv"] = userSecurity.wordListMasterKeyEncryptionIV.toBase64()
            params["mnemonic"] = userSecurity.encryptedMnemonic.toBase64()
            params["mnemonic_iv"] = userSecurity.mnemonicEncryptionIV.toBase64()
            params["wordlist"] = userSecurity.encryptedWordList.toBase64()
            params["wordlist_iv"] = userSecurity.wordListEncryptionIV.toBase64()
            params["public_key_0"] = userSecurity.publicKeyIndex0
            params["public_key_188"] = userSecurity.publicKeyIndex188
            
            do {
                let bodyData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                
                self.POSTRequestWithPath(path: "/portal/user/register_user", body: bodyData) { (result) -> (Void) in
                    switch result {
                    case .success(let data):
                        do {
                            let registrationResponse = try self.jsonDecoder.decode(RegistrationResponse.self, from: data)
                            response(.success(response: registrationResponse, mnemonic: userSecurity.mnemonic24Word))
                        } catch {
                            response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                        }
                    case .failure(let error):
                        response(.failure(error: error))
                    }
                }
            } catch {
                response(.failure(error: .parsingFailed(message: error.localizedDescription)))
            }
        }
    }
    
//    private func createAccountForPassword(_ password: String) throws -> UserSecurity {
//        do {
//            // generate 256 bit password and salt
//            let passwordSalt = CryptoUtil.generateSalt()
//            let derivedPassword = CryptoUtil.deriveKeyPbkdf2(password: password, salt: passwordSalt)
//
//            // generate master key
//            let masterKey = CryptoUtil.generateMasterKey()
//
//            // encrypt master key
//            let masterKeyIV = CryptoUtil.generateIV()
//            let encryptedMasterKey = try CryptoUtil.encryptValue(plainValue: masterKey, key: derivedPassword, iv: masterKeyIV)
//
//            // generate mnemonic
//            let mnemonic = Wallet.generate24WordMnemonic()
//
//            // encrypt the mnemonic
//            let mnemonicIV = CryptoUtil.generateIV()
//            let mnemonic16bytes = CryptoUtil.applyPadding(blockSize: 16, source: mnemonic.bytes)
//            let encryptedMnemonic = try CryptoUtil.encryptValue(plainValue: mnemonic16bytes, key: masterKey, iv: mnemonicIV)
//
//            // generate public keys
//            let publicKeyIndex0 = try Wallet.createKeyPair(mnemonic: mnemonic, passphrase: nil, index: 0).accountId
//            let publicKeyIndex188 = try Wallet.createKeyPair(mnemonic: mnemonic, passphrase: nil, index: 188).accountId
//
//
//            return UserSecurity(publicKeyIndex0: publicKeyIndex0,
//                                publicKeyIndex188: publicKeyIndex188,
//                                passwordSalt: passwordSalt,
//                                encryptedMasterKey: encryptedMasterKey,
//                                masterKeyIV: masterKeyIV,
//                                encryptedMnemonic: encryptedMnemonic,
//                                mnemonicIV: mnemonicIV,
//                                mnemonic24Word: mnemonic)
//        } catch {
//            throw error
//        }
//    }
}
