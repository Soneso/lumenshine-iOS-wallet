//
//  CardsResponsesMock.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

class CardsResponsesMock : ResponsesMock {
    var response: String?
    
    func addCardsResponse(_ response: String) {
        self.response = response
    }
    
    
    override func requestMock() -> RequestMock {
        let handler: MockHandler = { [weak self] mock, request in
            guard let response = self?.response else {
                    mock.statusCode = 404
                    return self?.resourceMissingResponse()
            }
            
            return response
        }
        
        return RequestMock(host: "service.stellar.org",
                           path: "/cards",
                           httpMethod: "GET",
                           mockHandler: handler)
    }
}
