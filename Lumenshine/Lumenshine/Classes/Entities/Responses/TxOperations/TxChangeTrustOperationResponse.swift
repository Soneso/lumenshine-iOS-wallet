//
//  TxChangeTrustOperationResponse.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

class TxChangeTrustOperationResponse: TxOperationResponse {
    
    /// Trustor account.
    public let trustor:String
    
    /// Trustee account.
    public let trustee:String
    
    /// Asset type (native / credit_alphanum4 / credit_alphanum12)
    public let assetType:String
    
    /// Asset code.
    public let assetCode:String?
    
    /// Asset issuer.
    public let assetIssuer:String?
    
    /// The limit for the asset.
    public let limit:String?
    
    // Properties to encode and decode
    private enum CodingKeys: String, CodingKey {
        case trustor
        case trustee
        case assetType = "asset_type"
        case assetCode = "asset_code"
        case assetIssuer = "asset_issuer"
        case limit
    }
    
    /**
     Initializer - creates a new instance by decoding from the given decoder.
     
     - Parameter decoder: The decoder containing the data
     */
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        trustor = try values.decode(String.self, forKey: .trustor)
        trustee = try values.decode(String.self, forKey: .trustee)
        assetType = try values.decode(String.self, forKey: .assetType)
        assetCode = try values.decodeIfPresent(String.self, forKey: .assetCode)
        assetIssuer = try values.decodeIfPresent(String.self, forKey: .assetIssuer)
        limit = try values.decodeIfPresent(String.self, forKey: .limit)
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(trustor, forKey: .trustor)
        try container.encode(trustee, forKey: .trustee)
        try container.encode(assetType, forKey: .assetType)
        try container.encode(assetCode, forKey: .assetCode)
        try container.encode(assetIssuer, forKey: .assetIssuer)
        try container.encode(limit, forKey: .limit)
    }
}
