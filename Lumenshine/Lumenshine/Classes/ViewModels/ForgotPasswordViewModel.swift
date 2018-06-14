//
//  ForgotPasswordViewModel.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 27/05/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

protocol ForgotPasswordViewModelType: Transitionable {
    func resetPassword(email:String?, response: @escaping EmptyResponseClosure)
}


class ForgotPasswordViewModel: ForgotPasswordViewModelType {
    var navigationCoordinator: CoordinatorType?
    
    fileprivate let service: AuthService
    
    init(service: AuthService) {
        self.service = service
    }
    
    func resetPassword(email:String?, response: @escaping EmptyResponseClosure) {
        if let email = email, email.isEmail() {
            service.resetPassword(email: email, response: response)
        } else {
            let error = ErrorResponse()
            error.errorMessage = R.string.localizable.invalid_email()
            response(.failure(error: .validationFailed(error: error)))
        }
    }

}
