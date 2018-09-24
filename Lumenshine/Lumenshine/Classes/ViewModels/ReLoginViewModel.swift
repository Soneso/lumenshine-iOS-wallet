//
//  ReLoginViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 6/27/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

class ReLoginViewModel : LoginViewModel {
    fileprivate var user: User
    
    init(service: AuthService, user: User) {
        self.user = user
        super.init(service: service)
        self.entries = [.signOut,
                        .home,
                        BiometricIDAuth().biometricType() == .faceID ? .faceRecognition : .fingerprint]
    }
    
    override var barItems: [(String, String)] {
        return entries.map { x in
            var name = x.name
            if x == .faceRecognition || x == .fingerprint {
                name = "\(R.string.localizable.activate()) \(name)"
            }
            return (name, x.icon.name)
        }
    }
    
    override func barItemSelected(at index:Int) {
        switch index {
        case 0:
            logout()
            navigationCoordinator?.performTransition(transition: .logout(nil))
        case 1:
            navigationCoordinator?.performTransition(transition: .showRelogin)
        case 2:
            navigationCoordinator?.performTransition(transition: .showFingerprint)
        default: break
        }
    }
    
    override var headerTitle: String {
        return R.string.localizable.welcome()
    }
    
    override var headerDetail: String {
        return user.email
    }
    
    override var hintText: String? {
        let text = BiometricIDAuth().biometricType() == .faceID ? R.string.localizable.face_recognition() : R.string.localizable.fingerprint()
        return R.string.localizable.hint_face_fingerprint(text, text)
    }
    
    override func loginCompleted() {
        navigationCoordinator?.performTransition(transition: .showDashboard(user))
    }
    
    override  func loginStep1(email: String, password: String, tfaCode: String?, checkSetup: Bool? = true, response: @escaping EmptyResponseClosure) {
        if let tfa = tfaCode, !tfa.isEmpty {
            super.loginStep1(email: user.email, password: password, tfaCode: tfa, checkSetup: checkSetup, response: response)
        } else {
            let tfa = TFAGeneration.generate2FACode(email: user.email)
            super.loginStep1(email: user.email, password: password, tfaCode: tfa, checkSetup: checkSetup, response: response)
        }
    }
    
    override func forgotPasswordClick() {
        logout()
        navigationCoordinator?.performTransition(transition: .logout(.showForgotPassword))
    }
    
    // MARK: Biometric authentication
    override func authenticateUser(completion: @escaping BiometricAuthResponseClosure) {
        BiometricHelper.authenticate(username: user.email, response: completion)
    }
}

fileprivate extension ReLoginViewModel {
    func logout() {
        LoginViewModel.logout(userEmail: user.email)
    }
}
