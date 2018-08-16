//
//  SendTransaction.swift
//  Lumenshine
//
//  Created by Ionut Teslovan on 09/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import stellarsdk

public class TransactionHelper {
    private var inputData: TransactionInput
    private var wallet: FoundedWallet
    private var transactionResult: TransactionResult
    
    private var stellarSdk: StellarSDK {
        get {
            return Services.shared.stellarSdk
        }
    }
    
    init(transactionInputData: TransactionInput, wallet: FoundedWallet) {
        inputData = transactionInputData
        self.wallet = wallet
        
        transactionResult = TransactionResult()
        transactionResult.amount = inputData.amount
        transactionResult.currency = inputData.currency
        transactionResult.issuer = inputData.issuer
    }
    
    public func createAndFundAccount() -> TransactionResult {
        // source account
        let sourceAccountKeyPair = try? stellarsdk.Wallet.createKeyPair(mnemonic: inputData.userMnemonic, passphrase: nil, index: 0)
        
        // destination account
        let destinationAccountKeyPair = try? KeyPair(accountId: inputData.address)
        
        var memo = Memo.none
        
        if inputData.memo != nil {
            if let memoType = inputData.memoType {
                memo = getMemo(memoType: memoType) ?? Memo.none
                transactionResult.memo = inputData.memo
                transactionResult.memoType = memoType
            } else {
                transactionResult.memoType = MemoTypeValues.MEMO_TEXT
            }
        }
        
        if let accountID = destinationAccountKeyPair?.publicKey.accountId {
            transactionResult.recipentPK = accountID
            transactionResult.recipentMail = inputData.address != accountID ? accountID : ""
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        if let sourceKeyPair = sourceAccountKeyPair,
            let destinationKeyPair = destinationAccountKeyPair,
            let amount = CoinUnit(self.inputData.amount) {
            // load the source account from horizon to be sure that we have the current sequence number.
            stellarSdk.accounts.getAccountDetails(accountId: sourceKeyPair.accountId) { (response) -> (Void) in
                switch response {
                case .success(let accountResponse): // source account successfully loaded.
                    do {
                        // build a create account operation.
                        let createAccount = CreateAccountOperation(destination: destinationKeyPair, startBalance: Decimal(amount))
                        
                        // build a transaction that contains the create account operation.
                        let transaction = try Transaction(sourceAccount: accountResponse,
                                                          operations: [createAccount],
                                                          memo: memo,
                                                          timeBounds: nil)
                        
                        // sign the transaction.
                        try transaction.sign(keyPair: sourceKeyPair, network: Network.testnet)
                        
                        // submit the transaction to the stellar network.
                        try self.stellarSdk.transactions.submitTransaction(transaction: transaction) { (response) -> (Void) in
                            switch response {
                            case .success(_):
                                print("Account successfully created.")
                                self.transactionResult.status = TransactionStatus.success
                                self.transactionResult.transactionFee = String(transaction.fee)
                                
                                if let transactionHash = try? transaction.getTransactionHash(network: Network.testnet) {
                                    self.stellarSdk.payments.getPayments(forTransaction: transactionHash, response: { (response) -> (Void) in
                                        switch response {
                                        case .success(details: let details):
                                            self.transactionResult.operationID = details.records.first?.id
                                            semaphore.signal()
                                            break
                                        case .failure(error: let error):
                                            self.transactionResult.status = TransactionStatus.error
                                            self.transactionResult.message = error.localizedDescription
                                            semaphore.signal()
                                            break
                                        }
                                    })
                                }
                                
                            case .failure(let error):
                                StellarSDKLog.printHorizonRequestErrorMessage(tag:"Create account", horizonRequestError: error)
                                self.transactionResult.status = TransactionStatus.error
                                self.transactionResult.message = error.localizedDescription
                                self.transactionResult.transactionFee = transaction.fee > 0 ? String(transaction.fee) : nil
                                semaphore.signal()
                            }
                        }
                    } catch {
                        // ...
                    }
                case .failure(let error):
                    StellarSDKLog.printHorizonRequestErrorMessage(tag:"Error:", horizonRequestError: error)
                    self.transactionResult.status = TransactionStatus.error
                    self.transactionResult.message = error.localizedDescription
                    semaphore.signal()
                }
            }
        }
        
        semaphore.wait()
        return transactionResult
    }
    
    private func getAssettypeIntValue(assetType: String) -> Int32 {
        switch assetType {
        case AssetTypeAsString.NATIVE:
            return AssetType.ASSET_TYPE_NATIVE
        case AssetTypeAsString.CREDIT_ALPHANUM4:
            return AssetType.ASSET_TYPE_CREDIT_ALPHANUM4
        case AssetTypeAsString.CREDIT_ALPHANUM12:
            return AssetType.ASSET_TYPE_CREDIT_ALPHANUM12
        default:
            return Int32()
        }
    }
    
    private func getMemo(memoType: MemoTypeValues) -> Memo? {
        if let memoType = inputData.memoType {
            switch memoType {
            case MemoTypeValues.MEMO_TEXT:
                return try? Memo.init(text: inputData.memo!) ?? Memo.none
            case MemoTypeValues.MEMO_ID:
                return Memo.id(UInt64(inputData.memo!)!)
            case MemoTypeValues.MEMO_HASH:
                return try? Memo.init(hash: Data.init(base64Encoded: inputData.memo!)!) ?? Memo.none
            case MemoTypeValues.MEMO_RETURN:
                return try? Memo.init(returnHash: Data.init(base64Encoded: inputData.memo!)!) ?? Memo.none
            }
        }
        
       return Memo.none
    }
    
    public func sendPayment() -> TransactionResult {
        // source account
        let sourceAccountKeyPair = try? stellarsdk.Wallet.createKeyPair(mnemonic: inputData.userMnemonic, passphrase: nil, index: 0)
        
        // destination account
        let destinationAccountKeyPair = try? KeyPair(accountId: inputData.address)
        
        var assetIssuerKeyPair: KeyPair? = nil
        var assetTypeIntValue: Int32 = -1
        var selectedAsset: Asset? = Asset(type: AssetType.ASSET_TYPE_NATIVE)
        
        if let selectedCurrency = wallet.balances.first(where: { (asset) -> Bool in
            if inputData.currency == NativeCurrencyNames.xlm.rawValue {
                return asset.assetCode == nil
            }
            
            if inputData.issuer?.isEmpty == false {
                return asset.assetCode == inputData.currency && asset.assetIssuer == inputData.issuer
            }
            
            return asset.assetCode == inputData.currency
        }) {
            if let assetIssuer = selectedCurrency.assetIssuer {
                assetIssuerKeyPair = try? KeyPair(accountId: assetIssuer)
                assetTypeIntValue = getAssettypeIntValue(assetType: selectedCurrency.assetType)
                selectedAsset = Asset.init(type: assetTypeIntValue, code: selectedCurrency.assetCode, issuer: assetIssuerKeyPair)
            }
        }
        
        var memo = Memo.none
        
        if inputData.memo != nil {
            if let memoType = inputData.memoType {
                memo = getMemo(memoType: memoType) ?? Memo.none
                transactionResult.memo = inputData.memo
                transactionResult.memoType = memoType
            } else {
                transactionResult.memoType = MemoTypeValues.MEMO_TEXT
            }
        }
        
        if let accountID = destinationAccountKeyPair?.publicKey.accountId {
            transactionResult.recipentPK = accountID
            transactionResult.recipentMail = inputData.address != accountID ? accountID : ""
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        if let asset = selectedAsset,
            let destinationKeyPair = destinationAccountKeyPair,
            let sourceKeyPair = sourceAccountKeyPair,
            let amount = CoinUnit(self.inputData.amount) {
            // get the account data to be sure that we have the current sequence number.
            stellarSdk.accounts.getAccountDetails(accountId: sourceKeyPair.accountId) { (response) -> (Void) in
                switch response {
                case .success(let accountResponse):
                    do {
                        // build the payment operation
                        let paymentOperation = PaymentOperation(destination: destinationKeyPair,
                                                                asset: asset,
                                                                amount: Decimal(amount))
                        
                        // build the transaction containing our payment operation.
                        let transaction = try Transaction(sourceAccount: accountResponse,
                                                          operations: [paymentOperation],
                                                          memo: memo,
                                                          timeBounds: nil)
                        // sign the transaction
                        try transaction.sign(keyPair: sourceKeyPair, network: Network.testnet)
                        
                        // submit the transaction.
                        try self.stellarSdk.transactions.submitTransaction(transaction: transaction) { (response) -> (Void) in
                            switch response {
                            case .success(_):
                                print("Success")
                                self.transactionResult.status = TransactionStatus.success
                                self.transactionResult.transactionFee = String(transaction.fee)
                                
                                self.stellarSdk.payments.getPayments(forTransaction: try! transaction.getTransactionHash(network: Network.testnet), response: { (response) -> (Void) in
                                    switch response {
                                    case .success(details: let details):
                                        self.transactionResult.operationID = details.records.first?.id
                                        semaphore.signal()
                                        break
                                    case .failure(error: let error):
                                        self.transactionResult.status = TransactionStatus.error
                                        self.transactionResult.message = error.localizedDescription
                                        semaphore.signal()
                                        break
                                    }
                                })
                                
                            case .failure(let error):
                                StellarSDKLog.printHorizonRequestErrorMessage(tag:"SRP Test", horizonRequestError:error)
                                self.transactionResult.status = TransactionStatus.error
                                self.transactionResult.message = error.localizedDescription
                                self.transactionResult.transactionFee = transaction.fee > 0 ? String(transaction.fee) : nil
                                semaphore.signal()
                            }
                        }
                    } catch {
                    }
                case .failure(let error):
                    StellarSDKLog.printHorizonRequestErrorMessage(tag:"SRP Test", horizonRequestError:error)
                    self.transactionResult.status = TransactionStatus.error
                    self.transactionResult.message = error.localizedDescription
                    semaphore.signal()
                }
            }
        }
        
        semaphore.wait()
        return transactionResult
    }
}
