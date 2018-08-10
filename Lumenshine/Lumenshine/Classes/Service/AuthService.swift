//
//  AuthService.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 4/18/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public enum GenerateAccountResponseEnum {
    case success(response: RegistrationResponse?, userSecurity: UserSecurity)
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

public enum AuthResponseEnum {
    case success(response: AuthenticationResponse)
    case failure(error: ServiceError)
}

public enum Login2ResponseEnum {
    case success(response: LoginStep2Response)
    case failure(error: ServiceError)
}

public enum TfaSecretResponseEnum {
    case success(response: RegistrationResponse)
    case failure(error: ServiceError)
}

public enum CountryListResponseEnum {
    case success(response: CountryListResponse)
    case failure(error: ServiceError)
}

public enum SalutationsResponseEnum {
    case success(response: SalutationsResponse)
    case failure(error: ServiceError)
}

public enum DecryptedUserDataResponseEnum {
    case success(response: DecryptedUserData)
    case failure(error: ServiceError)
}

public typealias GenerateAccountResponseClosure = (_ response:GenerateAccountResponseEnum) -> (Void)
public typealias TFAResponseClosure = (_ response:TFAResponseEnum) -> (Void)
public typealias EmptyResponseClosure = (_ response:EmptyResponseEnum) -> (Void)
public typealias AuthResponseClosure = (_ response:AuthResponseEnum) -> (Void)
public typealias Login2ResponseClosure = (_ response:Login2ResponseEnum) -> (Void)
public typealias TfaSecretResponseClosure = (_ response:TfaSecretResponseEnum) -> (Void)
public typealias CountryListResponseClosure = (_ response:CountryListResponseEnum) -> (Void)
public typealias SalutationsResponseClosure = (_ response:SalutationsResponseEnum) -> (Void)
public typealias DecryptedUserDataResponseClosure = (_ response:DecryptedUserDataResponseEnum) -> (Void)

public class AuthService: BaseService {
    
    private static var timer: Timer?
    
    override init(baseURL: String) {
        super.init(baseURL: baseURL)
        
        if AuthService.timer == nil {
            // 5 minutes repetition
            AuthService.timer = Timer.scheduledTimer(withTimeInterval: 5*60.0, repeats: true) { [weak self] timer in
                DispatchQueue.global(qos: .userInitiated).async {
                    self?.refreshToken() { response in
                        switch response {
                        case .success:
                            print("Token refreshed")
                        case .failure(let error):
                            print("Token refresh failed: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    
    private func refreshToken(response: @escaping EmptyResponseClosure) {
        guard let tokenType = BaseService.jwtTokenType else { return }
        var path: String = ""
        switch tokenType {
        case .full:
            path = "/portal/user/dashboard/refresh"
        case .partial:
            path = "/portal/user/auth/refresh"
        case .lost:
            path = "/portal/user/auth2/refresh"
        }
        
        GETRequestWithPath(path: path) { (result) -> (Void) in
            switch result {
            case .success(let data):
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject],
                        let token = json["token"] as? String {
                        BaseService.jwtToken = token
                        response(.success)
                    } else {
                        response(.failure(error: .unexpectedDataType))
                    }
                } catch {
                    response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                }
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    open func countryList(response: @escaping CountryListResponseClosure) {
        
        GETRequestWithPath(path: "/portal/user/country_list") { (result) -> (Void) in
            switch result {
            case .success(let data):
                do {
                    let countryListResponse = try self.jsonDecoder.decode(CountryListResponse.self, from: data)
                    response(.success(response: countryListResponse))
                } catch {
                    response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                }
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    open func salutationList(response: @escaping SalutationsResponseClosure) {
        
        GETRequestWithPath(path: "/portal/user/salutation_list") { (result) -> (Void) in
            switch result {
            case .success(let data):
                do {
                    let salutationsResponse = try self.jsonDecoder.decode(SalutationsResponse.self, from: data)
                    response(.success(response: salutationsResponse))
                } catch {
                    response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                }
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    open func tfaSecret(publicKeyIndex188: String, response: @escaping TfaSecretResponseClosure) {
        do {
            var params = Dictionary<String,String>()
            params["key"] = publicKeyIndex188
            
            let bodyData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            
            POSTRequestWithPath(path: "/portal/dashboard/tfa_secret", body: bodyData) { (result) -> (Void) in
                switch result {
                case .success(let data):
                    do {
                        let tfaResponse = try self.jsonDecoder.decode(RegistrationResponse.self, from: data)
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
    
    open func loginStep2(publicKeyIndex188: String, response: @escaping Login2ResponseClosure) {
        
        do {
            var params = Dictionary<String,String>()
            params["key"] = publicKeyIndex188
            
            let bodyData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        
            POSTRequestWithPath(path: "/portal/user/auth/login_step2", body: bodyData) { (result) -> (Void) in
                switch result {
                case .success(let data):
                    BaseService.jwtTokenType = .full
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
    
    open func loginStep1(email: String, tfaCode:String?, response: @escaping AuthResponseClosure) {
        
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
                    BaseService.jwtTokenType = .partial
                    do {
                        let loginResponse = try self.jsonDecoder.decode(AuthenticationResponse.self, from: data)
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
    
    open func confirmMnemonic(response: @escaping TFAResponseClosure) {
        POSTRequestWithPath(path: "/portal/user/dashboard/confirm_mnemonic") { (result) -> (Void) in
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
    
    open func resendMailConfirmation(email: String, response: @escaping EmptyResponseClosure) {
        
        do {
            var params = Dictionary<String,String>()
            params["email"] = email
            
            let bodyData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        
            POSTRequestWithPath(path: "/portal/user/resend_confirmation_mail", body: bodyData) { (result) -> (Void) in
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
        
        GETRequestWithPath(path: "/portal/user/dashboard/get_user_registration_status") { (result) -> (Void) in
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
        
            POSTRequestWithPath(path: "/portal/user/auth/confirm_tfa_registration", body: bodyData) { (result) -> (Void) in
                switch result {
                case .success(let data):
                    BaseService.jwtTokenType = .full
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
    
    open func generateAccount(email: String, password: String, userData: Dictionary<String,String>?, response: @escaping GenerateAccountResponseClosure) {
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
            
            if let userDict = userData {
                params.merge(userDict, uniquingKeysWith: {(first, _) in first})
            }
            
            do {
                let bodyData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                
                self.POSTRequestWithPath(path: "/portal/user/register_user", body: bodyData) { (result) -> (Void) in
                    switch result {
                    case .success(let data):
                        BaseService.jwtTokenType = .partial
                        do {
                            let registrationResponse = try self.jsonDecoder.decode(RegistrationResponse.self, from: data)
                            response(.success(response: registrationResponse, userSecurity: userSecurity))
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
    
    func lostPassword(email: String, response: @escaping EmptyResponseClosure) {
        do {
            var params = Dictionary<String,String>()
            params["email"] = email
            
            let bodyData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            
            POSTRequestWithPath(path: "/portal/user/lost_password", body: bodyData) { (result) -> (Void) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        response(.success)
                    case .failure(let error):
                        response(.failure(error: error))
                    }
                }
            }
        } catch {
            response(.failure(error: .parsingFailed(message: error.localizedDescription)))
        }
    }
    
    func reset2fa(email: String, response: @escaping EmptyResponseClosure) {
        do {
            var params = Dictionary<String,String>()
            params["email"] = email
            
            let bodyData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            
            POSTRequestWithPath(path: "/portal/user/lost_tfa", body: bodyData) { (result) -> (Void) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        response(.success)
                    case .failure(let error):
                        response(.failure(error: error))
                    }
                }
            }
        } catch {
            response(.failure(error: .parsingFailed(message: error.localizedDescription)))
        }
    }
    
    open func authenticationData(response: @escaping AuthResponseClosure) {
        
        GETRequestWithPath(path: "/portal/user/dashboard/user_auth_data") { (result) -> (Void) in
            switch result {
            case .success(let data):
                do {
                    let authResponse = try self.jsonDecoder.decode(AuthenticationResponse.self, from: data)
                    response(.success(response: authResponse))
                } catch {
                    response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                }
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    open func changePassword(userSecurity: UserSecurity, response: @escaping EmptyResponseClosure) {
        
        var params = Dictionary<String,String>()
        params["kdf_salt"] = userSecurity.passwordKdfSalt.toBase64()
        params["mnemonic_master_key"] = userSecurity.encryptedMnemonicMasterKey.toBase64()
        params["mnemonic_master_iv"] = userSecurity.mnemonicMasterKeyEncryptionIV.toBase64()
        params["wordlist_master_key"] = userSecurity.encryptedWordListMasterKey.toBase64()
        // key: wordlist_encryption_iv ??
        params["wordlist_master_iv"] = userSecurity.wordListMasterKeyEncryptionIV.toBase64()
        params["public_key_188"] = userSecurity.publicKeyIndex188
        
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            
            self.POSTRequestWithPath(path: "/portal/user/dashboard/change_password", body: bodyData) { (result) -> (Void) in
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
    
    open func new2faSecret(publicKeyIndex188: String, response: @escaping TfaSecretResponseClosure) {
        var params = Dictionary<String,String>()
        params["public_key_188"] = publicKeyIndex188
        
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            
            POSTRequestWithPath(path: "/portal/user/dashboard/new_2fa_secret", body: bodyData) { (result) -> (Void) in
                switch result {
                case .success(let data):
                    do {
                        let tfaResponse = try self.jsonDecoder.decode(RegistrationResponse.self, from: data)
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
    
    open func confirm2faSecret(tfaCode: String, response: @escaping TFAResponseClosure) {
        do {
            var params = Dictionary<String,String>()
            params["tfa_code"] = tfaCode
            
            let bodyData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            
            POSTRequestWithPath(path: "/portal/user/dashboard/confirm_new_2fa_secret", body: bodyData) { (result) -> (Void) in
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
    
}
