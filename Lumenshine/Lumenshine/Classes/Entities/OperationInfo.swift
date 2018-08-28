//
//  OperationInfo.swift
//  Lumenshine
//
//  Created by Soneso on 17/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

enum SignEnum {
    case plus
    case minus
}

class OperationInfo {
    var date: Date!
    var amount: String!
    var assetCode: String!
    var memo: String!
    var operationType: String!
    var operationID: String!
    var sign: SignEnum!
}
