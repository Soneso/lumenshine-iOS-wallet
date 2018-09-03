//
//  KnownInflationDestinationResponse.swift
//  Lumenshine
//
//  Created by Soneso on 01/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public class KnownInflationDestinationResponse: Decodable {
    let id: Int
    let name: String
    let issuerPublicKey: String
    let shortDescription: String
    let longDescription: String
    let orderIndex: Int
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case issuerPublicKey = "issuer_public_key"
        case shortDescription = "short_description"
        case longDescription = "long_description"
        case orderIndex = "order_index"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        issuerPublicKey = try values.decode(String.self, forKey: .issuerPublicKey)
        shortDescription = try values.decode(String.self, forKey: .shortDescription)
        longDescription = try values.decode(String.self, forKey: .longDescription)
        orderIndex = try values.decode(Int.self, forKey: .orderIndex)
    }
}
