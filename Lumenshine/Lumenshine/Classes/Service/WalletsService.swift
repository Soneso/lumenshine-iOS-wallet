//
//  WalletsService.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import stellarsdk

public enum GetWalletsEnum {
    case success(response: [WalletsResponse])
    case failure(error: ServiceError)
}

public enum ChangeWalletDataEnum {
    case success
    case failure(error: ServiceError)
}

public enum AddWalletEnum {
    case success
    case failure(error: ServiceError)
}

public enum SetWalletHomescreenEnum {
    case success
    case failure(error: ServiceError)
}

public typealias GetWalletsClosure = (_ response: GetWalletsEnum) -> (Void)
public typealias ChangeWalletDataClosure = (_ response: ChangeWalletDataEnum) -> (Void)
public typealias AddWalletClosure = (_ response: AddWalletEnum) -> (Void)
public typealias SetWalletHomescreenClosure = (_ response: SetWalletHomescreenEnum) -> (Void)

public class WalletsService: BaseService {
    
    private var walletsToRefresh = [String]()
    private var accountDetailsCache = NSCache<NSString, AnyObject>()
    private var accountDetailsCachingDuration = 5.0 //sec.
    typealias cacheEntry = (Date, AccountResponse)
    
    private class AcDetailsCacheEntry {
        let date:Date
        let accountResponse:AccountResponse
        
        init(date:Date, accountResponse:AccountResponse) {
            self.date = date
            self.accountResponse = accountResponse
        }
    }
    
    var stellarSDK: StellarSDK {
        get {
            return Services.shared.stellarSdk
        }
    }
    
    override init(baseURL: String) {
        super.init(baseURL: baseURL)
    }
    
    open func addWalletToRefresh(accountId: String) {
        if !walletsToRefresh.contains(accountId) {
            self.walletsToRefresh.append(accountId)
        }
    }
    
    open func isWalletNeedsRefresh(accountId: String) -> Bool {
        return self.walletsToRefresh.contains(accountId)
    }
    
    open func removeFromWalletsToRefresh(accountId: String) {
        self.walletsToRefresh.removeAll { $0 == accountId }
    }
    
    open func getWallets(response: @escaping GetWalletsClosure) {
        GETRequestWithPath(path: "/portal/user/dashboard/get_user_wallets") { (result) -> (Void) in
            switch result {
            case .success(let data):
                do {
                    let userWalletsResponse = try self.jsonDecoder.decode(Array<WalletsResponse>.self, from: data)
                    response(.success(response: userWalletsResponse))
                } catch {
                    response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                }
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    func changeWalletData(request: ChangeWalletRequest, response: @escaping ChangeWalletDataClosure) {
        POSTRequestWithPath(path: "/portal/user/dashboard/change_wallet_data", parameters: request.toDictionary()) { (result) -> (Void) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    response(.success)
                case .failure(let error):
                    response(.failure(error: error))
                }
            }
        }
    }
    
    func removeFederationAddress(walletId: Int, response: @escaping ChangeWalletDataClosure) {
        let params = ["id": walletId]
        
        POSTRequestWithPath(path: "/portal/user/dashboard/remove_wallet_federation_address", parameters: params) { (result) -> (Void) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    response(.success)
                case .failure(let error):
                    response(.failure(error: error))
                }
            }
        }
    }
    
    func addWallet(publicKey: String, name: String, federationAddress: String? = "", showOnHomescreen: Bool, completion: @escaping AddWalletClosure) {
        var params = Dictionary<String, Any>()
        params["public_key"] = publicKey
        params["wallet_name"] = name
        params["federation_address"] = federationAddress
        params["show_on_homescreen"] = showOnHomescreen
        
        POSTRequestWithPath(path: "/portal/user/dashboard/add_wallet", parameters: params) { (result) -> (Void) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    completion(.success)
                case .failure(let error):
                    completion(.failure(error: error))
                }
            }
        }
    }
    
    func setWalletHomescreen(walletID: Int, isVisible: Bool, completion: @escaping SetWalletHomescreenClosure) {
        var params = Dictionary<String, Any>()
        params["id"] = walletID
        params["visible"] = isVisible
        
        POSTRequestWithPath(path: "/portal/user/dashboard/wallet_set_homescreen", parameters: params) { (result) -> (Void) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    completion(.success)
                case .failure(let error):
                    completion(.failure(error: error))
                }
            }
        }
    }
    
    open func removeCachedAccountDetails(accountId:String){
        accountDetailsCache.removeObject(forKey: accountId as NSString)
    }
    
    open func removeAllCachedAccountDetails(){
        accountDetailsCache.removeAllObjects()
    }
    
    open func formatAmount(amount: String) -> String {
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.minimumFractionDigits = 2
        currencyFormatter.maximumFractionDigits = 5
        currencyFormatter.numberStyle = .decimal
        currencyFormatter.locale = Locale.current
        
        var value = "0.00"
        if let coinUnit = CoinUnit(amount) {
            let numberAmount = NSNumber(value:coinUnit)
            if let formattedValue = currencyFormatter.string(from: numberAmount) {
                value = formattedValue
            }
        }
        
        return value
    }
    
    open func getAccountDetails(accountId: String, response: @escaping AccountResponseClosure) {
        
        if let cachedObject = accountDetailsCache.object(forKey: accountId as NSString) {
            if let entry = cachedObject as? AcDetailsCacheEntry {
                let validEntryDate = Date().addingTimeInterval(-1.0 * accountDetailsCachingDuration)
                if validEntryDate <= entry.date {
                    print("CACHE: account details FOUND for \(accountId)")
                    response(.success(details:entry.accountResponse))
                    return
                } else {
                    print("CACHE: account details TO OLD for \(accountId)")
                    accountDetailsCache.removeObject(forKey: accountId as NSString)
                }
            }
        }
        
        stellarSDK.accounts.getAccountDetails(accountId: accountId) { (accountResponse) -> (Void) in
            print("CACHE: account details loaded for \(accountId)")
            switch accountResponse {
            case .success(details: let accountDetails):
                let newEntry = AcDetailsCacheEntry(date:Date(), accountResponse:accountDetails)
                self.accountDetailsCache.setObject(newEntry, forKey: accountId as NSString)
                response(.success(details:accountDetails))
            case .failure(let error):
                response(.failure(error:error))
            }
        }
    }
}
