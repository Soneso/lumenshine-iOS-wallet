//
//  SendTransaction.swift
//  Lumenshine
//
//  Created by Soneso on 09/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import stellarsdk

enum TrustLineStatus {
    case success
    case failure(error: HorizonRequestError)
}

typealias TransactionResultClosure = () -> (Void)
typealias TrustLineClosure = (_ completion: TrustLineStatus) -> (Void)

class TransactionHelper {
    private let TransactionDefaultLimit: Decimal = 10000
    private var inputData: TransactionInput!
    private var wallet: FoundedWallet!
    private var transactionResult: TransactionResult!
    
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
    
    init(wallet: FoundedWallet) {
        self.wallet = wallet
    }
    
    func createAndFundAccount(completion: @escaping (TransactionResult) -> ()) {
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
        
        if let sourceKeyPair = PrivateKeyManager.getKeyPair(forAccountID: wallet.publicKey),
            let destinationKeyPair = destinationAccountKeyPair,
            let amount = CoinUnit(self.inputData.amount) {
            
            createAndFundAccount(sourceKeyPair: sourceKeyPair, destinationKeyPair: destinationKeyPair, amount: Decimal(amount), memo: memo) { () -> (Void) in
                completion(self.transactionResult)
            }
        }
    }
    
    func sendPayment(completion: @escaping (TransactionResult) -> ()) {
        let destinationAccountKeyPair = try? KeyPair(accountId: inputData.address)
        
        var assetIssuerKeyPair: KeyPair? = nil
        var assetTypeIntValue: Int32 = -1
        var selectedAsset: Asset? = Asset(type: AssetType.ASSET_TYPE_NATIVE)
        
        if let selectedCurrency = getSelectedCurrency(), let assetIssuer = selectedCurrency.assetIssuer {
            assetIssuerKeyPair = try? KeyPair(accountId: assetIssuer)
            assetTypeIntValue = getAssettypeIntValue(assetType: selectedCurrency.assetType)
            selectedAsset = Asset.init(type: assetTypeIntValue, code: selectedCurrency.assetCode, issuer: assetIssuerKeyPair)
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
        
        if let asset = selectedAsset, let destinationKeyPair = destinationAccountKeyPair,
            let sourceKeyPair = PrivateKeyManager.getKeyPair(forAccountID: wallet.publicKey), let amount = CoinUnit(self.inputData.amount) {
            sendPayment(sourceKeyPair: sourceKeyPair, destinationKeyPair: destinationKeyPair, asset: asset, amount: Decimal(amount), memo: memo) { () -> (Void) in
                completion(self.transactionResult)
            }
        }
    }
    
    func removeTrustLine(currency: AccountBalanceResponse, userMnemonic: String, discardingDestination: String? = nil, completion: @escaping TrustLineClosure) {
        if let assetIssuer = currency.assetIssuer {
            let issuingAccountKeyPair = try? KeyPair(accountId: assetIssuer)
            
            var assetType: Int32? = nil
            
            switch currency.assetType {
            case AssetTypeAsString.NATIVE:
                assetType = AssetType.ASSET_TYPE_NATIVE
                break
            case AssetTypeAsString.CREDIT_ALPHANUM4:
                assetType = AssetType.ASSET_TYPE_CREDIT_ALPHANUM4
                break
            case AssetTypeAsString.CREDIT_ALPHANUM12:
                assetType = AssetType.ASSET_TYPE_CREDIT_ALPHANUM12
                break
            default:
                break
            }
            
            if let assetType = assetType, let asset = Asset(type: assetType, code: currency.assetCode, issuer: issuingAccountKeyPair),
                let trustingAccountKeyPair = PrivateKeyManager.getKeyPair(forAccountID: wallet.publicKey) {
                removeTrustLine(trustingAccountKeyPair: trustingAccountKeyPair, issuingAccountKeyPair: issuingAccountKeyPair, currency: currency, asset: asset) { (status) -> (Void) in
                    DispatchQueue.main.async {
                        completion(status)
                    }
                }
            }
        }
    }
    
    func addTrustLine(asset: Asset, userMnemonic: String, completion: @escaping TrustLineClosure) {
        if let trustingAccountKeyPair = PrivateKeyManager.getKeyPair(forAccountID: wallet.publicKey) {
            addTrustLine(trustingAccountKeyPair: trustingAccountKeyPair, asset: asset, userMnemonic: userMnemonic) { (result) -> (Void) in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
    
    private func getSelectedCurrency() -> AccountBalanceResponse? {
        return wallet.balances.first(where: { (asset) -> Bool in
            if inputData.currency == NativeCurrencyNames.xlm.rawValue {
                return asset.assetCode == nil
            }
            
            if inputData.issuer?.isEmpty == false {
                return asset.assetCode == inputData.currency && asset.assetIssuer == inputData.issuer
            }
            
            return asset.assetCode == inputData.currency
        })
    }
    
    private func submitTransactionSucceeded(transaction: Transaction, completion: @escaping (() -> (Void))) {
        print("Account successfully created.")
        self.transactionResult.status = TransactionStatus.success
        self.transactionResult.transactionFee = String(transaction.fee)
        
        if let transactionHash = try? transaction.getTransactionHash(network: Network.testnet) {
            self.stellarSdk.payments.getPayments(forTransaction: transactionHash, response: { (response) -> (Void) in
                switch response {
                case .success(details: let details):
                    self.transactionResult.operationID = details.records.first?.id
                case .failure(error: let error):
                    self.transactionResult.status = TransactionStatus.error
                    self.transactionResult.message = error.localizedDescription
                }
                
                completion()
            })
        }
    }
    
    private func submitCreateAndFundAccount(destinationKeyPair: KeyPair, sourceKeyPair: KeyPair,accountResponse: AccountResponse, amount: Decimal, memo: Memo, completion: @escaping (() -> (Void))) {
        do {
            let createAccount = CreateAccountOperation(destination: destinationKeyPair, startBalance: amount)
            let transaction = try Transaction(sourceAccount: accountResponse,
                                              operations: [createAccount],
                                              memo: memo,
                                              timeBounds: nil)
            
            try transaction.sign(keyPair: sourceKeyPair, network: Network.testnet)
            
            try self.stellarSdk.transactions.submitTransaction(transaction: transaction) { (response) -> (Void) in
                switch response {
                case .success(_):
                    self.submitTransactionSucceeded(transaction: transaction, completion: { () -> (Void) in
                        completion()
                    })
                    
                case .failure(let error):
                    StellarSDKLog.printHorizonRequestErrorMessage(tag:"Create account", horizonRequestError: error)
                    self.transactionResult.status = TransactionStatus.error
                    self.transactionResult.message = error.localizedDescription
                    self.transactionResult.transactionFee = transaction.fee > 0 ? String(transaction.fee) : nil
                    completion()
                }
            }
        } catch {
            completion()
        }
    }
    
    private func createAndFundAccount(sourceKeyPair: KeyPair, destinationKeyPair: KeyPair, amount: Decimal, memo: Memo, completion: @escaping TransactionResultClosure ) {
        stellarSdk.accounts.getAccountDetails(accountId: sourceKeyPair.accountId) { (response) -> (Void) in
            switch response {
            case .success(let accountResponse):
              self.submitCreateAndFundAccount(destinationKeyPair: destinationKeyPair,
                                              sourceKeyPair: sourceKeyPair,
                                              accountResponse: accountResponse,
                                              amount: amount,
                                              memo: memo,
                                              completion: { () -> (Void) in
                DispatchQueue.main.async {
                    completion()
                }
              })
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"Error:", horizonRequestError: error)
                self.transactionResult.status = TransactionStatus.error
                self.transactionResult.message = error.localizedDescription
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
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
    
    private func submidPaymentSucceeded(transaction: Transaction, completion: @escaping (() -> (Void))) {
        print("Success")
        self.transactionResult.status = TransactionStatus.success
        self.transactionResult.transactionFee = String(transaction.fee)
        
        self.stellarSdk.payments.getPayments(forTransaction: try! transaction.getTransactionHash(network: Network.testnet), response: { (response) -> (Void) in
            switch response {
            case .success(details: let details):
                self.transactionResult.operationID = details.records.first?.id
                completion()
                
            case .failure(error: let error):
                self.transactionResult.status = TransactionStatus.error
                self.transactionResult.message = error.localizedDescription
                completion()
            }
        })
    }
    
    private func submitPaymentTransaction(destinationKeyPair: KeyPair, sourceKeyPair: KeyPair, accountResponse: AccountResponse, asset: Asset, amount: Decimal, memo: Memo,
                                          completion: @escaping (() -> (Void))) {
        do {
            let paymentOperation = PaymentOperation(destination: destinationKeyPair, asset: asset, amount: amount)
            let transaction = try Transaction(sourceAccount: accountResponse, operations: [paymentOperation], memo: memo, timeBounds: nil)
            
            try transaction.sign(keyPair: sourceKeyPair, network: Network.testnet)
            
            try self.stellarSdk.transactions.submitTransaction(transaction: transaction) { (response) -> (Void) in
                switch response {
                case .success(_):
                    self.submidPaymentSucceeded(transaction: transaction, completion: { () -> (Void) in
                        completion()
                    })
                    
                case .failure(let error):
                    StellarSDKLog.printHorizonRequestErrorMessage(tag:"SRP Test", horizonRequestError:error)
                    self.transactionResult.status = TransactionStatus.error
                    self.transactionResult.message = error.localizedDescription
                    self.transactionResult.transactionFee = transaction.fee > 0 ? String(transaction.fee) : nil
                    completion()
                }
            }
        } catch {
            completion()
        }
    }
    
    private func sendPayment(sourceKeyPair: KeyPair, destinationKeyPair: KeyPair, asset: Asset, amount: Decimal, memo: Memo, completion: @escaping TransactionResultClosure) {
        stellarSdk.accounts.getAccountDetails(accountId: sourceKeyPair.accountId) { (response) -> (Void) in
            switch response {
            case .success(let accountResponse):
                self.submitPaymentTransaction(destinationKeyPair: destinationKeyPair, sourceKeyPair: sourceKeyPair, accountResponse: accountResponse,
                                              asset: asset, amount: amount, memo: memo, completion: { () -> (Void) in
                    DispatchQueue.main.async {
                        completion()
                    }
                })
                
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"SRP Test", horizonRequestError:error)
                self.transactionResult.status = TransactionStatus.error
                self.transactionResult.message = error.localizedDescription
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    private func submitAddTrustLine(trustingAccountKeyPair: KeyPair, accountResponse: AccountResponse, asset: Asset, completion: @escaping TrustLineClosure) {
        do {
            let changeTrustOp = ChangeTrustOperation(asset: asset, limit: self.TransactionDefaultLimit)
            let transaction = try Transaction(sourceAccount: accountResponse,
                                              operations: [changeTrustOp],
                                              memo: Memo.none,
                                              timeBounds: nil)
            
            try transaction.sign(keyPair: trustingAccountKeyPair, network: Network.testnet)
            
            try self.stellarSdk.transactions.submitTransaction(transaction: transaction) { (response) -> (Void) in
                switch response {
                case .success(_):
                    print("Success")
                    completion(.success)
                case .failure(let error):
                    StellarSDKLog.printHorizonRequestErrorMessage(tag:"Trust error", horizonRequestError:error)
                    completion(.failure(error: error))
                }
            }
        } catch {
        }
    }
    
    private func addTrustLine(trustingAccountKeyPair: KeyPair, asset: Asset, userMnemonic: String, completion: @escaping TrustLineClosure) {
        stellarSdk.accounts.getAccountDetails(accountId: trustingAccountKeyPair.accountId) { (response) -> (Void) in
            switch response {
            case .success(let accountResponse):
                self.submitAddTrustLine(trustingAccountKeyPair: trustingAccountKeyPair, accountResponse: accountResponse, asset: asset, completion: { (response) -> (Void) in
                    DispatchQueue.main.async {
                        completion(response)
                    }
                })
            case .failure(let error):
                print("Error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error: error))
                }
            }
        }
    }
    
    private func submitRemoveTrustLine(issuingAccountKeyPair: KeyPair?, trustingAccountKeyPair: KeyPair, accountResponse: AccountResponse, currency: AccountBalanceResponse, asset: Asset, discardingDestination: String? = nil, completion: @escaping TrustLineClosure) {
        do {
            var destination = issuingAccountKeyPair
            if let discardingDestination = discardingDestination {
                destination = try? KeyPair(accountId: discardingDestination)
            }
            
            if let destination = destination, let balance = CoinUnit(currency.balance) {
                var operationsArray: [stellarsdk.Operation] = []
                
                if balance > 0.0 {
                    operationsArray.append(PaymentOperation(destination: destination, asset: asset, amount: Decimal(balance)))
                }
                
                let changeTrustOp = ChangeTrustOperation(asset:asset, limit: 0)
                operationsArray.append(changeTrustOp)
                
                let transaction = try Transaction(sourceAccount: accountResponse,
                                                  operations: operationsArray,
                                                  memo: Memo.none,
                                                  timeBounds:nil)
                
                try transaction.sign(keyPair: trustingAccountKeyPair, network: Network.testnet)
                
                try self.stellarSdk.transactions.submitTransaction(transaction: transaction) { (response) -> (Void) in
                    switch response {
                    case .success(_):
                        print("Success")
                        DispatchQueue.main.async {
                            completion(.success)
                        }
                    case .failure(let error):
                        StellarSDKLog.printHorizonRequestErrorMessage(tag:"Trust error", horizonRequestError:error)
                        DispatchQueue.main.async {
                            completion(.failure(error: error))
                        }
                    }
                }
            }
        } catch {
        }
    }
    
    private func removeTrustLine(trustingAccountKeyPair: KeyPair, issuingAccountKeyPair: KeyPair?, discardingDestination: String? = nil,
                                 currency: AccountBalanceResponse, asset: Asset, completion: @escaping TrustLineClosure) {
        stellarSdk.accounts.getAccountDetails(accountId: trustingAccountKeyPair.accountId) { (response) -> (Void) in
            switch response {
            case .success(let accountResponse):
                self.submitRemoveTrustLine(issuingAccountKeyPair: issuingAccountKeyPair, trustingAccountKeyPair: trustingAccountKeyPair, accountResponse: accountResponse,
                                           currency: currency, asset: asset, completion: { (response) -> (Void) in
                    DispatchQueue.main.async {
                        completion(response)
                    }
                })
                
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"Get account error", horizonRequestError:error)
                DispatchQueue.main.async {
                    completion(.failure(error: error))
                }
            }
        }
    }
}
