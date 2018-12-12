//
//  TFAResponse.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public class TFAResponse: Decodable {
    
    let mailConfirmed: Bool
    let tfaConfirmed: Bool
    let mnemonicConfirmed: Bool
    
    private enum CodingKeys: String, CodingKey {
        
        case mailConfirmed = "mail_confirmed"
        case tfaConfirmed = "tfa_confirmed"
        case mnemonicConfirmed = "mnemonic_confirmed"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        mailConfirmed = try values.decode(Bool.self, forKey: .mailConfirmed)
        tfaConfirmed = try values.decode(Bool.self, forKey: .tfaConfirmed)
        mnemonicConfirmed = try values.decode(Bool.self, forKey: .mnemonicConfirmed)
    }
}
