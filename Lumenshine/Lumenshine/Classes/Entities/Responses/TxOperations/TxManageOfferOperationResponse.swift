//
//  TxManageOfferOperationResponse.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 14/11/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

class TxManageOfferOperationResponse: TxCreatePassiveOfferOperationResponse {
    
    /// Offer ID.
    public let offerId:Int
    
    // Properties to encode and decode
    private enum CodingKeys: String, CodingKey {
        case offerId = "offer_id"
    }
    
    /**
     Initializer - creates a new instance by decoding from the given decoder.
     
     - Parameter decoder: The decoder containing the data
     */
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        offerId = try values.decode(Int.self, forKey: .offerId)
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(offerId, forKey: .offerId)
    }
}
