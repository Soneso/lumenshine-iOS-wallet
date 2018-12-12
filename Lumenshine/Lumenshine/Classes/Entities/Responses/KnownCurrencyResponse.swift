//
//  KnownCurrencyResponse.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public class KnownCurrencyResponse: Decodable {
    let id: Int
    let name: String
    let issuerPublicKey: String
    let assetCode: String
    let shortDescription: String
    let longDescription: String
    let orderIndex: Int
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case issuerPublicKey = "issuer_public_key"
        case assetCode = "asset_code"
        case shortDescription = "short_description"
        case longDescription = "long_description"
        case orderIndex = "order_index"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        issuerPublicKey = try values.decode(String.self, forKey: .issuerPublicKey)
        assetCode = try values.decode(String.self, forKey: .assetCode)
        shortDescription = try values.decode(String.self, forKey: .shortDescription)
        longDescription = try values.decode(String.self, forKey: .longDescription)
        orderIndex = try values.decode(Int.self, forKey: .orderIndex)
    }
}
