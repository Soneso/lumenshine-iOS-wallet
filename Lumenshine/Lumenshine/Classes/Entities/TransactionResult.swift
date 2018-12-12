//
//  TransactionResult.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

enum TransactionStatus: String {
    case success = "success"
    case error = "error"
}

protocol OperationIDValueChangedDelegate {
    func operationIDChanged(newValue: String?)
}

public class TransactionResult {
    var operationIDChangedDelegate: OperationIDValueChangedDelegate?
    var status: TransactionStatus = TransactionStatus.error
    var message: String? = nil
    var currency: String = ""
    var issuer: String? = nil
    var amount: String = ""
    var recipentMail: String = ""
    var recipentPK: String = ""
    var memo: String? = nil
    var memoType: MemoTypeValues = MemoTypeValues.MEMO_TEXT
    var transactionFee: String? = nil
    var operationID: String? = nil {
        didSet {
            operationIDChangedDelegate?.operationIDChanged(newValue: operationID)
        }
    }
}
