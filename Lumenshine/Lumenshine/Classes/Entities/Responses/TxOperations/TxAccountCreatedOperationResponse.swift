//
//  TxAccountCreatedOperationResponse.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 14/11/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

class TxAccountCreatedOperationResponse: TxOperationResponse {
    
    /// Amount the account was funded.
    public let startingBalance:String
    
    /// Account that funded a new account.
    public let funder:String
    
    /// A new account that was funded.
    public let account:String
    
    // Properties to encode and decode
    private enum CodingKeys: String, CodingKey {
        case startingBalance = "starting_balance"
        case funder
        case account
    }
    
    /**
     Initializer - creates a new instance by decoding from the given decoder.
     
     - Parameter decoder: The decoder containing the data
     */
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        startingBalance = try values.decode(String.self, forKey: .startingBalance)
        funder = try values.decode(String.self, forKey: .funder)
        account = try values.decode(String.self, forKey: .account)
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(startingBalance, forKey: .startingBalance)
        try container.encode(funder, forKey: .funder)
        try container.encode(account, forKey: .account)
    }
}
