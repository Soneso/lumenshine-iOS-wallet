//
//  LoginStep2Response.swift
//  Stellargate
//
//  Created by Istvan Elekes on 5/14/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public class LoginStep2Response: Decodable {
    
    let tfaSecret: String?
    let qrCode: String?
    let mailConfirmed: Bool?
    let tfaConfirmed: Bool?
    let mnemonicConfirmed: Bool?
    
    private enum CodingKeys: String, CodingKey {
        
        case tfaSecret = "tfa_secret"
        case qrCode = "tfa_qr_image"
        case mailConfirmed = "mail_confirmed"
        case tfaConfirmed = "tfa_confirmed"
        case mnemonicConfirmed = "menmonic_confirmed"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        tfaSecret = try values.decodeIfPresent(String.self, forKey: .tfaSecret)
        qrCode = try values.decodeIfPresent(String.self, forKey: .qrCode)
        mailConfirmed = try values.decodeIfPresent(Bool.self, forKey: .mailConfirmed)
        tfaConfirmed = try values.decodeIfPresent(Bool.self, forKey: .tfaConfirmed)
        mnemonicConfirmed = try values.decodeIfPresent(Bool.self, forKey: .mnemonicConfirmed)
    }
}
