//
//  ChartCurrentRatesResponse.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
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
