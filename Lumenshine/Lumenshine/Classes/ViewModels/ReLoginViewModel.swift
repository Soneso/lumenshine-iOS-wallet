//
//  ReLoginViewModel.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import LocalAuthentication

class ReLoginViewModel : LoginViewModel {
    fileprivate var user: User
    
    var reloadClosure: (() -> ())?
    
    init(user: User) {
        self.user = user
        super.init()
        self.entries = [.signOut,
                        .home]
        
        if !BiometricHelper.isTouchEnabled {
            entries.append(BiometricIDAuth().biometricType() == .faceID ? .faceRecognition : .fingerprint)
        }
    }
    
    override var barItems: [(String, String)] {
        return entries.map { x in
            return (x.name, x.icon.name)
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
        if entries.count > 2 {
            let buttonLabel = entries[2].name
            return R.string.localizable.hint_face_fingerprint(buttonLabel, buttonLabel)
        }
        return nil
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
    
    override func lost2FAClick() {
        logout()
        navigationCoordinator?.performTransition(transition: .logout(.showLost2fa))
    }
    
    override func removeBiometricRecognition() {
        entries.removeLast()
        reloadClosure?()
    }
    
    // MARK: Biometric authentication
    override func authenticateUser(completion: @escaping BiometricAuthResponseClosure) {
        BiometricHelper.authenticate(username: user.email) { response in
            completion(response)
        }
    }
}

fileprivate extension ReLoginViewModel {
    func logout() {
        if let deviceToken = UserDefaults.standard.value(forKey: Keys.UserDefs.DeviceToken) as? String {
            Services.shared.push.unsubscribe(pushToken: deviceToken) { result in
                switch result {
                case .success:
                    UserDefaults.standard.setValue(nil, forKey:Keys.UserDefs.DeviceToken)
                case .failure(let error):
                    print("Push unsubscribe error: \(error)")
                }
            }
        }
        LoginViewModel.logout(username: user.email)
    }
}
