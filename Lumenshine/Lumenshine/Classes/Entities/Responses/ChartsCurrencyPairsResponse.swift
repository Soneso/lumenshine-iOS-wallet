//
//  ChartsCurrencyPairsResponse.swift
//  Lumenshine
//
//  Created by Soneso on 16/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public class ChartsCurrencyPairsResponse: Decodable {
    let sourceCurrency: SourceCurrencyResponse
    let destinationCurrencies: Array<String>
    
    private enum CodingKeys: String, CodingKey {
        case sourceCurrency = "source_currency"
        case destinationCurrencies = "destination_currencies"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        sourceCurrency = try values.decode(SourceCurrencyResponse.self, forKey: .sourceCurrency)
        destinationCurrencies = try values.decode(Array<String>.self, forKey: .destinationCurrencies)
    }
}
