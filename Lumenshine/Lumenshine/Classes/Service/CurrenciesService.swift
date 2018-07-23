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

public typealias GetRateClosure = (_ response:GetRateEnum) -> (Void)

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
    
}
