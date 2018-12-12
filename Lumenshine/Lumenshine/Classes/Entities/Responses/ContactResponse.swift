//
//  ContactResponse.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public class ContactResponse: Decodable {
    
    let id: Int
    let userId: Int?
    let name: String
    let address: String
    let publicKey: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case userId = "user_id"
        case name = "contact_name"
        case address = "stellar_address"
        case publicKey = "public_key"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        userId = try values.decodeIfPresent(Int.self, forKey: .userId)
        name = try values.decode(String.self, forKey: .name)
        address = try values.decode(String.self, forKey: .address)
        publicKey = try values.decode(String.self, forKey: .publicKey)
    }
}
