//
//  RegistrationViewModel.swift
//  Stellargate
//
//  Created by Istvan Elekes on 4/21/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

protocol RegistrationViewModelType: Transitionable {
    var items: [[String]] { get }
    
}

class RegistrationViewModel : RegistrationViewModelType {
    
    
    init() {
        
    }
    
    var navigationCoordinator: CoordinatorType?
    
    var items: [[String]] = [
        ["Email", "Password"],
        ["Forename", "Last name", "Company name", "Salutation", "Title",
         "Street address", "Street number", "Zip code", "City", "State",
         "Country", "Nationality", "Mobile phone", "Birth day", "Birth place"]
    ]
    
    
}

