//
//  CountryListResponse.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 6/13/18.
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
