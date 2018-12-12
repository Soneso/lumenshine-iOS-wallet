//
//  UserData.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public struct UserData: Codable {
    
    let email: String
    let forename: String
    let lastname: String
    let salutation: String
    let address: String
    let zipCode: String
    let city: String
    let state: String
    let countryCode: String
    let nationality: String
    let mobileNR: String
    let birthday: Date?
    let birthPlace: String
    let additionalName: String
    let birthCountryCode: String
    let bankAccountNumber: String
    let bankNumber: String
    let bankPhoneNumber: String
    let taxID: String
    let taxIDName: String
    let occupation: String
    let occupationCode08: String
    let occupationCode88: String
    let employerName: String
    let employerAddress: String
    let languageCode: String
    
    private enum CodingKeys: String, CodingKey {
        
        case email
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
        case occupationCode08 = "occupation_code08"
        case occupationCode88 = "occupation_code88"
        case employerName = "employer_name"
        case employerAddress = "employer_address"
        case languageCode = "language_code"
    }
}
