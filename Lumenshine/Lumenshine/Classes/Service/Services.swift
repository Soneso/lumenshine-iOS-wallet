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
    let usePublicStellarNetwork = false
    //let baseURL = "http://192.168.0.17:9000"
    //let baseURL = "http://127.0.0.1:8000"
    let baseURL = "https://demoapi.lumenshine.com"
    //let horizonURL = "https://horizon-testnet.stellar.org"
    let horizonURL = "https://demohorizon.lumenshine.com"
    let tomlURL = "https://demo.lumenshine.com/.well-known/stellar.toml"
    let initialServerSigningKey = "GCP4BR7GWG664577XMLX2BRUPSHKHTAXQ4I4HZORLMQNILNNVMSFWVUV"
    let termsUrl = "https://demo.lumenshine.com/terms"
    let privacyUrl = "https://demo.lumenshine.com/privacy"
    let guidesUrl = "https://demo.lumenshine.com/guidelines"
    
#elseif DEVELOPMENT
    let usePublicStellarNetwork = false
    let baseURL = "https://demoapi.lumenshine.com"
    let horizonURL = "https://horizon-testnet.stellar.org"
    //let horizonURL = "https://demohorizon.lumenshine.com"
    let tomlURL = "https://demo.lumenshine.com/.well-known/stellar.toml"
    let initialServerSigningKey = "GCP4BR7GWG664577XMLX2BRUPSHKHTAXQ4I4HZORLMQNILNNVMSFWVUV"
    
    /** live net **/
    //let baseURL = "https://alphaapi.lumenshine.com"
    //let horizonURL = "https://alphahorizon.lumenshine.com"
    //let tomlURL = "https://alpha.lumenshine.com/.well-known/stellar.toml"
    //let initialServerSigningKey = "GBGXAY3HDXMUWAUDATBZ5SVGLFUC5GKJC4BNN5MEPVLWKCOMBXQUIUWM"
    
    let termsUrl = "https://demo.lumenshine.com/terms"
    let privacyUrl = "https://demo.lumenshine.com/privacy"
    let guidesUrl = "https://demo.lumenshine.com/guidelines"

#else
    let usePublicStellarNetwork = true
    let baseURL = "https://alphaapi.lumenshine.com"
    let horizonURL = "https://alphahorizon.lumenshine.com"
    let tomlURL = "https://alpha.lumenshine.com/.well-known/stellar.toml"
    let initialServerSigningKey = "GBGXAY3HDXMUWAUDATBZ5SVGLFUC5GKJC4BNN5MEPVLWKCOMBXQUIUWM"
    let termsUrl = "https://lumenshine.com/terms"
    let privacyUrl = "https://lumenshine.com/privacy"
    let guidesUrl = "https://lumenshine.com/guidelines"
    
#endif
    
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
        
        stellarSdk = StellarSDK(withHorizonUrl: horizonURL)
    }
}
