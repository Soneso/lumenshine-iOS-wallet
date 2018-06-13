//
//  SalutationsResponse.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 6/13/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public class SalutationsResponse: Decodable {
    
    let salutations: Array<String>
    
    private enum CodingKeys: String, CodingKey {
        case salutations
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        salutations = try values.decode(Array<String>.self, forKey: .salutations)
    }
}
