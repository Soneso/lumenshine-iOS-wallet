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
    let federationAddress: String
    let showOnHomeScreen: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case publicKey = "public_key"
        case walletName = "wallet_name"
        case federationAddress = "federation_address"
        case showOnHomeScreen = "show_on_homescreen"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        publicKey = try values.decode(String.self, forKey: .publicKey)
        walletName = try values.decode(String.self, forKey: .walletName)
        federationAddress = try values.decode(String.self, forKey: .federationAddress)
        showOnHomeScreen = try values.decode(Bool.self, forKey: .showOnHomeScreen)
    }
    
}
