//
//  SalutationsResponse.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
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
