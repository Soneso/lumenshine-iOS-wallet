//
//  ErrorResponse.swift
//  Stellargate
//
//  Created by Istvan Elekes on 4/30/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public class ErrorResponse: Decodable {
    
    let errorCode: Int?
    let parameterName: String?
    let errorMessageKey: String?
    let errorMessage: String?
    
    private enum CodingKeys: String, CodingKey {
        
        case errorCode = "error_code"
        case parameterName = "parameter_name"
        case errorMessageKey = "user_error_message_key"
        case errorMessage = "error_message"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        errorCode = try values.decodeIfPresent(Int.self, forKey: .errorCode)
        parameterName = try values.decodeIfPresent(String.self, forKey: .parameterName)
        errorMessageKey = try values.decodeIfPresent(String.self, forKey: .errorMessageKey)
        errorMessage = try values.decodeIfPresent(String.self, forKey: .errorMessage)
    }
}
