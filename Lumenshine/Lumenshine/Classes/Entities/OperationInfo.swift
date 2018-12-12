//
//  OperationInfo.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

enum SignEnum {
    case plus
    case minus
}

class OperationInfo: Equatable {
    static func == (lhs: OperationInfo, rhs: OperationInfo) -> Bool {
        return lhs.operationID == rhs.operationID
    }
    
    var date: Date!
    var amount: String!
    var assetCode: String!
    var memo: String!
    var operationType: String!
    var operationID: String!
    var sign: SignEnum!
    var responseData: Data?
}
