//
//  ChartsService.swift
//  Lumenshine
//
//  Created by Ionut Teslovan on 16/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public enum GetChartsCurrencyPairsEnum {
    case success(response: [ChartsCurrencyPairsResponse])
    case failure(error: ServiceError)
}

public enum GetChartCurrentRatesEnum {
    case success(response: ChartCurrentRatesResponse)
    case failure(error: ServiceError)
}

public enum GetChartExchangeRatesEnum {
    case success(response: ChartExchangeRatesResponse)
    case failure(error: ServiceError)
}

public typealias GetChartsCurrencyPairsClosure = ( _ response: GetChartsCurrencyPairsEnum) -> (Void)
public typealias GetChartCurrentRatesClosure = ( _ response: GetChartCurrentRatesEnum) -> (Void)
public typealias GetChartExchangeRatesClosure = ( _ response: GetChartExchangeRatesEnum) -> (Void)

public class ChartsService: BaseService {
    override init(baseURL: String) {
        super.init(baseURL: baseURL)
    }
    
    open func getChartsCurrencyPairs(response: @escaping GetChartsCurrencyPairsClosure) {
        GETRequestWithPath(path: "/portal/chart/chart_currency_pairs") { (result) -> (Void) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    do {
                        let chartsCurrencyPairs = try self.jsonDecoder.decode(Array<ChartsCurrencyPairsResponse>.self, from: data)
                        response(.success(response: chartsCurrencyPairs))
                    } catch {
                        response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                    }
                case .failure(let error):
                    response(.failure(error: error))
                }
            }
        }
    }
    
    open func getChartCurrentRates(currencyIssuerPairs: Dictionary<String, String>, to: String, response: @escaping GetChartCurrentRatesClosure) {
        var params = Dictionary<String, Any>()
        params["destination_currency"] = to
        
        var currenciesArray = Array<Dictionary<String, String>>()
        for keyValuePair in currencyIssuerPairs {
            currenciesArray.append(["asset_code": keyValuePair.key, "issuer_public_key": keyValuePair.value])
        }
        
        params["source_currencies"] = currenciesArray
        
        if let bodyData = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) {
            POSTRequestWithPath(path: "/portal/chart/chart_current_rates", body: bodyData) { (result) -> (Void) in
                switch result {
                case .success(data: let data):
                    do {
                        let chartCurrentRates = try self.jsonDecoder.decode(ChartCurrentRatesResponse.self, from: data)
                        response(.success(response: chartCurrentRates))
                    } catch {
                        response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                    }
                case .failure(error: let error):
                    response(.failure(error: error))
                }
            }
        } else {
            print("Invalid parameters")
        }
    }
    
    open func getChartExchangeRates(assetCode: String, issuerPublicKey: String?, destinationCurrency: String, timeRange: Int32, response: @escaping GetChartExchangeRatesClosure) {
        var params = Dictionary<String, Any>()
        params["source_currency"] = ["asset_code": assetCode, "issuer_public_key": issuerPublicKey]
        params["destination_currency"] = destinationCurrency
        params["range_hours"] = timeRange
        
        if let bodyData = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) {
            POSTRequestWithPath(path: "/portal/chart/chart_exchange_rates", body: bodyData) { (result) -> (Void) in
                switch result {
                case .success(data: let data):
                    do {
                        let chartExchangeRates = try self.jsonDecoder.decode(ChartExchangeRatesResponse.self, from: data)
                        response(.success(response: chartExchangeRates))
                    } catch {
                        response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                    }
                case .failure(error: let error):
                    response(.failure(error: error))
                }
            }
        } else {
            print("Invalid parameters")
        }
    }
}
