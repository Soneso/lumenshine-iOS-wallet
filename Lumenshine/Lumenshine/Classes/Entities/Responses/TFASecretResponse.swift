//
//  TFASecretResponse.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public class TFASecretResponse: Decodable {
    
    let tfaSecret: String
    
    private enum CodingKeys: String, CodingKey {
        
        case tfaSecret = "tfa_secret"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        tfaSecret = try values.decode(String.self, forKey: .tfaSecret)
    }
    
    init(tfaSecret: String, qrCode: String?) {
        self.tfaSecret = tfaSecret
    }
}
