//
//  AddContactResponse.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 10/3/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public class AddContactResponse: Decodable {
    
    let id: Int
    let contacts: Array<ContactResponse>
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case contacts = "contacts"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        contacts = try values.decode(Array<ContactResponse>.self, forKey: .contacts)
    }
}
