//
//  SendTransaction.swift
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

enum TrustLineStatus {
    case success
    case failure(error: HorizonRequestError?)
}

typealias TransactionResultClosure = () -> (Void)
typealias TrustLineClosure = (_ completion: TrustLineStatus) -> (Void)

enum SignerErorr: Error {
    case signerMismatch
}

class TransactionHelper {
    private let transactionFee = String(format: "%.5f", CoinUnit.Constants.transactionFee)
    private var inputData: TransactionInput!
    private var wallet: FundedWallet!
    private var transactionResult: TransactionResult!
    private var externalSigner: String?
    private var externalSignerSeed: String?
    private var transactionStream: OperationsStreamItem!
    
    private var stellarSdk: StellarSDK {
        get {
            return Services.shared.stellarSdk
        }
    }
    
    init(transactionInputData: TransactionInput, wallet: FundedWallet) {
        inputData = transactionInputData
        self.wallet = wallet
        
        transactionResult = TransactionResult()
        transactionResult.amount = inputData.amount
        transactionResult.currency = inputData.currency
        transactionResult.issuer = inputData.issuer
    }
    
    init(wallet: FundedWallet, signer: String? = nil, signerSeed: String? = nil) {
        self.wallet = wallet
        self.externalSigner = signer
        self.externalSignerSeed = signerSeed
    }
    
    func createAndFundAccount(completion: @escaping (TransactionResult) -> ()) {
        let destinationAccountKeyPair = try? KeyPair(accountId: inputData.destinationPublicKey)
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
            transactionResult.recipentMail = inputData.destinationPublicKey != accountID ? accountID : ""
        }
        
        var sourceKeyPair = try! KeyPair(publicKey: PublicKey(accountId:wallet.publicKey), privateKey:nil)
        
        if let masterKeyPair = inputData.masterKeyPair {
            sourceKeyPair = masterKeyPair
        }
        
        if let destinationKeyPair = destinationAccountKeyPair,
            let amount = CoinUnit(self.inputData.amount) {
            
            self.createAndFundAccount(sourceKeyPair: sourceKeyPair, destinationKeyPair: destinationKeyPair, amount: Decimal(amount), memo: memo) { () -> (Void) in
                completion(self.transactionResult)
            }
        }
    }
    
    func sendPayment(completion: @escaping (TransactionResult) -> ()) {
        let destinationAccountKeyPair = try? KeyPair(accountId: inputData.destinationPublicKey)
        
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
            transactionResult.recipentMail = inputData.destinationPublicKey != accountID ? accountID : ""
        }
        
        var sourceKeyPair = try! KeyPair(publicKey: PublicKey(accountId:wallet.publicKey), privateKey:nil)

        if let masterKeyPair = inputData.masterKeyPair {
            sourceKeyPair = masterKeyPair
        }
        
        if let asset = selectedAsset,
            let destinationKeyPair = destinationAccountKeyPair,
            let amount = CoinUnit(self.inputData.amount) {
                        
            self.sendPayment(sourceKeyPair: sourceKeyPair, destinationKeyPair: destinationKeyPair, asset: asset, amount: Decimal(amount), memo: memo) { () -> (Void) in
                completion(self.transactionResult)
            }
        }
    }
    
    func removeTrustLine(currency: AccountBalanceResponse, discardingDestination: String? = nil, trustingAccountKeyPair: KeyPair, completion: @escaping TrustLineClosure) {
        if let assetIssuer = currency.assetIssuer {
            let issuingAccountKeyPair = try! KeyPair(accountId: assetIssuer)
            
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
            
            if let assetType = assetType,
                let asset = Asset(type: assetType, code: currency.assetCode, issuer: issuingAccountKeyPair) {
                self.removeTrustLine(trustingAccountKeyPair: trustingAccountKeyPair, issuingAccountKeyPair: issuingAccountKeyPair, currency: currency, asset: asset) { (status) -> (Void) in
                    DispatchQueue.main.async {
                        completion(status)
                    }
                }
            }
        } else{
            completion(.failure(error: nil))
        }
    }
    
    private func getSelectedCurrency() -> AccountBalanceResponse? {
        return inputData.otherCurrencyAsset ?? wallet.balances.first(where: { (asset) -> Bool in
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
        
        self.transactionResult.status = TransactionStatus.success
        self.transactionResult.transactionFee = transactionFee

        var network = Network.testnet
        if (Services.shared.usePublicStellarNetwork) {
            network = Network.public
        }
        if let transactionHash = try? transaction.getTransactionHash(network: network) {
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
            
            try signTransaction(transaction: transaction, sourceKeyPair: sourceKeyPair)
            
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
                    self.transactionResult.transactionFee = transaction.fee > 0 ? self.transactionFee : nil
                    completion()
                }
            }
        } catch {
            completion()
        }
    }
    
    private func createAndFundAccount(sourceKeyPair: KeyPair, destinationKeyPair: KeyPair, amount: Decimal, memo: Memo, completion: @escaping TransactionResultClosure ) {
        Services.shared.walletService.getAccountDetails(accountId: sourceKeyPair.accountId) { (response) -> (Void) in
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
    
    private func openStreamToGetOperationID(forTransaction transaction: Transaction) {
        var network = Network.testnet
        if (Services.shared.usePublicStellarNetwork) {
            network = Network.public
        }
        
        if let transactionHash = try? transaction.getTransactionHash(network: network) {
            transactionStream = self.stellarSdk.payments.stream(for: PaymentsChange.paymentsForTransaction(transaction: transactionHash, cursor: nil))
            transactionStream.onReceive { (response) -> (Void) in
                switch response {
                case .response(id: let id, data: _):
                    self.transactionResult.operationID = id
                    self.closeStreamToGetOperationID()
                case .error(error: _):
                    break
                case .open:
                    break
                }
            }
        }
    }
    
    private func closeStreamToGetOperationID() {
        self.transactionStream?.closeStream()
        self.transactionStream = nil
    }
    
    private func submitPaymentTransaction(destinationKeyPair: KeyPair, sourceKeyPair: KeyPair, accountResponse: AccountResponse, asset: Asset, amount: Decimal, memo: Memo,
                                          completion: @escaping (() -> (Void))) {
        do {
            let paymentOperation = PaymentOperation(destination: destinationKeyPair, asset: asset, amount: amount)
            let transaction = try Transaction(sourceAccount: accountResponse, operations: [paymentOperation], memo: memo, timeBounds: nil)
            
            try signTransaction(transaction: transaction, sourceKeyPair: sourceKeyPair)
            openStreamToGetOperationID(forTransaction: transaction)
            
            try self.stellarSdk.transactions.submitTransaction(transaction: transaction) { (response) -> (Void) in
                switch response {
                case .success(details:_):
                    self.transactionResult.status = TransactionStatus.success
                    self.transactionResult.transactionFee = self.transactionFee
                    completion()
                    
                case .failure(let error):
                    StellarSDKLog.printHorizonRequestErrorMessage(tag:"SRP Test", horizonRequestError:error)
                    self.transactionResult.status = TransactionStatus.error
                    self.transactionResult.message = error.localizedDescription
                    self.transactionResult.transactionFee = transaction.fee > 0 ? self.transactionFee : nil
                    self.closeStreamToGetOperationID()
                    completion()
                }
            }
        } catch {
            self.closeStreamToGetOperationID()
            completion()
        }
    }
    
    private func signTransaction(transaction: Transaction, sourceKeyPair: KeyPair) throws{
        var network = Network.testnet
        if (Services.shared.usePublicStellarNetwork) {
            network = Network.public
        }
        
        if let signer = inputData?.signer ?? externalSigner, let signerSeed = inputData?.signerSeed ?? externalSignerSeed {
            let signerKeyPair = try KeyPair.init(secretSeed: signerSeed)
            
            if signerKeyPair.accountId != signer {
                throw SignerErorr.signerMismatch
            }
            
            try transaction.sign(keyPair: signerKeyPair, network: network)
            inputData?.signerSeed = nil
            externalSignerSeed = nil
        } else {
            try transaction.sign(keyPair: sourceKeyPair, network: network)
        }
    }
    
    private func sendPayment(sourceKeyPair: KeyPair, destinationKeyPair: KeyPair, asset: Asset, amount: Decimal, memo: Memo, completion: @escaping TransactionResultClosure) {
        Services.shared.walletService.getAccountDetails(accountId: sourceKeyPair.accountId) { (response) -> (Void) in
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
    
    private func submitAddTrustLine(trustingAccountKeyPair: KeyPair, accountResponse: AccountResponse, asset: Asset, limit:Decimal?, completion: @escaping TrustLineClosure) {
        do {
            let changeTrustOp = ChangeTrustOperation(asset: asset, limit: limit)
            let transaction = try Transaction(sourceAccount: accountResponse,
                                              operations: [changeTrustOp],
                                              memo: Memo.none,
                                              timeBounds: nil)
            try signTransaction(transaction: transaction, sourceKeyPair: trustingAccountKeyPair)
            
            try self.stellarSdk.transactions.submitTransaction(transaction: transaction) { (response) -> (Void) in
                switch response {
                case .success(_):
                    completion(.success)
                case .failure(let error):
                    StellarSDKLog.printHorizonRequestErrorMessage(tag:"Trust error", horizonRequestError:error)
                    completion(.failure(error: error))
                }
            }
        } catch {
            completion(.failure(error: nil))
        }
    }
    
    func addTrustLine(trustingAccountKeyPair: KeyPair, asset: Asset, limit:Decimal?, completion: @escaping TrustLineClosure) {
        Services.shared.walletService.getAccountDetails(accountId: trustingAccountKeyPair.accountId) { (response) -> (Void) in
            switch response {
            case .success(let accountResponse):
                self.submitAddTrustLine(trustingAccountKeyPair: trustingAccountKeyPair, accountResponse: accountResponse, asset: asset, limit:limit, completion: { (response) -> (Void) in
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
    
    private func submitRemoveTrustLine(issuingAccountKeyPair: KeyPair, trustingAccountKeyPair: KeyPair, accountResponse: AccountResponse, currency: AccountBalanceResponse, asset: Asset, discardingDestination: String? = nil, completion: @escaping TrustLineClosure) {
        do {
            var destination = issuingAccountKeyPair
            if let discardingDestination = discardingDestination {
                destination = try! KeyPair(accountId: discardingDestination)
            }
            
            if let balance = CoinUnit(currency.balance) {
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
                
                try signTransaction(transaction: transaction, sourceKeyPair: trustingAccountKeyPair)
                
                try self.stellarSdk.transactions.submitTransaction(transaction: transaction) { (response) -> (Void) in
                    switch response {
                    case .success(_):
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
            completion(.failure(error: nil))
        }
    }
    
    private func removeTrustLine(trustingAccountKeyPair: KeyPair, issuingAccountKeyPair: KeyPair, discardingDestination: String? = nil,
                                 currency: AccountBalanceResponse, asset: Asset, completion: @escaping TrustLineClosure) {
        Services.shared.walletService.getAccountDetails(accountId: trustingAccountKeyPair.accountId) { (response) -> (Void) in
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
