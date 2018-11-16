//
//  TxPaymentOperationResponse.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 14/11/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

class TxPaymentOperationResponse: TxOperationResponse {
    
    /// Amount sent.
    public let amount:String
    
    /// Asset type (native / alphanum4 / alphanum12)
    public let assetType:String
    
    /// Code of the destination asset.
    public let assetCode:String?
    
    /// Asset issuer.
    public let assetIssuer:String?
    
    /// Sender of a payment.
    public let from:String
    
    /// Destination of a payment.
    public let to:String
    
    // Properties to encode and decode
    private enum CodingKeys: String, CodingKey {
        case amount
        case assetType = "asset_type"
        case assetCode = "asset_code"
        case assetIssuer = "asset_issuer"
        case from
        case to
    }
    
    /**
     Initializer - creates a new instance by decoding from the given decoder.
     
     - Parameter decoder: The decoder containing the data
     */
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        amount = try values.decode(String.self, forKey: .amount)
        assetType = try values.decode(String.self, forKey: .assetType)
        assetCode = try values.decodeIfPresent(String.self, forKey: .assetCode)
        assetIssuer = try values.decodeIfPresent(String.self, forKey: .assetIssuer)
        from = try values.decode(String.self, forKey: .from)
        to = try values.decode(String.self, forKey: .to)
        
        try super.init(from: decoder)
    }
}
