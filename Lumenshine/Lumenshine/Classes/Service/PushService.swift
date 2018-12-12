//
//  PushService.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public class PushService: BaseService {
    override init(baseURL: String) {
        super.init(baseURL: baseURL)
    }
    
    func subscribe(pushToken: String, deviceType: String = "apple", response: @escaping EmptyResponseClosure) {
        var params = Dictionary<String, Any>()
        params["push_token"] = pushToken
        params["device_type"] = deviceType
        
        POSTRequestWithPath(path: "/portal/user/dashboard/subscribe_push_token", parameters: params) { (result) -> (Void) in
            switch result {
            case .success:
                response(.success)
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    func unsubscribe(pushToken: String, response: @escaping EmptyResponseClosure) {
        var params = Dictionary<String, Any>()
        params["push_token"] = pushToken
        
        POSTRequestWithPath(path: "/portal/user/dashboard/unsubscribe_push_token", parameters: params) { (result) -> (Void) in
            switch result {
            case .success:
                response(.success)
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    func unsubscribePreviousUser(pushToken: String, email: String, response: @escaping EmptyResponseClosure) {
        var params = Dictionary<String, Any>()
        params["push_token"] = pushToken
        params["email"] = email
        
        POSTRequestWithPath(path: "/portal/user/dashboard/unsubscribe_previous_user_push_token", parameters: params) { (result) -> (Void) in
            switch result {
            case .success:
                response(.success)
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    func update(newPushToken: String, oldPushToken: String, deviceType: String = "apple", response: @escaping EmptyResponseClosure) {
        var params = Dictionary<String, Any>()
        params["new_push_token"] = newPushToken
        params["old_push_token"] = oldPushToken
        params["device_type"] = deviceType
            
        POSTRequestWithPath(path: "/portal/user/dashboard/subscribe_push_token", parameters: params) { (result) -> (Void) in
            switch result {
            case .success:
                response(.success)
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
}
