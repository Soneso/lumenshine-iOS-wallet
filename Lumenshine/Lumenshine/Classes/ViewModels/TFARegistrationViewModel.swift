//
//  TFARegistrationViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 4/29/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

protocol TFARegistrationViewModelType: Transitionable {
    var tfaSecret: String { get }
    var qrCode: Data? { get }
    func openAuthenticator()
    func submit(tfaCode: String, response: @escaping TFAResponseClosure)
    func showMnemonicConfirmation()
    func showEmailConfirmation()
}

class TFARegistrationViewModel : TFARegistrationViewModelType {
    fileprivate let service: AuthService
    fileprivate let email: String
    fileprivate let registrationResponse: RegistrationResponse
    fileprivate let mnemonic: String?
    
    init(service: AuthService, email: String, response: RegistrationResponse, mnemonic: String?) {
        self.service = service
        self.email = email
        self.registrationResponse = response
        self.mnemonic = mnemonic
    }
    
    var navigationCoordinator: CoordinatorType?
    
    var tfaSecret: String {
        return registrationResponse.tfaSecret
    }
    
    var qrCode: Data? {
        return Data(base64Encoded: registrationResponse.qrCode)
    }
    
    func openAuthenticator() {
        guard let tfaSecret = registrationResponse.tfaSecret.base32EncodedString else { return }
        let urlString = "otpauth://totp/stellargate:\(email)?secret=\(tfaSecret)&issuer=stellargate"
        guard let url = URL(string: urlString) else { return }
        navigationCoordinator?.performTransition(transition: .showGoogle2FA(url))
    }
    
    func submit(tfaCode: String, response: @escaping TFAResponseClosure) {
        service.sendTFA(code: tfaCode) { result in
            response(result)
        }
    }
    
    func showMnemonicConfirmation() {
        guard let mnemonic = self.mnemonic else { return }
        navigationCoordinator?.performTransition(transition: .showMnemonic(mnemonic))
    }
    
    func showEmailConfirmation() {
        navigationCoordinator?.performTransition(transition: .showEmailConfirmation(email))
    }
}
