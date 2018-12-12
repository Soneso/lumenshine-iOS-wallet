//
//  TransactionInput.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import stellarsdk

enum TransactionActionType {
    case sendPayment
    case createAndFundAccount
}

public struct TransactionInput {
    let currency: String
    let issuer: String?
    let destinationPublicKey: String
    let destinationStellarAddress: String?
    let amount: String
    let memo: String?
    let memoType: MemoTypeValues?
    let masterKeyPair: KeyPair?
    let transactionType: TransactionActionType
    let signer: String?
    var signerSeed: String?
    let otherCurrencyAsset: AccountBalanceResponse?
}
