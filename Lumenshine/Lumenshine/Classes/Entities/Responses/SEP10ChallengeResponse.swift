//
//  SEP10ChallengeResponse.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
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
