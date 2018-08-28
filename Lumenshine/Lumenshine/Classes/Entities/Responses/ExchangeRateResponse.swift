//
//  ExchangeRateResponse.swift
//  Lumenshine
//
//  Created by Soneso on 16/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public class ExchangeRateResponse: Decodable {
    let date: String
    let rate: Decimal
    
    private enum CodingKeys: String, CodingKey {
        case date = "date"
        case rate = "rate"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        date = try values.decode(String.self, forKey: .date)
        rate = try values.decode(Decimal.self, forKey: .rate)
    }
}
