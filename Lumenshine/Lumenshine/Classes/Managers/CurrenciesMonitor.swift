//
//  CurrenciesMonitor.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class CurrenciesMonitor: NSObject {
    static var updateInterval: Double = 3*60
    
    private let chartService = Services.shared.chartsService
    
    var isMonitoring = false
    var currentRate: Double = 0
    var updateClosure: ((Double) -> ())?
    
    func startMonitoring() {
        isMonitoring = true
        update()
    }
    
    func stopMonitoring() {
        isMonitoring = false
    }
    
    private func update() {
    
        chartService.getChartExchangeRates(assetCode: "XLM", issuerPublicKey: nil, destinationCurrency: "USD", timeRange: 1) { (result) -> (Void) in
            switch result {
            case .success(let exchangeRates):
                if let currentRateResponse = exchangeRates.rates.first?.rate {
                    self.currentRate = Double(truncating: currentRateResponse as NSNumber)
                    print ("current rate: \(self.currentRate)")
                    self.updateClosure?(self.currentRate)
                }
            case .failure(let error):
                print("Failed to get exchange rates: \(error)")
            }
        }
        
        if self.isMonitoring {
            DispatchQueue.main.asyncAfter(deadline: .now() + CurrenciesMonitor.updateInterval) {
                self.update()
            }
        }
    }
    
}
