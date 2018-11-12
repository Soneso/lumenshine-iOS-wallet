//
//  ChartCardViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 8/20/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit.UIImage
import stellarsdk

class ChartCardViewModel: CardViewModelType {
    
    weak var navigationCoordinator: CoordinatorType?
    
    fileprivate var card: Card?
    fileprivate let service: ChartsService
    private(set) var exchangeRates: ChartExchangeRatesResponse?
    fileprivate let balance: AccountBalanceResponse?
    fileprivate let periodValues: [Int]
    fileprivate let periodLabels: [String]
    private(set) var selectedPeriodIndex: Int
    
    var reloadClosure: ((ChartExchangeRatesResponse) -> ())?
    
    init(service: ChartsService, balance: AccountBalanceResponse? = nil) {
        self.service = service
        self.balance = balance
        self.periodValues = [1, 12, 24, 3*24, 7*24, 2*365, 6*365, 12*365, 24*365]
        self.periodLabels = [
            "1 \(R.string.localizable.hour())",
            "12 \(R.string.localizable.hours())",
            "1 \(R.string.localizable.day())",
            "3 \(R.string.localizable.days())",
            "1 \(R.string.localizable.week())",
            "1 \(R.string.localizable.month())",
            "3 \(R.string.localizable.months())",
            "6 \(R.string.localizable.months())",
            "1 \(R.string.localizable.year())"
        ]
        if let selectedIndex = UserDefaults.standard.value(forKey: Keys.UserDefs.SelectedPeriod) as? Int {
            self.selectedPeriodIndex = selectedIndex
        } else {
            self.selectedPeriodIndex = 4
        }
        periodSelected(at: selectedPeriodIndex)
    }
    
    var type: CardType {
        return .chart
    }
    
    var currentRate: String? {
        guard let exchange = exchangeRates else { return nil }
        let formatter = NumberFormatter()
//        formatter.decimalSeparator = ","
        formatter.minimumFractionDigits = 5
        formatter.maximumFractionDigits = 6
        formatter.minimumIntegerDigits = 1
        let rate = formatter.string(from: NSDecimalNumber(decimal: exchange.currentRate)) ?? exchange.currentRate.description
        
        return "\(exchange.destinationCurrency) \(rate)"
    }
    
    var periodOptions: [String] {
        return periodLabels
    }
    
    var imageURL: URL? {
        guard let urlString = card?.imgUrl else { return nil }
        guard let url = URL(string: urlString) else { return nil}
        return url
    }
    
    var image: UIImage? {
        return nil
    }
    
    var linkURL: URL? {
        guard let urlString = card?.link else { return nil }
        guard let url = URL(string: urlString) else { return nil}
        return url
    }
    
    var title: String? {
        if let assetCode = balance?.assetCode {
            return R.string.localizable.chart_card_title2(assetCode)
        }
        return R.string.localizable.chart_card_title()
    }
    
    var detail: String? {
        var updateStr = exchangeRates?.lastUpdateDate ?? ""
        if let date = exchangeRates?.lastUpdateDate,
            let updated = DateUtils.format(date, in: .dateAndTime) {
            updateStr = R.string.localizable.updated(DateUtils.longString(from: updated))
        }
        return "\(periodOptions[selectedPeriodIndex]) - \(updateStr)"
    }
    
    var percentageChange: String? {
        if let oldRate = exchangeRates?.rates.last?.rate,
            let current = exchangeRates?.currentRate {
            let change = getPercentageChange(oldNumber: oldRate, newNumber: current)
            
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            var rate = formatter.string(from: NSDecimalNumber(decimal: change)) ?? "0.0"
            let prefix = change < 0 ? "↑" : "↓"
            if change < 0 { rate.removeFirst() }
            
            return "\(prefix) \(rate)%"
        }
        return nil
    }
    
    var bottomTitles: [String]? {
        return [R.string.localizable.refresh()]
    }
    
    func barButtonSelected(at index: Int) {
        periodSelected(at: selectedPeriodIndex)
    }
    
    func periodSelected(at index: Int) {
        selectedPeriodIndex = index
        UserDefaults.standard.setValue(index, forKey:Keys.UserDefs.SelectedPeriod)
        
        let assetCode = balance?.assetCode ?? "XLM"
        let currency = UserDefaults.standard.value(forKey: Keys.UserDefs.DestinationCurrency) as? String ?? "USD"
        
        service.getChartExchangeRates(assetCode: assetCode, issuerPublicKey: balance?.assetIssuer, destinationCurrency: currency, timeRange: Int32(periodValues[selectedPeriodIndex])) { [weak self] result in
            switch result {
            case .success(let exchangeRates):
                self?.exchangeRates = exchangeRates
                if let reload = self?.reloadClosure {
                    reload(exchangeRates)
                }
            case .failure(let error):
                print("Failed to get exchange rates: \(error)")
            }
        }
    }
}

fileprivate extension ChartCardViewModel {
    
    func getPercentageChange(oldNumber: Decimal, newNumber: Decimal) -> Decimal {
        let decreaseValue = oldNumber - newNumber
        return (decreaseValue / oldNumber) * 100
    }
}

