//
//  Occupation.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 10/18/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

class Occupation: Decodable {
    
    let name: String
    let isco08: Int
    let isco88: Int
    
    
    private enum CodingKeys: String, CodingKey {
        case name
        case isco08 = "isco08"
        case isco88 = "isco88"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        isco08 = try values.decode(Int.self, forKey: .isco08)
        isco88 = try values.decode(Int.self, forKey: .isco88)
    }
}
