//
//  RegistrationResponse.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 4/28/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public class RegistrationResponse: Decodable {
    
    let tfaSecret: String
    let qrCode: String?
    
    private enum CodingKeys: String, CodingKey {
        
        case tfaSecret = "tfa_secret"
        case qrCode = "tfa_qr_image"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        tfaSecret = try values.decode(String.self, forKey: .tfaSecret)
        qrCode = try values.decodeIfPresent(String.self, forKey: .qrCode)
    }
    
    init(tfaSecret: String, qrCode: String) {
        self.tfaSecret = tfaSecret
        self.qrCode = qrCode
    }
}
