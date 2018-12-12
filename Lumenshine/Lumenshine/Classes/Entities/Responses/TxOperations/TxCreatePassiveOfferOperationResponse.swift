//
//  TxCreatePassiveOfferOperationResponse.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

class TxCreatePassiveOfferOperationResponse: TxOperationResponse {
    
    /// Amount of asset to be sold.
    public let amount:String
    
    /// Price to buy a buying asset
    public let price:String
    
    /// Type of asset to buy (native / alphanum4 / alphanum12).
    public let buyingAssetType:String
    
    /// The code of asset to buy.
    public let buyingAssetCode:String?
    
    /// The issuer of asset to buy.
    public let buyingAssetIssuer:String?
    
    /// Type of asset to sell (native / credit_alphanum4 / credit_alphanum12)
    public let sellingAssetType:String
    
    /// The code of asset to sell.
    public let sellingAssetCode:String?
    
    /// The issuer of asset to sell.
    public let sellingAssetIssuer:String?
    
    // Properties to encode and decode
    private enum CodingKeys: String, CodingKey {
        case amount
        case price
        case buyingAssetType = "buying_asset_type"
        case buyingAssetCode = "buying_asset_code"
        case buyingAssetIssuer = "buying_asset_issuer"
        case sellingAssetType = "selling_asset_type"
        case sellingAssetCode = "selling_asset_code"
        case sellingAssetIssuer = "selling_asset_issuer"
        
    }
    
    /**
     Initializer - creates a new instance by decoding from the given decoder.
     
     - Parameter decoder: The decoder containing the data
     */
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        amount = try values.decode(String.self, forKey: .amount)
        price = try values.decode(String.self, forKey: .price)
        buyingAssetType = try values.decode(String.self, forKey: .buyingAssetType)
        buyingAssetCode = try values.decodeIfPresent(String.self, forKey: .buyingAssetCode)
        buyingAssetIssuer = try values.decodeIfPresent(String.self, forKey: .buyingAssetIssuer)
        sellingAssetType = try values.decode(String.self, forKey: .sellingAssetType)
        sellingAssetCode = try values.decodeIfPresent(String.self, forKey: .sellingAssetCode)
        sellingAssetIssuer = try values.decodeIfPresent(String.self, forKey: .sellingAssetIssuer)
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(amount, forKey: .amount)
        try container.encode(price, forKey: .price)
        try container.encode(buyingAssetType, forKey: .buyingAssetType)
        try container.encode(buyingAssetCode, forKey: .buyingAssetCode)
        try container.encode(buyingAssetIssuer, forKey: .buyingAssetIssuer)
        try container.encode(sellingAssetType, forKey: .sellingAssetType)
        try container.encode(sellingAssetCode, forKey: .sellingAssetCode)
        try container.encode(sellingAssetIssuer, forKey: .sellingAssetIssuer)
    }
}
