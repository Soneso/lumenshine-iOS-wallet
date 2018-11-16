//
//  TxSetOptionsOperationResponse.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 14/11/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import stellarsdk

class TxSetOptionsOperationResponse: TxOperationResponse {
    
    /// The sum weight for the low threshold.
    public let lowThreshold:Int?
    
    /// The sum weight for the medium threshold.
    public let medThreshold:Int?
    
    /// The sum weight for the high threshold.
    public let highThreshold:Int?
    
    /// The inflation destination account.
    public let inflationDestination:String?
    
    /// The home domain used for reverse federation lookup
    public let homeDomain:String?
    
    /// The public key of the new signer.
    public let signerKey:String?
    
    /// The weight of the new signer (1-255).
    public let signerWeight:Int?
    
    /// The weight of the master key (1-255).
    public let masterKeyWeight:Int?
    
    /// The array of numeric values of flags that has been cleared in this operation
    public let clearFlags:AccountFlagsResponse?
    
    /// The array of numeric values of flags that has been set in this operation
    public let setFlags:AccountFlagsResponse?
    
    
    // Properties to encode and decode
    private enum CodingKeys: String, CodingKey {
        case lowThreshold = "low_threshold"
        case medThreshold = "med_threshold"
        case highThreshold = "high_threshold"
        case inflationDestination = "inflation_dest"
        case homeDomain = "home_domain"
        case signerKey = "signer_key"
        case signerWeight = "signer_weight"
        case masterKeyWeight = "master_key_weight"
        case clearFlags = "clear_flags_s"
        case setFlags = "set_flags_s"
        
    }
    
    /**
     Initializer - creates a new instance by decoding from the given decoder.
     
     - Parameter decoder: The decoder containing the data
     */
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lowThreshold = try values.decodeIfPresent(Int.self, forKey: .lowThreshold)
        medThreshold = try values.decodeIfPresent(Int.self, forKey: .medThreshold)
        highThreshold = try values.decodeIfPresent(Int.self, forKey: .highThreshold)
        inflationDestination = try values.decodeIfPresent(String.self, forKey: .inflationDestination)
        homeDomain = try values.decodeIfPresent(String.self, forKey: .homeDomain)
        signerKey = try values.decodeIfPresent(String.self, forKey: .signerKey)
        signerWeight = try values.decodeIfPresent(Int.self, forKey: .signerWeight)
        masterKeyWeight = try values.decodeIfPresent(Int.self, forKey: .masterKeyWeight)
        clearFlags = try values.decodeIfPresent(AccountFlagsResponse.self, forKey: .clearFlags)
        setFlags = try values.decodeIfPresent(AccountFlagsResponse.self, forKey: .setFlags)
        
        try super.init(from: decoder)
    }
}
