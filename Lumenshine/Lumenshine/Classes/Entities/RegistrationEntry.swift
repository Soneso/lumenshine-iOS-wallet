//
//  RegistrationEntry.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 6/13/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

enum RegistrationEntry: Int {
    case email
    case password
    case forename
    case lastname
    case company
    case salutation
    case title
    case street
    case streetNr
    case zipCode
    case city
    case state
    case country
    case nationality
    case phone
    case birthday
    case birthplace
    
    var placeholder: String? {
        switch self {
        case .email:
            return R.string.localizable.email()
        case .password:
            return R.string.localizable.password()
        case .forename:
            return R.string.localizable.forename()
        case .lastname:
            return R.string.localizable.lastname()
        case .company:
            return R.string.localizable.company_name()
        case .salutation:
            return R.string.localizable.salutation()
        case .title:
            return R.string.localizable.title()
        case .street:
            return R.string.localizable.street_address()
        case .streetNr:
            return R.string.localizable.street_number()
        case .zipCode:
            return R.string.localizable.zip_code()
        case .city:
            return R.string.localizable.city()
        case .state:
            return R.string.localizable.state()
        case .country:
            return R.string.localizable.country()
        case .nationality:
            return R.string.localizable.nationality()
        case .phone:
            return R.string.localizable.mobile_phone()
        case .birthday:
            return R.string.localizable.birthday()
        case .birthplace:
            return R.string.localizable.birthplace()
        }
    }
    
    var secureText: Bool {
        switch self {
        case .password:
            return true
        default:
            return false
        }
    }
}
