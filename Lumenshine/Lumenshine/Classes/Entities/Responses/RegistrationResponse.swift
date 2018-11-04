//
//  RegistrationResponse.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 4/28/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public class RegistrationResponse: Decodable {
    
    let tfaSecret: String?
    let qrCode: String?
    let sep10ChallengeXDR: String
    
    private enum CodingKeys: String, CodingKey {
        
        case tfaSecret = "tfa_secret"
        case qrCode = "tfa_qr_image"
        case sep10ChallengeXDR = "sep10_transaction_challenge"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        tfaSecret = try values.decode(String.self, forKey: .tfaSecret)
        qrCode = try values.decodeIfPresent(String.self, forKey: .qrCode)
        sep10ChallengeXDR = try values.decode(String.self, forKey: .sep10ChallengeXDR)
    }
    
    init(tfaSecret: String, qrCode: String, sep10ChallengeXDR: String) {
        self.tfaSecret = tfaSecret
        self.qrCode = qrCode
        self.sep10ChallengeXDR = sep10ChallengeXDR
    }
}
