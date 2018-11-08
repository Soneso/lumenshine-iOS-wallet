//
//  AuthService.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 4/18/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import stellarsdk


public enum GenerateAccountResponseEnum {
    case success(response: TFASecretResponse?, userSecurity: UserSecurity)
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

public enum Login1ResponseEnum {
    case success(response: LoginStep1Response)
    case failure(error: ServiceError)
}

public enum Login2ResponseEnum {
    case success(response: LoginStep2Response)
    case failure(error: ServiceError)
}

public enum TfaSecretResponseEnum {
    case success(response: TFASecretResponse)
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

public enum ServerSigningKeyResponseEnum {
    case success(signingKey: String)
    case failure(error: ServiceError)
}

public enum SEP10ChallengeResponseEnum {
    case success(transactionEnvelopeXDR: String)
    case failure(error: ServiceError)
}

public enum SignSEP10ChallengeResponseEnum {
    case success(signedXDR: String)
    case failure(error: ServiceError)
}

public enum SEP10ChallengeValidationResponseEnum {
    case success(isValid: Bool, envelopeXDR: TransactionEnvelopeXDR?)
    case failure(error: ServiceError)
}

public typealias GenerateAccountResponseClosure = (_ response:GenerateAccountResponseEnum) -> (Void)
public typealias TFAResponseClosure = (_ response:TFAResponseEnum) -> (Void)
public typealias EmptyResponseClosure = (_ response:EmptyResponseEnum) -> (Void)
public typealias AuthResponseClosure = (_ response:AuthResponseEnum) -> (Void)
public typealias Login1ResponseClosure = (_ response:Login1ResponseEnum) -> (Void)
public typealias Login2ResponseClosure = (_ response:Login2ResponseEnum) -> (Void)
public typealias TfaSecretResponseClosure = (_ response:TfaSecretResponseEnum) -> (Void)
public typealias CountryListResponseClosure = (_ response:CountryListResponseEnum) -> (Void)
public typealias SalutationsResponseClosure = (_ response:SalutationsResponseEnum) -> (Void)
public typealias DecryptedUserDataResponseClosure = (_ response:DecryptedUserDataResponseEnum) -> (Void)
public typealias ServerSigningKeyClosure = (_ response:ServerSigningKeyResponseEnum) -> (Void)
public typealias SEP10ChallengeClosure = (_ response:SEP10ChallengeResponseEnum) -> (Void)
public typealias SignSEP10ChallengeClosure = (_ response:SignSEP10ChallengeResponseEnum) -> (Void)
public typealias SEP10ChallengeValidationClosure = (_ response:SEP10ChallengeValidationResponseEnum) -> (Void)

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
        
        POSTRequestWithPath(path: path) { (result) -> (Void) in
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
    
    /// Requests the sep10 challange from the server
    /// - Parameter: SEP10ChallengeClosure
    open func getSep10Challenge(response: @escaping SEP10ChallengeClosure) {
        
        guard let tokenType = BaseService.jwtTokenType else { return }
        var path: String = ""
        switch tokenType {
        case .full:
            path = "/portal/user/dashboard/get_sep10_challange"
        case .partial:
            path = "/portal/user/auth/get_sep10_challange"
        case .lost:
            path = "/portal/user/auth/get_sep10_challange"
        }
        
        GETRequestWithPath(path: path) { (result) -> (Void) in
            switch result {
            case .success(let data):
                do {
                    let challenge = try self.jsonDecoder.decode(SEP10ChallengeResponse.self, from: data)
                    response(.success(transactionEnvelopeXDR: challenge.transactionEnvelopeXDR))
                } catch {
                    response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                }
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    /// Loads the server signing key from the servers stellar.toml file
    /// - Parameter: ServerSigningKeyClosure
    open func loadServerSigningKey(completion:@escaping ServerSigningKeyClosure) {
        let serverSigningKeyTomlKey = "SIGNING_KEY"
        
        guard let url = URL(string: Services.shared.tomlURL) else {
            completion(.failure(error: .invalidRequest))
            return
        }
        
        DispatchQueue.global().async {
            do {
                let tomlString = try String(contentsOf: url, encoding: .utf8)
                let toml = try Toml(withString: tomlString)
                if let serverKey = toml.string(serverSigningKeyTomlKey) {
                    completion(.success(signingKey: serverKey))
                } else {
                    completion(.failure(error: .noSigningKeySet))
                }
                
            } catch {
                completion(.failure(error: .invalidToml))
            }
        }
    }
    
    /// Validates a transaction envelope of a SEP10 Challenge received from the server and signes it if valid
    /// The transaction envelope must contain only one transaction having the seqence number 0
    /// The transaction within the envelope must contain only one manage data operation having the user account as source account
    /// The transaction within the envelope must be signed by the server key only
    ///
    /// - Parameters:
    ///     - base64EnvelopeXDR: The SEP10 challenge to be validated
    ///     - userKeyPair: the keypair of the user including its public key and private key
    open func signSEP10ChallengeIfValid(base64EnvelopeXDR: String, userKeyPair: KeyPair, completion:@escaping SignSEP10ChallengeClosure) {
        validateSEP10Envelope(base64EnvelopeXDR: base64EnvelopeXDR, userAccountId: userKeyPair.accountId) { validationResult in
            switch validationResult {
            case .success(let isValid, let transactionEnvelopeXDR):
                if isValid, let envelopeXDR = transactionEnvelopeXDR, envelopeXDR.tx.seqNum == 0 {
                    // sign
                    // get currently used stellar network
                    var network = Network.testnet
                    if (Services.shared.usePublicStellarNetwork) {
                        network = Network.public
                    }
                    do {
                        // TODO: improve this in the SDK: add signature + get base 64
                        let tx = envelopeXDR.tx
                        // server signature
                        let serverSignature = envelopeXDR.signatures.first
                        
                        // user signature
                        let transactionHash = try [UInt8](tx.hash(network: network))
                        let userSignature = userKeyPair.signDecorated(transactionHash)
                        
                        // server + user signature
                        let signatures = [serverSignature, userSignature]
                        
                        // new envelope containung both signatures
                        let signedEnvelopeXDR = TransactionEnvelopeXDR(tx: tx, signatures:signatures as! [DecoratedSignatureXDR])
                        
                        // base 64
                        var encodedEnvelope = try XDREncoder.encode(signedEnvelopeXDR)
                        let result = Data(bytes: &encodedEnvelope, count: encodedEnvelope.count).base64EncodedString()
                    
                        completion(.success(signedXDR: result))
                    } catch let error {
                        print(error)
                        completion(.failure(error: .badCredentials))
                    }
                } else {
                    completion(.failure(error: .invalidSEP10Challenge))
                }
            case .failure(let error):
                completion(.failure(error: error))
            }
        }
    }
    
    open func validateSEP10Envelope(base64EnvelopeXDR: String, userAccountId: String, completion:@escaping SEP10ChallengeValidationClosure) {
        
        do {
            // xdr decoder to be used for decoding the transaction envelope
            let xdrDecoder = XDRDecoder.init(data: [UInt8].init(base64: base64EnvelopeXDR))
        
            
            // decode the envelope
            let transactionEnvelopeXDR = try TransactionEnvelopeXDR(fromBinary: xdrDecoder)
            let transactionXDR = transactionEnvelopeXDR.tx
            
            // sequence number of transaction must be 0
            if (transactionXDR.seqNum != 0) {
                completion(.success(isValid: false, envelopeXDR: transactionEnvelopeXDR))
                return
            }
            
            // the transaction must contain one operation
            if transactionXDR.operations.count == 1, let operationXDR = transactionXDR.operations.first {
                
                // the source account of the operation must match
                if let operationSourceAccount = operationXDR.sourceAccount {
                    if (operationSourceAccount.accountId != userAccountId) {
                        // source account of transaction doese not match user account
                        completion(.success(isValid: false, envelopeXDR: transactionEnvelopeXDR))
                        return
                    }
                } else {
                    // source account of transaction not found
                    completion(.success(isValid: false, envelopeXDR: transactionEnvelopeXDR))
                    return
                }
                
                //operation must be manage data operation
                let operationBodyXDR = operationXDR.body
                if (operationBodyXDR.type() != OperationType.manageData.rawValue) {
                    // not a manage data operation
                    completion(.success(isValid: false, envelopeXDR: transactionEnvelopeXDR))
                    return
                }
                
            } else {
                // the transaction has no operation or contains more than one operation
                completion(.success(isValid: false, envelopeXDR: transactionEnvelopeXDR))
                return
            }
            
            // the envelope must have one signature and it must be valid: transaction signed by the server
            if transactionEnvelopeXDR.signatures.count == 1, let signature = transactionEnvelopeXDR.signatures.first?.signature {
                
                // get currently used stellar network
                var network = Network.testnet
                if (Services.shared.usePublicStellarNetwork) {
                    network = Network.public
                }
                
                // transaction hash is the signed payload
                let transactionHash = try [UInt8](transactionXDR.hash(network: network))
                
                // validate signature
                var serverKeyPair = try KeyPair(accountId: Services.shared.serverSigningKey)
                var signatureIsValid = try serverKeyPair.verify(signature: [UInt8](signature), message: transactionHash)
                if signatureIsValid {
                    // signature is valid
                    completion(.success(isValid: true, envelopeXDR: transactionEnvelopeXDR))
                    return
                } else { // signature is not valid
                    //check if our server key is still the same. Load from server and if different, try validation again
                    loadServerSigningKey() { keyResult in
                        switch keyResult {
                        case .success(let signingKey):
                            // check if key loaded from the server is different to our locally stored key
                            if (signingKey != Services.shared.serverSigningKey) {
                                // store new signing key
                                Services.shared.serverSigningKey = signingKey
                                do {
                                    // validate signature again
                                    serverKeyPair = try KeyPair(accountId: signingKey)
                                    signatureIsValid = try serverKeyPair.verify(signature: [UInt8](signature), message: transactionHash)
                                    if signatureIsValid {
                                        // signature is valid
                                        completion(.success(isValid: true, envelopeXDR: transactionEnvelopeXDR))
                                        return
                                    }
                                    else {
                                        // signature is not valid
                                        completion(.success(isValid: false, envelopeXDR: transactionEnvelopeXDR))
                                        return
                                    }
                                } catch let error {
                                    print(error.localizedDescription)
                                    // validation failed
                                    completion(.success(isValid: false, envelopeXDR: transactionEnvelopeXDR))
                                }
                            } else {
                                // server key is not different
                                // signature is not valid
                                completion(.success(isValid: false, envelopeXDR: transactionEnvelopeXDR))
                                return
                            }
                        case .failure(let error):
                            // could not load signing key from server signature
                            completion(.failure(error: error))
                        }
                    }
                }
            }
            else {
                // could not find signature
                completion(.success(isValid: false, envelopeXDR: transactionEnvelopeXDR))
                return
            }
        } catch let error {
            print(error.localizedDescription)
            // validation failed
            completion(.success(isValid: false, envelopeXDR: nil))
        }
    }
    
    open func tfaSecret(signedSEP10TransactionEnvelope: String, response: @escaping TfaSecretResponseClosure) {
        var params = Dictionary<String,String>()
        params["sep10_transaction"] = signedSEP10TransactionEnvelope
        
        POSTRequestWithPath(path: "/portal/user/dashboard/tfa_secret", parameters: params) { (result) -> (Void) in
            switch result {
            case .success(let data):
                do {
                    let tfaResponse = try self.jsonDecoder.decode(TFASecretResponse.self, from: data)
                    response(.success(response: tfaResponse))
                } catch {
                    response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                }
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    open func loginStep2(signedSEP10TransactionEnvelope: String, userEmail: String, response: @escaping Login2ResponseClosure) {
        
        var params = Dictionary<String,String>()
        params["sep10_transaction"] = signedSEP10TransactionEnvelope
        
        POSTRequestWithPath(path: "/portal/user/auth/login_step2", parameters: params) { (result) -> (Void) in
            switch result {
            case .success(let data):
                BaseService.jwtTokenType = .full
                do {
                    let loginResponse = try self.jsonDecoder.decode(LoginStep2Response.self, from: data)
                    if let tokenExists = TFAGeneration.isTokenExists(email: userEmail),
                        tokenExists == false, loginResponse.tfaConfirmed {
                        self.tfaSecret(signedSEP10TransactionEnvelope: signedSEP10TransactionEnvelope) { result in
                            switch result {
                            case .success(let tfaResponse):
                                TFAGeneration.createToken(tfaSecret: tfaResponse.tfaSecret, email: userEmail)
                            case .failure(let error):
                                print("Tfa secret request error: \(error)")
                            }
                            response(.success(response: loginResponse))
                        }
                    } else {
                        response(.success(response: loginResponse))
                    }
                } catch {
                    response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                }
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    open func loginStep1(email: String, tfaCode:String?, response: @escaping Login1ResponseClosure) {
        var params = Dictionary<String,String>()
        params["email"] = email
        if let tfa = tfaCode {
            params["tfa_code"] = tfa
        }
    
        POSTRequestWithPath(path: "/portal/user/login_step1", parameters: params) { (result) -> (Void) in
            switch result {
            case .success(let data):
                BaseService.jwtTokenType = .partial
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
        var params = Dictionary<String,String>()
        params["email"] = email
    
        POSTRequestWithPath(path: "/portal/user/resend_confirmation_mail", parameters: params) { (result) -> (Void) in
            switch result {
            case .success:
                response(.success)
            case .failure(let error):
                response(.failure(error: error))
            }
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
        var params = Dictionary<String,String>()
        params["tfa_code"] = code
    
        POSTRequestWithPath(path: "/portal/user/auth/confirm_tfa_registration", parameters: params) { (result) -> (Void) in
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
            let keyPair = try! KeyPair.generateRandomKeyPair()
            params["public_key_188"] = keyPair.accountId //TODO remove this as soon as the server is ready
            
            if let userDict = userData {
                params.merge(userDict, uniquingKeysWith: {(first, _) in first})
            }
                
            self.POSTRequestWithPath(path: "/portal/user/register_user", parameters: params) { (result) -> (Void) in
                switch result {
                case .success(let data):
                    BaseService.jwtTokenType = .partial
                    do {
                        let registrationResponse = try self.jsonDecoder.decode(TFASecretResponse.self, from: data)
                        response(.success(response: registrationResponse, userSecurity: userSecurity))
                    } catch {
                        response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                    }
                case .failure(let error):
                    response(.failure(error: error))
                }
            }
        }
    }
    
    func lostPassword(email: String, response: @escaping EmptyResponseClosure) {
        var params = Dictionary<String,String>()
        params["email"] = email
        
        POSTRequestWithPath(path: "/portal/user/lost_password", parameters: params) { (result) -> (Void) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    response(.success)
                case .failure(let error):
                    response(.failure(error: error))
                }
            }
        }
    }
    
    func reset2fa(email: String, response: @escaping EmptyResponseClosure) {
        var params = Dictionary<String,String>()
        params["email"] = email
        
        POSTRequestWithPath(path: "/portal/user/lost_tfa", parameters: params) { (result) -> (Void) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    response(.success)
                case .failure(let error):
                    response(.failure(error: error))
                }
            }
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
    
    open func changePassword(signedSEP10TransactionEnvelope: String, userSecurity: UserSecurity, response: @escaping EmptyResponseClosure) {
        
        var params = Dictionary<String,String>()
        params["kdf_salt"] = userSecurity.passwordKdfSalt.toBase64()
        params["mnemonic_master_key"] = userSecurity.encryptedMnemonicMasterKey.toBase64()
        params["mnemonic_master_iv"] = userSecurity.mnemonicMasterKeyEncryptionIV.toBase64()
        params["wordlist_master_key"] = userSecurity.encryptedWordListMasterKey.toBase64()
        params["wordlist_master_iv"] = userSecurity.wordListMasterKeyEncryptionIV.toBase64()
        params["sep10_transaction"] = signedSEP10TransactionEnvelope
            
        POSTRequestWithPath(path: "/portal/user/dashboard/change_password", parameters: params) { (result) -> (Void) in
            switch result {
            case .success:
                response(.success)
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    open func new2faSecret(signedSEP10TransactionEnvelope: String, response: @escaping TfaSecretResponseClosure) {
        var params = Dictionary<String,String>()
        params["sep10_transaction"] = signedSEP10TransactionEnvelope
        params["public_key_188"] = "blubber" // TODO remove this when server is ready
            
        POSTRequestWithPath(path: "/portal/user/dashboard/new_2fa_secret", parameters: params) { (result) -> (Void) in
            switch result {
            case .success(let data):
                do {
                    let tfaResponse = try self.jsonDecoder.decode(TFASecretResponse.self, from: data)
                    response(.success(response: tfaResponse))
                } catch {
                    response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                }
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    open func confirm2faSecret(tfaCode: String, response: @escaping TFAResponseClosure) {
        var params = Dictionary<String,String>()
        params["tfa_code"] = tfaCode
        
        POSTRequestWithPath(path: "/portal/user/dashboard/confirm_new_2fa_secret", parameters: params) { (result) -> (Void) in
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
    
}
