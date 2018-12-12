//
//  TransactionsService.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public enum TransactionsResponseEnum {
    case success(response: [TxTransactionResponse])
    case failure(error: ServiceError)
}

public typealias TransactionsResponseClosure = ( _ response: TransactionsResponseEnum) -> (Void)

public class TransactionsService: BaseService {
    override init(baseURL: String) {
        super.init(baseURL: baseURL)
    }
    
    func getTransactions(stellarAccount: String, startTime: String, endTime: String, response: @escaping TransactionsResponseClosure) {
        var params = Dictionary<String, String>()
        params["stellar_account_pk"] = stellarAccount
        params["start_timestamp"] = startTime
        params["end_timestamp"] = endTime
        
        GETRequestWithPath(path: "/portal/user/dashboard/get_stellar_transactions", parameters: params) { (result) -> (Void) in
            switch result {
            case .success(let data):
                if data.isEmpty {
                    response(.success(response: []))
                    return
                }
                if let dataString = String(data: data, encoding: String.Encoding.utf8), dataString == "null" {
                    response(.success(response: []))
                    return
                }
                do {
                    let operations = try self.jsonDecoder.decode(Array<TxTransactionResponse>.self, from: data)
                    response(.success(response: operations))
                } catch {
                    response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                }
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
}
