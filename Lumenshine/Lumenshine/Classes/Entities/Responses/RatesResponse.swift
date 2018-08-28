//
//  RatesResponse.swift
//  Lumenshine
//
//  Created by Soneso on 16/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public class RatesResponse: Decodable {
    let sourceCurrency: SourceCurrencyResponse
    let rate: Decimal
    let lastUpdateDate: String
    
    private enum CodingKeys: String, CodingKey {
        case sourceCurrency = "source_currency"
        case rate = "rate"
        case lastUpdateDate = "last_updated"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        sourceCurrency = try values.decode(SourceCurrencyResponse.self, forKey: .sourceCurrency)
        rate = try values.decode(Decimal.self, forKey: .rate)
        lastUpdateDate = try values.decode(String.self, forKey: .lastUpdateDate)
    }
}
