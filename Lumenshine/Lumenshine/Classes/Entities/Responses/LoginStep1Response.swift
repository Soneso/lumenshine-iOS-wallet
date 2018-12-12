//
//  LoginStep1Response.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public class LoginStep1Response: AuthenticationResponse {
    
    let sep10TransactionEnvelopeXDR: String
    
    private enum CodingKeys: String, CodingKey {
        case sep10TransactionEnvelopeXDR = "sep10_transaction_challenge"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        sep10TransactionEnvelopeXDR = try values.decode(String.self, forKey: .sep10TransactionEnvelopeXDR)
        try super.init(from: decoder)
    }
}
