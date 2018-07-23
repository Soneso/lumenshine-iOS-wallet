//
//  LoginStep2Response.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 5/14/18.
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
