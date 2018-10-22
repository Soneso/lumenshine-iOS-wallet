//
//  TransactionInput.swift
//  Lumenshine
//
//  Created by Soneso on 07/08/2018.
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
    let address: String
    let amount: String
    let memo: String?
    let memoType: MemoTypeValues?
    let masterKeyPair: KeyPair?
    let transactionType: TransactionActionType
    let signer: String?
    let signerSeed: String?
    let otherCurrencyAsset: AccountBalanceResponse?
}
