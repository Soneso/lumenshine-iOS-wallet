//
//  ChartCurrentRatesResponse.swift
//  Lumenshine
//
//  Created by Ionut Teslovan on 16/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public class ChartCurrentRatesResponse: Decodable {
    let destinationCurrency: String
    let rates: Array<RatesResponse>
    
    private enum CodingKeys: String, CodingKey {
        case destionationCurrency = "destination_currency"
        case rates = "rates"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        destinationCurrency = try values.decode(String.self, forKey: .destionationCurrency)
        rates = try values.decode(Array<RatesResponse>.self, forKey: .rates)
    }
}
