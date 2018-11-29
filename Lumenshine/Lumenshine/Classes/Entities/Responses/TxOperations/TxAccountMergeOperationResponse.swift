//
//  TxAccountMergeOperationResponse.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 14/11/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

class TxAccountMergeOperationResponse: TxOperationResponse {
    
    /// Account ID of the account that has been deleted.
    public let account:String
    
    /// Account ID where funds of deleted account were transferred.
    public let into:String
    
    // Properties to encode and decode
    private enum CodingKeys: String, CodingKey {
        case account
        case into
    }
    
    /**
     Initializer - creates a new instance by decoding from the given decoder.
     
     - Parameter decoder: The decoder containing the data
     */
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        account = try values.decode(String.self, forKey: .account)
        into = try values.decode(String.self, forKey: .into)
        
        try super.init(from: decoder)
    }
}
