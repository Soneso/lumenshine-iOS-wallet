//
//  TransactionSorter.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 01/12/2018.
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
