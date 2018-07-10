//
//  WalletsResponse.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 05/07/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

public class WalletsResponse: Decodable {
    let id: Int
    let publicKey: String
    let walletName: String
    let federationNickname: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case publicKey = "public_key_0"
        case walletName = "wallet_name"
        case federationNickname = "federation_nickname"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        publicKey = try values.decode(String.self, forKey: .publicKey)
        walletName = try values.decode(String.self, forKey: .walletName)
        federationNickname = try values.decode(String.self, forKey: .federationNickname)
    }
    
}
