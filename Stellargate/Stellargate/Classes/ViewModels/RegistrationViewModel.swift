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
    var values: [[String?]] { get }
    var sectionTitles: [String] { get }
    
    func textChanged(_ text: String, itemForRowAt indexPath: IndexPath)
}

class RegistrationViewModel : RegistrationViewModelType {
    
    init() {
        values = items.map { value in
            return Array<String?>(repeating: nil, count: value.count)
        }
    }
    
    var navigationCoordinator: CoordinatorType?
    
    var values: [[String?]]
    var items: [[String]] = [
        ["Email", "Password"],
        ["Forename", "Last name", "Company name", "Salutation", "Title",
         "Street address", "Street number", "Zip code", "City", "State",
         "Country", "Nationality", "Mobile phone", "Birth day", "Birth place"]
    ]
    
    var sectionTitles: [String] = [
        R.string.localizable.account_data_title(),
        R.string.localizable.user_data_title()
    ]
    
    func textChanged(_ text: String, itemForRowAt indexPath: IndexPath) {
        values[indexPath.section][indexPath.row] = text
    }
}

