//
//  TransactionHistoryManager.swift
//  Lumenshine
//
//  Created by Soneso on 31/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import stellarsdk

enum TransactionHistoryEnum {
    case success(operations: [OperationInfo], cursor: String?)
    case failure(error: HorizonRequestError)
}

typealias TransactionsHistoryClosure = (_ response: TransactionHistoryEnum) -> (Void)

class TransactionHistoryManager {
    private var stellarSdk: StellarSDK {
        get {
            return Services.shared.stellarSdk
        }
    }
    
    func getTransactionsHistory(forAccount account: String, fromCursor cursor: String? = nil, completion: @escaping TransactionsHistoryClosure) {
        stellarSdk.payments.getPayments(forAccount: account, from: cursor, order: Order.descending) { (response) -> (Void) in
            switch response {
            case .success(details: let details):
                var token: String? = nil
                if let pagingToken = details.records.last?.pagingToken {
                    token = pagingToken
                }
                
                self.getOperations(forOperations: details.records, forAccount: account, completion: { (operations) -> (Void) in
                    DispatchQueue.main.async {
                        completion(.success(operations: operations, cursor: token))
                    }
                })
                
                break
            case .failure(error: let error):
                DispatchQueue.main.async {
                    completion(.failure(error: error))
                }
                break
            }
        }
    }
    
    private func getMemoForTransaction(fromHash transactionHash:String, forOperation operation: OperationInfo, completion: @escaping (() -> (Void))) {
        stellarSdk.transactions.getTransactionDetails(transactionHash: transactionHash, response: { (response) -> (Void) in
            switch response {
            case .success(details: let transaction):
                if let memo = transaction.memo {
                    switch memo {
                    case .text(let text):
                        operation.memo = text
                        break
                    case .id(let id):
                        operation.memo = String(id)
                        break
                    case .hash(let data):
                        operation.memo = data.toHexString()
                        break
                    case .returnHash(let data):
                        operation.memo = data.toHexString()
                        break
                    case .none:
                        break
                    }
                }
                
                completion()
                break
                
            case .failure(error: let error):
                print("Error: \(error)")
                completion()
            }
        })
    }
    
    private func getOperations(forOperations operations: [OperationResponse], forAccount account: String, completion: @escaping (([OperationInfo]) -> (Void))) {
        var operationsToReturn = [OperationInfo]()
        var memosReturned = 0
        
        if memosReturned == operations.count {
            completion(operationsToReturn)
        }
        
        for record in operations {
            let operation: OperationInfo = OperationInfo()
            operation.operationID = record.id
            operation.operationType = record.operationTypeString
            operation.date = record.createdAt
            
            switch record.operationType {
            case .accountCreated:
                // AccountCreatedOperationResponse
                if let accountCreatedOperation = record as? AccountCreatedOperationResponse {
                    operation.amount = "\(accountCreatedOperation.startingBalance)"
                    operation.assetCode = NativeCurrencyNames.xlm.rawValue
                    operation.sign = accountCreatedOperation.sourceAccount == account ? SignEnum.minus : SignEnum.plus
                }
                
                break
                
            case .accountMerge:
                // AccountMergeOperationResponse
                if let _ = record as? AccountMergeOperationResponse {
                    operation.amount = "0"
                    operation.assetCode = NativeCurrencyNames.xlm.rawValue
                    operation.sign = SignEnum.plus
                }
                
                break
                
            case .allowTrust:
                // AllowTrustOperationResponse
                if let allowTrustOperationResponse = record as? AllowTrustOperationResponse {
                    operation.amount = "0"
                    operation.assetCode = allowTrustOperationResponse.assetCode ?? NativeCurrencyNames.xlm.rawValue
                    operation.sign = SignEnum.plus
                }
                
                break
                
            case .changeTrust:
                // ChangeTrustOperationResponse
                if let changeTrustOperationResponse = record as? ChangeTrustOperationResponse {
                    operation.amount = "0"
                    operation.assetCode = changeTrustOperationResponse.assetCode ?? NativeCurrencyNames.xlm.rawValue
                    operation.sign = SignEnum.plus
                }
                
                break
                
            case .createPassiveOffer:
                // CreatePassiveOfferOperationResponse
                if let createPassiveOfferOperationResponse = record as? CreatePassiveOfferOperationResponse {
                    operation.amount = createPassiveOfferOperationResponse.amount
                    operation.assetCode = createPassiveOfferOperationResponse.sellingAssetCode
                    operation.sign = record.sourceAccount == account ? SignEnum.minus : SignEnum.plus
                }
                
                break
                
            case .inflation:
                // InflationOperationResponse
                if let _ = record as? InflationOperationResponse {
                    operation.amount = "0"
                    operation.assetCode = NativeCurrencyNames.xlm.rawValue
                    operation.sign = SignEnum.plus
                }
                
                break
                
            case .manageData:
                // ManageDataOperationResponse
                if let manageDataOperationResponse = record as? ManageDataOperationResponse {
                    operation.amount = manageDataOperationResponse.value
                    operation.assetCode = NativeCurrencyNames.xlm.rawValue
                    operation.sign = SignEnum.plus
                }
                
                break
                
            case .manageOffer:
                // ManageOfferOperationResponse
                if let manageOffferOperationResponse = record as? ManageOfferOperationResponse {
                    operation.amount = manageOffferOperationResponse.amount
                    operation.assetCode = manageOffferOperationResponse.sellingAssetCode
                    operation.sign = SignEnum.minus
                }
                
                break
                
            case .pathPayment:
                // PathPaymentOperationResponse
                if let pathPaymentOperationResponse = record as? PathPaymentOperationResponse {
                    operation.amount = pathPaymentOperationResponse.amount
                    operation.assetCode = pathPaymentOperationResponse.assetCode ?? NativeCurrencyNames.xlm.rawValue
                    operation.sign = pathPaymentOperationResponse.from == account ? SignEnum.minus : SignEnum.plus
                }
                
                break
                
            case .payment:
                // PaymentOperationResponse
                if let paymentOperation = record as? PaymentOperationResponse {
                    operation.amount = paymentOperation.amount
                    operation.assetCode = paymentOperation.assetCode ?? NativeCurrencyNames.xlm.rawValue
                    operation.sign = paymentOperation.to == account ? SignEnum.plus : SignEnum.minus
                }
                
                break
            case .setOptions:
                // SetOptionsOperationResponse
                if let setOptionsOperation = record as? SetOptionsOperationResponse {
                    operation.amount = "\(setOptionsOperation.lowThreshold ?? 0)"
                    operation.assetCode = NativeCurrencyNames.xlm.rawValue
                    operation.sign = SignEnum.minus
                }
                
                break
            case .bumpSequence:
                if let _ = record as? BumpSequenceOperationResponse {
                    operation.amount = "0"
                    operation.sign = SignEnum.minus
                }
                
                break
            }
            
            operationsToReturn.append(operation)
            
            self.getMemoForTransaction(fromHash: record.transactionHash, forOperation: operation) {
                memosReturned += 1

                if memosReturned == operations.count {
                    completion(operationsToReturn)
                }
            }
        }
    }
}
