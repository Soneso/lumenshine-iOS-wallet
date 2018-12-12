//
//  LoginStep2Response.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public class LoginStep2Response: TFAResponse {
    
    let tfaSecret: String?
    let qrCode: String?
    
    private enum CodingKeys: String, CodingKey {
        
        case tfaSecret = "tfa_secret"
        case qrCode = "tfa_qr_image"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        tfaSecret = try values.decodeIfPresent(String.self, forKey: .tfaSecret)
        qrCode = try values.decodeIfPresent(String.self, forKey: .qrCode)
        try super.init(from: decoder)
    }
}
