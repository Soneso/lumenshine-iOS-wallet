//
//  TxSetOptionsOperationResponse.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

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
    public let clearFlagsString:[String]?
    public let clearFlags:[Int]?
    
    /// The array of numeric values of flags that has been set in this operation
    public let setFlagsString:[String]?
    public let setFlags:[Int]?
    
    
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
        case clearFlagsString = "clear_flags_s"
        case clearFlags = "clear_flags"
        case setFlagsString = "set_flags_s"
        case setFlags = "set_flags"
        
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
        clearFlagsString = try values.decodeIfPresent(Array<String>.self, forKey: .clearFlagsString)
        clearFlags = try values.decodeIfPresent(Array<Int>.self, forKey: .clearFlags)
        setFlagsString = try values.decodeIfPresent(Array<String>.self, forKey: .setFlagsString)
        setFlags = try values.decodeIfPresent(Array<Int>.self, forKey: .setFlags)
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lowThreshold, forKey: .lowThreshold)
        try container.encode(medThreshold, forKey: .medThreshold)
        try container.encode(highThreshold, forKey: .highThreshold)
        try container.encode(inflationDestination, forKey: .inflationDestination)
        try container.encode(homeDomain, forKey: .homeDomain)
        try container.encode(signerKey, forKey: .signerKey)
        try container.encode(signerWeight, forKey: .signerWeight)
        try container.encode(masterKeyWeight, forKey: .masterKeyWeight)
        try container.encode(clearFlagsString, forKey: .clearFlagsString)
        try container.encode(clearFlags, forKey: .clearFlags)
        try container.encode(setFlagsString, forKey: .setFlagsString)
        try container.encode(setFlags, forKey: .setFlags)
    }
}
