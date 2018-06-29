//
//  ReLoginViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 6/27/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

class ReLoginViewModel : LoginViewModel {
    fileprivate let touchMe: BiometricIDAuth
    fileprivate var user: User
    
    init(service: AuthService, user: User) {
        self.user = user
        self.touchMe = BiometricIDAuth()
        super.init(service: service)
        self.entries = [.signOut, .home]
        
        switch touchMe.biometricType() {
        case .faceID:
            entries.append(.faceRecognition)
        case .touchID:
            entries.append(.fingerprint)
        default: break
        }
    }
    
    override var barItems: [(String, String)] {
        return entries.map {
            ($0.name, $0.icon.name)
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
            break
        default: break
        }
    }
    
    override var headerTitle: String {
        return R.string.localizable.app_name()
    }
    
    override var headerDetail: String {
        return "\(R.string.localizable.welcome()) \(R.string.localizable.back())\n\(user.email)"
    }
    
    override func loginCompleted() {
        navigationCoordinator?.performTransition(transition: .openDashboard)
        touchMe.invalidate()
    }
    
    override func loginStep1(email: String, tfaCode: String?, response: @escaping Login1ResponseClosure) {
        let tfa = TFAGeneration.generatePassword(email: user.email)
        super.loginStep1(email: user.email, tfaCode: tfa, response: response)
    }
    
    override func forgotPasswordClick() {
        logout()
        navigationCoordinator?.performTransition(transition: .logout(.showForgotPassword))
    }
    
    // MARK: Biometric authentication
    override func biometricType() -> BiometricType {
        return touchMe.biometricType()
    }
    
    override func canEvaluatePolicy() -> Bool {
        return touchMe.canEvaluatePolicy()
    }
    
    override func authenticateUser(completion: @escaping (String?) -> Void) {
        touchMe.authenticateUser(completion: completion)
    }
}

fileprivate extension ReLoginViewModel {
    func logout() {
        TFAGeneration.removeToken(email: user.email)
        BaseService.removeToken()
    }
}
