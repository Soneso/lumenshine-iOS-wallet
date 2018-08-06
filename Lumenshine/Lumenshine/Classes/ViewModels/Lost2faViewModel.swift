//
//  Lost2faViewModel.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 29/05/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

protocol Lost2faViewModelType: Transitionable {
    func reset2fa(email:String?, response: @escaping EmptyResponseClosure)
}


class Lost2faViewModel: Lost2faViewModelType {
    weak var navigationCoordinator: CoordinatorType?
    
    fileprivate let service: AuthService
    
    init(service: AuthService) {
        self.service = service
    }
    
    func reset2fa(email:String?, response: @escaping EmptyResponseClosure) {
        if let email = email, email.isEmail() {
            service.reset2fa(email: email, response: response)
        } else {
            let error = ErrorResponse()
            error.errorMessage = R.string.localizable.invalid_email()
            response(.failure(error: .validationFailed(error: error)))
        }
    }
    
}
