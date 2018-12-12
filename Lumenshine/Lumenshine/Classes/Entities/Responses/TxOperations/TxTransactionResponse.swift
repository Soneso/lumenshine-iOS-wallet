//
//  TxTransactionResponse.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import stellarsdk

public class TxTransactionResponse: Decodable {
    
    let opId: Int
    let opType: Int
    let opApplicationOrder: Int
    let opDetails: String
    
    let transactionHash: String
    let createdAt: Date
    let memoType: String
    let memo: String
    let operationCount: Int
    let feePaid: Int
    let sourceAccount: String
    
    let operationType: OperationType
    let operationResponse: TxOperationResponse
    
    private enum CodingKeys: String, CodingKey {
        case opId = "op_id"
        case opType = "op_type"
        case opApplicationOrder = "op_application_order"
        case opDetails = "op_details"
        
        case transactionHash = "tx_transaction_hash"
        case createdAt = "tx_created_at"
        case memoType = "tx_memo_type"
        case memo = "tx_memo"
        case operationCount = "tx_operation_count"
        case feePaid = "tx_fee_paid"
        case sourceAccount = "tx_source_account"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        opId = try values.decode(Int.self, forKey: .opId)
        opType = try values.decode(Int.self, forKey: .opType)
        opApplicationOrder = try values.decode(Int.self, forKey: .opApplicationOrder)
        opDetails = try values.decode(String.self, forKey: .opDetails)
        transactionHash = try values.decode(String.self, forKey: .transactionHash)
        createdAt = try values.decode(Date.self, forKey: .createdAt)
        memoType = try values.decode(String.self, forKey: .memoType)
        memo = try values.decode(String.self, forKey: .memo)
        operationCount = try values.decode(Int.self, forKey: .operationCount)
        feePaid = try values.decode(Int.self, forKey: .feePaid)
        sourceAccount = try values.decode(String.self, forKey: .sourceAccount)
        
        if let data = opDetails.data(using: .utf8) {
            (operationType, operationResponse) = try TxOperationResponse.create(type: opType, data: data)
        } else {
            throw ServiceError.parsingFailed(message: "Operation details parsing")
        }
    }
}
