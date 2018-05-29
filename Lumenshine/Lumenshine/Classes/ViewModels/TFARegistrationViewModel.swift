//
//  TFARegistrationViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 4/29/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import OneTimePassword

protocol TFARegistrationViewModelType: Transitionable {
    var tfaSecret: String { get }
    var qrCode: Data? { get }
    func openAuthenticator()
    func submit(tfaCode: String, response: @escaping TFAResponseClosure)
    func showMnemonicConfirmation()
    func showEmailConfirmation()
    func showDashboard()
    func generatePassword() -> String?
}

class TFARegistrationViewModel : TFARegistrationViewModelType {
    fileprivate let service: AuthService
    fileprivate let user: User
    fileprivate let registrationResponse: RegistrationResponse
    
    init(service: AuthService, user: User, response: RegistrationResponse) {
        self.service = service
        self.user = user
        self.registrationResponse = response
        
//        TFAGeneration.createToken(tfaSecret: response.tfaSecret, email: email)
    }
    
    var navigationCoordinator: CoordinatorType?
    
    var tfaSecret: String {
        return registrationResponse.tfaSecret
    }
    
    var qrCode: Data? {
        return Data(base64Encoded: registrationResponse.qrCode)
    }
    
    
    func generatePassword() -> String? {
        return TFAGeneration.generatePassword(email: user.email)
    }
    
    func openAuthenticator() {
        guard let tfaSecret = registrationResponse.tfaSecret.base32EncodedString else { return }
        let urlString = "otpauth://totp/stellargate:\(user.email)?secret=\(tfaSecret)&issuer=stellargate"
        guard let url = URL(string: urlString) else { return }
        navigationCoordinator?.performTransition(transition: .showGoogle2FA(url))
    }
    
    func submit(tfaCode: String, response: @escaping TFAResponseClosure) {
        service.sendTFA(code: tfaCode) { result in
            response(result)
        }
    }
    
    func showMnemonicConfirmation() {
        navigationCoordinator?.performTransition(transition: .showMnemonic(user))
    }
    
    func showEmailConfirmation() {
        navigationCoordinator?.performTransition(transition: .showEmailConfirmation(user))
    }
    
    func showDashboard() {
        navigationCoordinator?.performTransition(transition: .showDashboard(user))
    }
}
