//
//  Services.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 3/19/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import stellarsdk

public final class Services {
#if DEBUG
    //let baseURL = "http://192.168.0.17:9000"
    //let baseURL = "http://127.0.0.1:8000"
    let baseURL = "https://demoapi.lumenshine.com"
    let horizonURL = "https://horizon-testnet.stellar.org"
#elseif DEVELOPMENT
    let baseURL = "https://demoapi.lumenshine.com"
    let horizonURL = "https://horizon-testnet.stellar.org"
#endif
    
    public var isTestURL: Bool {
        return horizonURL == "https://horizon-testnet.stellar.org"
    }
    
    static let shared = Services()
    
    public let auth: AuthService
    public let walletService: WalletsService
    public let currenciesService: CurrenciesService
    public let chartsService: ChartsService
    public let contacts: ContactsService
    public let userManager: UserManager
    
    public let stellarSdk: StellarSDK
    
    public init() {
        auth = AuthService(baseURL: baseURL)
        walletService = WalletsService(baseURL: baseURL)
        currenciesService = CurrenciesService(baseURL: baseURL)
        chartsService = ChartsService(baseURL: baseURL)
        contacts = ContactsService(baseURL: baseURL)
        userManager = UserManager()
        
        stellarSdk = StellarSDK(withHorizonUrl: horizonURL)
    }
}
