//
//  TFAResponse.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 4/30/18.
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
