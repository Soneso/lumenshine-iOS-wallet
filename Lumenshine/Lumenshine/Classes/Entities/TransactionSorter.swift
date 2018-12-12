//
//  TransactionSorter.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation


struct TransactionSorter {
    var date: Bool?
    var type: Bool?
    var amount: Bool?
    var currency: Bool?
    
    init() {
        date = true
        type = nil
        amount = nil
        currency = nil
    }
    
    mutating func clear() {
        date = true
        type = nil
        amount = nil
        currency = nil
    }
}
