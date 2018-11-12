//
//  CurrenciesService.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 15/07/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

public enum Currency {
    case xlm
    case usd
    
    var assetCode: String {
        get {
            switch self {
            case .xlm:
                return "XLM"
            case .usd:
                return "USD"
            }
        }
    }
    
}

public enum GetRateEnum {
    case success(response: Double)
    case failure(error: ServiceError)
}

public enum GetKnownCurrencyEnum {
    case success(response: KnownCurrencyResponse)
    case failure(error: ServiceError)
}

public enum GetKnownCurrenciesEnum {
    case success(response: [KnownCurrencyResponse])
    case failure(error: ServiceError)
}

public enum GetKnownInflationDestinationsEnum {
    case success(response: [KnownInflationDestinationResponse])
    case failure(error: ServiceError)
}

public typealias GetRateClosure = (_ response:GetRateEnum) -> (Void)
public typealias GetKnownCurrencyClosure = (_ response: GetKnownCurrencyEnum) -> (Void)
public typealias GetKnownCurrenciesClosure = (_ response: GetKnownCurrenciesEnum) -> (Void)
public typealias GetKnownInflationDestinationsClosure = (_ response: GetKnownInflationDestinationsEnum) -> (Void)

public class CurrenciesService: BaseService {

    override init(baseURL: String) {
        super.init(baseURL: baseURL)
    }
    
    open func getRate(from:Currency, to:Currency, response: @escaping GetRateClosure) {
        var params = Dictionary<String,Any>()
        params["destination_currency"] = to.assetCode
        params["source_currencies"] = [["asset_code": from.assetCode, "issuer_public_key": ""]]
        
        //let bodyData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        
        response(.success(response: 0.34))
        
//        POSTRequestWithPath(path: "/portal/chart/chart_current_data", body: bodyData) { (result) -> (Void) in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let data):
//                    do {
//                        //let countryListResponse = try self.jsonDecoder.decode(Array<WalletsResponse>.self, from: data)
//                        //response(.success(response: countryListResponse))
//                    } catch {
//                        //response(.failure(error: .parsingFailed(message: error.localizedDescription)))
//                    }
//                    print("ble")
//                case .failure(let error):
//                   // response(.failure(error: error))
//                    print("ble")
//                }
//            }
//        }
    }
    
    open func getKnownInflationDestinations(response: @escaping GetKnownInflationDestinationsClosure) {
        POSTRequestWithPath(path: "/portal/user/dashboard/get_known_inflation_destinations") { (result) -> (Void) in
            switch result {
            case .success(let data):
                do {
                    let knownInflationDestinations = try self.jsonDecoder.decode(Array<KnownInflationDestinationResponse>.self, from: data)
                    response(.success(response: knownInflationDestinations))
                } catch {
                    response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                }
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    open func getKnownInflationDestination(forID ID: Int, response: @escaping GetKnownInflationDestinationClosure) {
        var params = Dictionary<String,Any>()
        params["id"] = ID
        
        POSTRequestWithPath(path: "/portal/user/dashboard/get_known_inflation_destination", parameters: params) { (result) -> (Void) in
            switch result {
            case .success(let data):
                do {
                    let knownInflationDestination = try self.jsonDecoder.decode(KnownInflationDestinationResponse.self, from: data)
                    response(.success(response: knownInflationDestination))
                } catch {
                    response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                }
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    open func getKnownCurrencies(response: @escaping GetKnownCurrenciesClosure) {
        POSTRequestWithPath(path: "/portal/user/dashboard/get_known_currencies") { (result) -> (Void) in
            switch result {
            case .success(data: let data):
                do {
                    let knownCurrenciesResponse = try self.jsonDecoder.decode(Array<KnownCurrencyResponse>.self, from: data)
                    response(.success(response: knownCurrenciesResponse))
                } catch {
                    response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                }
            case .failure(error: let error):
                response(.failure(error: error))
            }
        }
    }
    
    open func getKnownCurrency(forID ID: Int, response: @escaping GetKnownCurrencyClosure) {
        var params = Dictionary<String,Any>()
        params["id"] = ID
        
        POSTRequestWithPath(path: "/portal/user/dashboard/get_known_currency", parameters: params) { (result) -> (Void) in
            switch result {
            case .success(let data):
                do {
                    let knownCurrencyResponse = try self.jsonDecoder.decode(KnownCurrencyResponse.self, from: data)
                    response(.success(response: knownCurrencyResponse))
                } catch {
                    response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                }
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
}
