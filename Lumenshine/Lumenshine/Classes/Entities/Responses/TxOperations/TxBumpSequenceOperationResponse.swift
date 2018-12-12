//
//  TxBumpSequenceOperationResponse.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

class TxBumpSequenceOperationResponse: TxOperationResponse {
    
    /// Value to bump the sequence to.
    public let bumpTo:String
    
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
        bumpTo = try values.decode(String.self, forKey: .bumpTo)
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bumpTo, forKey: .bumpTo)
    }
}
