//
//  WalletsService.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 05/07/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

public enum GetWalletsEnum {
    case success(response: [WalletsResponse])
    case failure(error: ServiceError)
}

public typealias GetWalletsClosure = (_ response:GetWalletsEnum) -> (Void)

public class WalletsService: BaseService {
    
    override init(baseURL: String) {
        super.init(baseURL: baseURL)
    }
    
    open func getWallets(response: @escaping GetWalletsClosure) {
        GETRequestWithPath(path: "/portal/user/dashboard/get_user_wallets") { (result) -> (Void) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    do {
                        let userWalletsResponse = try self.jsonDecoder.decode(Array<WalletsResponse>.self, from: data)
                        response(.success(response: userWalletsResponse))
                    } catch {
                        response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                    }
                case .failure(let error):
                    response(.failure(error: error))
                }
            }
        }
    }
    
}
