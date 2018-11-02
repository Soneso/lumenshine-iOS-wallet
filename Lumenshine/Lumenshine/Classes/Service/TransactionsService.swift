//
//  TransactionsService.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 02/11/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import stellarsdk

public enum TransactionsResponseEnum {
    case success(response: [TransactionResponse])
    case failure(error: ServiceError)
}

public typealias TransactionsResponseClosure = ( _ response: TransactionsResponseEnum) -> (Void)

public class TransactionsService: BaseService {
    override init(baseURL: String) {
        super.init(baseURL: baseURL)
    }
    
    func getTransactions(response: @escaping TransactionsResponseClosure) {
        GETRequestWithPath(path: "/portal/user/dashboard/get_stellar_transactions") { (result) -> (Void) in
            switch result {
            case .success(let data):
                do {
                    let contacts = try self.jsonDecoder.decode(Array<TransactionResponse>.self, from: data)
                    response(.success(response: contacts))
                } catch {
                    response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                }
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
}
