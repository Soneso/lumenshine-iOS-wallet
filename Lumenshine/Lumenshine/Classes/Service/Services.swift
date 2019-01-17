//
//  Services.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import stellarsdk

public final class Services {
/*#if DEBUG
    let usePublicStellarNetwork = false
    let baseURL = "https://lsdevapi.ponytest.de"
    //let horizonURL = "https://horizon-testnet.stellar.org"
    let horizonURL = "https://lsdevhorizon.ponytest.de"
    let tomlURL = "https://lsdev.ponytest.de/.well-known/stellar.toml"
    let initialServerSigningKey = "GCP4BR7GWG664577XMLX2BRUPSHKHTAXQ4I4HZORLMQNILNNVMSFWVUV"
    let federationDomain = "lsdev.ponytest.de"
    let termsUrl = "https://lsdev.ponytest.de/terms"
    let privacyUrl = "https://lsdev.ponytest.de/privacy"
    let guidesUrl = "https://lsdev.ponytest.de/guidelines"
    
#elseif DEVELOPMENT
    let usePublicStellarNetwork = false
    let baseURL = "https://lsdevapi.ponytest.de"
    //let horizonURL = "https://horizon-testnet.stellar.org"
    let horizonURL = "https://lsdevhorizon.ponytest.de"
    let tomlURL = "https://lsdev.ponytest.de/.well-known/stellar.toml"
    let federationDomain = "lsdev.ponytest.de"
    let initialServerSigningKey = "GCP4BR7GWG664577XMLX2BRUPSHKHTAXQ4I4HZORLMQNILNNVMSFWVUV"
    
    /** live net **/
    //let baseURL = "https://lsstageapi.ponytest.de"
    //let horizonURL = "https://lsdstagehorizon.ponytest.de"
    //let tomlURL = "https://lsstage.ponytest.de/.well-known/stellar.toml"
    //let initialServerSigningKey = "GBGXAY3HDXMUWAUDATBZ5SVGLFUC5GKJC4BNN5MEPVLWKCOMBXQUIUWM"
    
    let termsUrl = "https://lsdev.ponytest.de/terms"
    let privacyUrl = "https://lsdev.ponytest.de/privacy"
    let guidesUrl = "https://lsdev.ponytest.de/guidelines"

#else*/
    let usePublicStellarNetwork = true
    let baseURL = "https://api.lumenshine.com"
    let horizonURL = "https://horizon.lumenshine.com"
    let tomlURL = "https://lumenshine.com/.well-known/stellar.toml"
    let federationDomain = "lumenshine.com"
    let initialServerSigningKey = "GBGXAY3HDXMUWAUDATBZ5SVGLFUC5GKJC4BNN5MEPVLWKCOMBXQUIUWM"
    let termsUrl = "https://lumenshine.com/terms"
    let privacyUrl = "https://lumenshine.com/privacy"
    let guidesUrl = "https://lumenshine.com/guidelines"
    
//#endif
    
    let supportEmailAddress = "support@lumenshine.com"
    
    let userDefaultsServerKey = "serverKey"
    
    public var serverSigningKey: String {
        set {
            UserDefaults.standard.set(newValue, forKey:userDefaultsServerKey)
        }
        get {
            if let keyFromPrefs = UserDefaults.standard.string(forKey: userDefaultsServerKey) {
                return keyFromPrefs
            }
            return initialServerSigningKey
        }
    }
    
    static let shared = Services()
    
    public let auth: AuthService
    public let walletService: WalletsService
    public let currenciesService: CurrenciesService
    public let chartsService: ChartsService
    public let contacts: ContactsService
    public let userManager: UserManager
    public let userData: UserDataService
    public let push: PushService
    public let webSocketService: WebSocketService
    public let transactions: TransactionsService
    
    public let stellarSdk: StellarSDK
    
    public init() {
        auth = AuthService(baseURL: baseURL)
        walletService = WalletsService(baseURL: baseURL)
        currenciesService = CurrenciesService(baseURL: baseURL)
        chartsService = ChartsService(baseURL: baseURL)
        contacts = ContactsService(baseURL: baseURL)
        userManager = UserManager()
        userData = UserDataService(baseURL: baseURL)
        push = PushService(baseURL: baseURL)
        webSocketService = WebSocketService(baseURL: baseURL)
        let _ = ReachabilityService.instance
        transactions = TransactionsService(baseURL: baseURL)
        
        stellarSdk = StellarSDK(withHorizonUrl: horizonURL)
    }
}
