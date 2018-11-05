//
//  TFASecretResponse.swift
//  Lumenshine
//
//  Created by Christian Rogobete on 04.11.18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public class TFASecretResponse: Decodable {
    
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
    
    init(tfaSecret: String, qrCode: String?) {
        self.tfaSecret = tfaSecret
        self.qrCode = qrCode
    }
}
