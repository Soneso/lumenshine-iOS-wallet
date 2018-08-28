//
//  SourceCurrencyResponse.swift
//  Lumenshine
//
//  Created by Soneso on 16/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public class SourceCurrencyResponse: Decodable {
    let assetCode: String
    let issuerPublicKey: String
    
    private enum CodingKeys: String, CodingKey {
        case assetCode = "asset_code"
        case issuerPublicKey = "issuer_public_key"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        assetCode = try values.decode(String.self, forKey: .assetCode)
        issuerPublicKey = try values.decode(String.self, forKey: .issuerPublicKey)
    }
}
