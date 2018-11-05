//
//  PushService.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 05/11/2018.
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
        
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            
            POSTRequestWithPath(path: "/portal/user/dashboard/subscribe_push_token", body: bodyData) { (result) -> (Void) in
                switch result {
                case .success:
                    response(.success)
                case .failure(let error):
                    response(.failure(error: error))
                }
            }
        } catch {
            response(.failure(error: .parsingFailed(message: error.localizedDescription)))
        }
    }
    
    func unsubscribe(pushToken: String, response: @escaping EmptyResponseClosure) {
        var params = Dictionary<String, Any>()
        params["push_token"] = pushToken
        
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            
            POSTRequestWithPath(path: "/portal/user/dashboard/unsubscribe_push_token", body: bodyData) { (result) -> (Void) in
                switch result {
                case .success:
                    response(.success)
                case .failure(let error):
                    response(.failure(error: error))
                }
            }
        } catch {
            response(.failure(error: .parsingFailed(message: error.localizedDescription)))
        }
    }
    
    func unsubscribePreviousUser(pushToken: String, email: String, response: @escaping EmptyResponseClosure) {
        var params = Dictionary<String, Any>()
        params["push_token"] = pushToken
        params["email"] = email
        
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            
            POSTRequestWithPath(path: "/portal/user/dashboard/unsubscribe_previous_user_push_token", body: bodyData) { (result) -> (Void) in
                switch result {
                case .success:
                    response(.success)
                case .failure(let error):
                    response(.failure(error: error))
                }
            }
        } catch {
            response(.failure(error: .parsingFailed(message: error.localizedDescription)))
        }
    }
    
    func update(newPushToken: String, oldPushToken: String, deviceType: String = "apple", response: @escaping EmptyResponseClosure) {
        var params = Dictionary<String, Any>()
        params["new_push_token"] = newPushToken
        params["old_push_token"] = oldPushToken
        params["device_type"] = deviceType
        
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            
            POSTRequestWithPath(path: "/portal/user/dashboard/subscribe_push_token", body: bodyData) { (result) -> (Void) in
                switch result {
                case .success:
                    response(.success)
                case .failure(let error):
                    response(.failure(error: error))
                }
            }
        } catch {
            response(.failure(error: .parsingFailed(message: error.localizedDescription)))
        }
    }
}
