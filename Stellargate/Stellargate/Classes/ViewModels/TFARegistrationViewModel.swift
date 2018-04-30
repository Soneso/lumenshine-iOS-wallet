//
//  TFARegistrationViewModel.swift
//  Stellargate
//
//  Created by Istvan Elekes on 4/29/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

protocol TFARegistrationViewModelType: Transitionable {
    var tfaSecret: String { get }
    var qrCode: Data? { get }
    func openAuthenticator()
    func submit()
}

class TFARegistrationViewModel : TFARegistrationViewModelType {
    fileprivate let email: String
    fileprivate let registrationResponse: RegistrationResponse
    
    init(email: String, response: RegistrationResponse) {
        self.email = email
        self.registrationResponse = response
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
    
    func submit() {
        
    }

}
