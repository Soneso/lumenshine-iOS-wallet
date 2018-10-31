//
//  SEP10ChallengeResponse.swift
//  Lumenshine
//
//  Created by Soneso on 31.10.18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public class SEP10ChallengeResponse: Decodable {
    
    let transactionEnvelopeXDR: String
    
    private enum CodingKeys: String, CodingKey {
        
        case transactionEnvelopeXDR = "sep10_transaction"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        transactionEnvelopeXDR = try values.decode(String.self, forKey: .transactionEnvelopeXDR)
    }
}
