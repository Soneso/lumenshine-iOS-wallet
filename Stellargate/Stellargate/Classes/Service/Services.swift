//
//  Services.swift
//  Stellargate
//
//  Created by Istvan Elekes on 3/19/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

final class Services {

    let baseURL = "https://service.stellar.org"
    let home: HomeService

    init() {
        home = HomeService(baseURL: baseURL)
    }
}
