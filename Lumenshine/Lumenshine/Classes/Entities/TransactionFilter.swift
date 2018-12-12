//
//  TransactionFilter.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

struct TransactionFilter {
    
    struct Payment {
        var receivedRange: Range<Double>?
        var sentRange: Range<Double>?
        var currency: String?
        var include: Bool = false {
            didSet {
                receivedRange = nil
                sentRange = nil
                currency = nil
            }
        }
        
        init() {
            receivedRange = nil
            sentRange = nil
            currency = nil
        }
        
        mutating func clear() {
            receivedRange = nil
            sentRange = nil
            currency = nil
            include = false
        }
    }
    
    struct Offer {
        var sellingCurrency: String?
        var buyingCurrency: String?
        var include: Bool = false {
            didSet {
                sellingCurrency = nil
                buyingCurrency = nil
            }
        }
        
        init() {
            sellingCurrency = nil
            buyingCurrency = nil
        }
        
        mutating func clear() {
            sellingCurrency = nil
            buyingCurrency = nil
            include = false
        }
    }
    
    struct Other {
        var setOptions: Bool?
        var manageData: Bool?
        var trust: Bool?
        var accountMerge: Bool?
        var bumpSequence: Bool?
        var include: Bool = false {
            didSet {
                setOptions = nil
                manageData = nil
                trust = nil
                accountMerge = nil
                bumpSequence = nil
            }
        }
        
        init() {
            setOptions = nil
            manageData = nil
            trust = nil
            accountMerge = nil
            bumpSequence = nil
        }
        
        mutating func clear() {
            setOptions = nil
            manageData = nil
            trust = nil
            accountMerge = nil
            bumpSequence = nil
            include = false
        }
    }
    
    var walletIndex: Int
    var currencyIndex: Int
    var startDate: Date
    var endDate: Date
    var memo: String
    
    var payment: Payment
    var offer: Offer
    var other: Other
    
    init(startDate: Date, endDate: Date) {
        self.walletIndex = 0
        self.currencyIndex = 0
        self.startDate = startDate
        self.endDate = endDate
        self.memo = ""
        self.payment = Payment()
        self.offer = Offer()
        self.other = Other()
    }
    
    mutating func clear() {
        payment.clear()
        offer.clear()
        other.clear()
    }
}
