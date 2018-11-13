//
//  PersonalDataEntry.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 10/17/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

protocol PersonalDataProtocol {
    var name: String { get }
    var code: String? { get }
}

struct PersonalData: PersonalDataProtocol {
    let name: String
    let code: String?
    
    init(name: String, code: String? = nil) {
        self.name = name
        self.code = code
    }
}

enum PersonalDataEntry: String {
    
    case forename
    case lastname
    case salutation
    case address
    case zipCode = "zip_code"
    case city
    case state
    case countryCode = "country_code"
    case nationality
    case mobileNR = "mobile_nr"
    case birthday = "birth_day"
    case birthPlace = "birth_place"
    case additionalName = "additional_name"
    case birthCountryCode = "birth_country_code"
    case bankAccountNumber = "bank_account_number"
    case bankNumber = "bank_number"
    case bankPhoneNumber = "bank_phone_number"
    case taxID = "tax_id"
    case taxIDName = "tax_id_name"
    case occupation = "occupation_name"
    case employerName = "employer_name"
    case employerAddress = "employer_address"
    case languageCode = "language_code"
    case registrationDate = "registration_date"
    
    var placeholder: String? {
        switch self {
        case .forename:
            return R.string.localizable.forename()
        case .lastname:
            return R.string.localizable.lastname()
        case .salutation:
            return R.string.localizable.salutation()
        case .address:
            return R.string.localizable.street_address()
        case .zipCode:
            return R.string.localizable.zip_code()
        case .city:
            return R.string.localizable.city()
        case .state:
            return R.string.localizable.state()
        case .countryCode:
            return R.string.localizable.country()
        case .nationality:
            return R.string.localizable.nationality()
        case .mobileNR:
            return R.string.localizable.mobile_phone()
        case .birthday:
            return R.string.localizable.birthday()
        case .birthPlace:
            return R.string.localizable.birthplace()
        case .additionalName:
            return R.string.localizable.additional_name()
        case .birthCountryCode:
            return R.string.localizable.birth_country()
        case .bankAccountNumber:
            return R.string.localizable.bank_account_number()
        case .bankNumber:
            return R.string.localizable.bank_number()
        case .bankPhoneNumber:
            return R.string.localizable.bank_phone_number()
        case .taxID:
            return R.string.localizable.tax_id()
        case .taxIDName:
            return R.string.localizable.tax_id_name()
        case .occupation:
            return R.string.localizable.occupation()
        case .employerName:
            return R.string.localizable.employer_name()
        case .employerAddress:
            return R.string.localizable.employer_address()
        case .languageCode:
            return R.string.localizable.language()
        case .registrationDate:
            return R.string.localizable.registration_date()
        }
    }
}
