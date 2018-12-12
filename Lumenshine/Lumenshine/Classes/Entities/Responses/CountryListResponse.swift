//
//  CountryListResponse.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public class CountryListResponse: Decodable {
    
    let countries: Array<CountryResponse>
    
    private enum CodingKeys: String, CodingKey {
        case countries
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        countries = try values.decode(Array<CountryResponse>.self, forKey: .countries)
    }
}
