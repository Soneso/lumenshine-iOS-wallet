//
//  SetupViewModel.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit

enum SetupStep {
    case none
    case TFA
    case email
    case mnemonic
}

protocol SetupViewModelType: Transitionable {
    
    var headerTitle: String { get }
    var headerDetail: String { get }
    var headerText: String? { get }
    var tfaSecret: String? { get }
    var mnemonic24Word: String { get }
    var verificationWords: [String] { get }
    var userEmail: String {get}
    
    func submit(tfaCode: String, response: @escaping TFAResponseClosure)
    
    func checkMailConfirmation(response: @escaping TFAResponseClosure)
    func resendMailConfirmation(response: @escaping EmptyResponseClosure)
    func confirmMnemonic(response: @escaping TFAResponseClosure)
    
    func setupStep() -> SetupStep
    func nextStep(tfaResponse: TFAResponse?)
    func mnemonicVerification()
    
    func validateSetup(wordsIndices: [String?]) -> [Int]?
}

class SetupViewModel: SetupViewModelType {

    fileprivate let user: User
    fileprivate let mnemonic: String
    fileprivate let tfaConfirmed: Bool
    fileprivate let mailConfirmed: Bool
    fileprivate let mnemonicConfirmed: Bool
    fileprivate let internalTfaSecret: String?
    fileprivate var currentSetupStep: SetupStep
    fileprivate var randomIndices = [Int]()
    fileprivate var backgroundTime: Date?
    
    weak var navigationCoordinator: CoordinatorType?
    
    init(user: User, mnemonic: String, tfaConfirmed: Bool, mailConfirmed: Bool, mnemonicConfirmed: Bool, tfaSecret:String?) {
        self.user = user
        self.mnemonic = mnemonic
        self.tfaConfirmed = tfaConfirmed
        self.mailConfirmed = mailConfirmed
        self.mnemonicConfirmed = mnemonicConfirmed
        self.internalTfaSecret = tfaSecret
        self.currentSetupStep = .none
        self.randomIndices = generateRandomIndices()
        updateSetupStep(tfaConfirmed: tfaConfirmed, mailConfirmed: mailConfirmed, mnemonicConfirmed: mnemonicConfirmed)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground(notification:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground(notification:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc
    func appWillEnterForeground(notification: Notification) {
        showRelogin()
    }
    
    @objc
    func appDidEnterBackground(notification: Notification) {
        countBackgroundTime()
    }
    
    var headerTitle: String {
        return R.string.localizable.welcome()
    }
    
    var headerDetail: String {
        return user.email
    }
    
    var headerText: String? {
        return R.string.localizable.setup_wallet()
    }
    
    var tfaSecret: String? {
        return internalTfaSecret
    }
    
    var mnemonic24Word: String {
        return mnemonic
    }
    
    var userEmail: String {
        return user.email
    }
    
    func setupStep() -> SetupStep {
        return currentSetupStep
    }
    
    var verificationWords: [String] {
        let questionWords = mnemonic.components(separatedBy: " ")
        var words = [String]()
        for i in randomIndices {
            words.append(questionWords[i])
        }
        return words
    }
    
    // 2FA methods
    func submit(tfaCode: String, response: @escaping TFAResponseClosure) {
        Services.shared.auth.sendTFA(code: tfaCode) { result in
            response(result)
        }
    }
    
    // Email confirmation methods
    func checkMailConfirmation(response: @escaping TFAResponseClosure) {
        Services.shared.auth.registrationStatus { result in
            response(result)
        }
    }
    
    func resendMailConfirmation(response: @escaping EmptyResponseClosure) {
        Services.shared.auth.resendMailConfirmation(email: user.email) { result in
            response(result)
        }
    }
    
    func confirmMnemonic(response: @escaping TFAResponseClosure) {
        Services.shared.auth.confirmMnemonic { result in
            response(result)
        }
    }
    
    func nextStep(tfaResponse: TFAResponse?) {
        if let response = tfaResponse {
            updateSetupStep(tfaConfirmed: response.tfaConfirmed, mailConfirmed: response.mailConfirmed, mnemonicConfirmed: response.mnemonicConfirmed)
        }
        navigationCoordinator?.performTransition(transition: .nextSetupStep)
    }
    
    func mnemonicVerification() {
        randomIndices = generateRandomIndices()
        navigationCoordinator?.performTransition(transition: .showMnemonicVerification)
    }
    
    func validateSetup(wordsIndices: [String?]) -> [Int]? {
        var result = [Int]()
        for i in 0...3 {
            if let index = wordsIndices[i],
                Int(index) != randomIndices[i]+1 {
                result.append(i)
            }
        }
        return result.count > 0 ? result : nil
    }
}

fileprivate extension SetupViewModel {
    func updateSetupStep(tfaConfirmed: Bool, mailConfirmed: Bool, mnemonicConfirmed: Bool) {

        if tfaConfirmed == false {
            currentSetupStep = .TFA
        } else if mailConfirmed == false {
            currentSetupStep = .email
        } else if mnemonicConfirmed == false {
            currentSetupStep = .mnemonic
        } else {
            currentSetupStep = .none
        }
    }
    
    func generateRandomIndices() -> [Int] {
        let questionWords = mnemonic.components(separatedBy: " ")
        var numbers = [Int]()
        for _ in 1...4 {
            var n: Int
            repeat {
                n = Int(arc4random_uniform(UInt32(questionWords.count)))
            } while numbers.contains(n)
            numbers.append(n)
        }
        return numbers
    }
    
    func showRelogin() {
        if currentSetupStep == .mnemonic, let time = backgroundTime, time.addingTimeInterval(90) < Date() {
            navigationCoordinator?.performTransition(transition: .showRelogin)
        }
    }
    
    func countBackgroundTime() {
        backgroundTime = Date()
    }
}
