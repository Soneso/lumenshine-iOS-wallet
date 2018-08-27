//
//  ChartCardViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 8/20/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

class ChartCardViewModel: CardViewModelType {
    weak var navigationCoordinator: CoordinatorType?
    
    fileprivate var card: Card?
    fileprivate let service: ChartsService
    private(set) var exchangeRates: ChartExchangeRatesResponse?
    fileprivate let periodValues: [Int32]
    private(set) var selectedPeriodIndex: Int
    
    var reloadClosure: ((ChartExchangeRatesResponse) -> ())?
    
    init(service: ChartsService) {
        self.service = service
        self.periodValues = [1,2,3,4,5,6,7]
        self.selectedPeriodIndex = 6
        periodSelected(at: 6)
    }
    
    var type: CardType {
        return .chart
    }
    
    var currentRate: String? {
        guard let exchange = exchangeRates else { return nil }
        let formatter = NumberFormatter()
//        formatter.usesGroupingSeparator = true
        formatter.minimumFractionDigits = 5
        formatter.maximumFractionDigits = 6
        let rate = formatter.string(from: NSDecimalNumber(decimal: exchange.currentRate)) ?? exchange.currentRate.description
        
        return "\(exchange.destinationCurrency) \(rate)"
    }
    
    var periodOptions: [String] {
        var opt = ["1 \(R.string.localizable.lbl_day())"]
        for i in 2...7 {
            opt.append("\(i) \(R.string.localizable.lbl_days())")
        }
        return opt
    }
    
    var imageURL: URL? {
        guard let urlString = card?.imgUrl else { return nil }
        guard let url = URL(string: urlString) else { return nil}
        return url
    }
    
    var linkURL: URL? {
        guard let urlString = card?.link else { return nil }
        guard let url = URL(string: urlString) else { return nil}
        return url
    }
    
    var title: String? {
        return R.string.localizable.chart_card_title()
    }
    
    var detail: String? {
        var updateStr = exchangeRates?.lastUpdateDate ?? ""
        // TODO: use lastUpdateDate when format is valid
        if let date = exchangeRates?.rates.first?.date,
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
        return [R.string.localizable.remove()]
    }
    
    func barButtonSelected(at index: Int) {
        switch type {
        case .web:
            guard let url = linkURL else { return }
            navigationCoordinator?.performTransition(transition: .showOnWeb(url))
        default:
            break
        }
    }
    
    func periodSelected(at index: Int) {
        selectedPeriodIndex = index
        
        service.getChartExchangeRates(assetCode: "MOBI", issuerPublicKey: "GA6HCMBLTZS5VYYBCATRBRZ3BZJMAFUDKYYF6AH6MVCMGWMRDNSWJPIH", destinationCurrency: "USD", timeRange: periodValues[selectedPeriodIndex]*24) { [weak self] result in
            switch result {
            case .success(let exchangeRates):
                self?.exchangeRates = exchangeRates
                if let reload = self?.reloadClosure {
                    reload(exchangeRates)
                }
            case .failure(_):
                print("Failed to get exchange rates")
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

