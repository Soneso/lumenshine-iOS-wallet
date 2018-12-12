//
//  ChartExchangeRatesResponse.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public class ChartExchangeRatesResponse: Decodable {
    let sourceCurrency: SourceCurrencyResponse
    let destinationCurrency: String
    let currentRate: Decimal
    let lastUpdateDate: String
    let rates: Array<ExchangeRateResponse>
    
    private enum CodingKeys: String, CodingKey {
        case sourceCurrency = "source_currency"
        case destinationCurrency = "destination_currency"
        case currentRate = "current_rate"
        case lastUpdateDate = "last_updated"
        case rates = "rates"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        sourceCurrency = try values.decode(SourceCurrencyResponse.self, forKey: .sourceCurrency)
        destinationCurrency = try values.decode(String.self, forKey: .destinationCurrency)
        currentRate = try values.decode(Decimal.self, forKey: .currentRate)
        lastUpdateDate = try values.decode(String.self, forKey: .lastUpdateDate)
        rates = try values.decode(Array<ExchangeRateResponse>.self, forKey: .rates)
    }
}
