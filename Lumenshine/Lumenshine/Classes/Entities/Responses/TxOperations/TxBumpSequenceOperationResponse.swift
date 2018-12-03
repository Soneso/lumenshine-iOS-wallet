//
//  TxBumpSequenceOperationResponse.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 14/11/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

class TxBumpSequenceOperationResponse: TxOperationResponse {
    
    /// Value to bump the sequence to.
    public let bumpTo:UInt64
    
    // Properties to encode and decode
    private enum CodingKeys: String, CodingKey {
        case bumpTo = "bump_to"
    }
    
    /**
     Initializer - creates a new instance by decoding from the given decoder.
     
     - Parameter decoder: The decoder containing the data
     */
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        bumpTo = try values.decode(UInt64.self, forKey: .bumpTo)
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bumpTo, forKey: .bumpTo)
    }
    
}
