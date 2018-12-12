//
//  TxPathPaymentOperationResponse.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

class TxPathPaymentOperationResponse: TxOperationResponse {
    
    /// Amount received.
    public let amount:String
    
    /// Amount sent.
    public let sourceAmount:String
    
    /// Sender of a payment.
    public let from:String
    
    /// Destination of a payment.
    public let to:String
    
    /// Destination asset type (native / alphanum4 / alphanum12)
    public let assetType:String
    
    /// Code of the destination asset.
    public let assetCode:String?
    
    /// Destination asset issuer.
    public let assetIssuer:String?
    
    /// Source asset type (native / alphanum4 / alphanum12).
    public let sendAssetType:String
    
    /// Code of the source asset.
    public let sendAssetCode:String?
    
    /// Source asset issuer.
    public let sendAssetIssuer:String?
    
    // Properties to encode and decode
    private enum CodingKeys: String, CodingKey {
        case amount
        case sourceAmount = "source_amount"
        case from
        case to
        case assetType = "asset_type"
        case assetCode = "asset_code"
        case assetIssuer = "asset_issuer"
        case sendAssetType = "send_asset_type"
        case sendAssetCode = "send_asset_code"
        case sendAssetIssuer = "send_asset_issuer"
        
    }
    
    /**
     Initializer - creates a new instance by decoding from the given decoder.
     
     - Parameter decoder: The decoder containing the data
     */
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        amount = try values.decode(String.self, forKey: .amount)
        sourceAmount = try values.decode(String.self, forKey: .sourceAmount)
        from = try values.decode(String.self, forKey: .from)
        to = try values.decode(String.self, forKey: .to)
        assetType = try values.decode(String.self, forKey: .assetType)
        assetCode = try values.decodeIfPresent(String.self, forKey: .assetCode)
        assetIssuer = try values.decodeIfPresent(String.self, forKey: .assetIssuer)
        sendAssetType = try values.decode(String.self, forKey: .sendAssetType)
        sendAssetCode = try values.decodeIfPresent(String.self, forKey: .sendAssetCode)
        sendAssetIssuer = try values.decodeIfPresent(String.self, forKey: .sendAssetIssuer)
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(amount, forKey: .amount)
        try container.encode(sourceAmount, forKey: .sourceAmount)
        try container.encode(from, forKey: .from)
        try container.encode(to, forKey: .to)
        try container.encode(assetType, forKey: .assetType)
        try container.encode(assetCode, forKey: .assetCode)
        try container.encode(assetIssuer, forKey: .assetIssuer)
        try container.encode(sendAssetType, forKey: .sendAssetType)
        try container.encode(sendAssetCode, forKey: .sendAssetCode)
        try container.encode(sendAssetIssuer, forKey: .sendAssetIssuer)
    }
}
