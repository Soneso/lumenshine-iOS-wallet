//
//  TxOperationResponse.swift
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

class TxOperationResponse: Codable {
    public static func create(type: Int, data: Data) throws -> (OperationType, TxOperationResponse)  {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601)
        
        guard let opType = OperationType(rawValue: Int32(type)) else {
            throw HorizonRequestError.parsingResponseFailed(message: "Unknown operation type")
        }
        var response: TxOperationResponse
        switch opType {
        case .accountCreated:
            response = try jsonDecoder.decode(TxAccountCreatedOperationResponse.self, from: data)
        case .payment:
            response = try jsonDecoder.decode(TxPaymentOperationResponse.self, from: data)
        case .pathPayment:
            response = try jsonDecoder.decode(TxPathPaymentOperationResponse.self, from: data)
        case .manageOffer:
            response = try jsonDecoder.decode(TxManageOfferOperationResponse.self, from: data)
        case .createPassiveOffer:
            response = try jsonDecoder.decode(TxCreatePassiveOfferOperationResponse.self, from: data)
        case .setOptions:
            response = try jsonDecoder.decode(TxSetOptionsOperationResponse.self, from: data)
        case .changeTrust:
            response = try jsonDecoder.decode(TxChangeTrustOperationResponse.self, from: data)
        case .allowTrust:
            response = try jsonDecoder.decode(TxAllowTrustOperationResponse.self, from: data)
        case .accountMerge:
            response = try jsonDecoder.decode(TxAccountMergeOperationResponse.self, from: data)
        case .inflation:
            response = try jsonDecoder.decode(TxInflationOperationResponse.self, from: data)
        case .manageData:
            response = try jsonDecoder.decode(TxManageDataOperationResponse.self, from: data)
        case .bumpSequence:
            response = try jsonDecoder.decode(TxBumpSequenceOperationResponse.self, from: data)
        }
        return (opType, response)
    }
    
}
