//
//  ChangeWallettRequest.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

struct ChangeWalletRequest: Codable {
    var id: Int
    var walletName: String?
    var federationAddress: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case walletName = "wallet_name"
        case federationAddress = "federation_address"
    }
    
    init(id: Int) {
        self.id = id
    }
    
    func toDictionary() -> [String:Any] {
        var dict = [String:Any]()
        dict[CodingKeys.id.rawValue] = id
        dict[CodingKeys.walletName.rawValue] = walletName
        dict[CodingKeys.federationAddress.rawValue] = federationAddress
        return dict
    }
}
