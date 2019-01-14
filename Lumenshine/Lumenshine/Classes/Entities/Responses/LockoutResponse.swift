//
//  ErrorResponse.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 14/01/2019.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2019 Soneso. All rights reserved.
//

import Foundation

public class LockoutResponse: Decodable {
    
    var lockoutMinutes: Int?
    
    private enum CodingKeys: String, CodingKey {
        case lockoutMinutes = "lockout_minutes"
    }
    
    init() {
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lockoutMinutes = try values.decodeIfPresent(Int.self, forKey: .lockoutMinutes)
    }
}
