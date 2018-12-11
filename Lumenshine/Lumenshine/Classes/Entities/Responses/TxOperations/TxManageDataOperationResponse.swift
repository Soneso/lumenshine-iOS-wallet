//
//  TxManageDataOperationResponse.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 14/11/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

class TxManageDataOperationResponse: TxOperationResponse {
    
    /// Name from the (name/value pair) for an account.
    public let name:String
    
    /// Value from the (name/value pair) for an account.
    public let value:String?
    
    // Properties to encode and decode
    private enum CodingKeys: String, CodingKey {
        case name
        case value
    }
    
    /**
     Initializer - creates a new instance by decoding from the given decoder.
     
     - Parameter decoder: The decoder containing the data
     */
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        value = try values.decodeIfPresent(String.self, forKey: .value)
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(value, forKey: .value)
    }
}
