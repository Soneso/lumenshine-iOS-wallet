//
//  BaseService.swift
//  Stellargate
//
//  Created by Istvan Elekes on 3/19/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

enum ServiceError: Error {
    case userNotLoggedIn
    case unexpectedDataType
    case invalidRequest
    case badCredentials
}

extension ServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .userNotLoggedIn:
            return R.string.localizable.user_not_logged_in()
        case .unexpectedDataType:
            return R.string.localizable.unexpected_data_type()
        case .invalidRequest:
            return R.string.localizable.invalid_request()
        case .badCredentials:
            return R.string.localizable.bad_Credentials()
        }
    }
}

/// An enum for HTTP methods
enum HTTPMethod {
    case get
    case post
}

/// An enum to diferentiate between succesful and failed responses
enum Result {
    case success(data: Data)
    case failure(error: ServiceError)
}

/// A closure to be called when a HTTP response is received
typealias ResponseClosure = (_ response:Result) -> (Void)

class BaseService: NSObject {
    
    internal let baseURL: String
    internal let jsonDecoder = JSONDecoder()
    
    private override init() {
        baseURL = ""
    }
    
    init(baseURL: String) {
        self.baseURL = baseURL
    }
    
    /// Performs a get request to the spcified path.
    ///
    /// - parameter path:  A path relative to the baseURL. If URL parameters have to be sent they can be encoded in this parameter as you would do it with regular URLs.
    /// - parameter response:   The closure to be called upon response.
    open func GETRequestWithPath(path: String, completion: @escaping ResponseClosure) {
        requestFromUrl(url: baseURL + path, method:.get, completion:completion)
    }
    
    /// Performs a get request to the spcified path.
    ///
    /// - parameter path:  A URL for the request. If URL parameters have to be sent they can be encoded in this parameter as you would do it with regular URLs.
    /// - parameter response:   The closure to be called upon response.
    open func GETRequestFromUrl(url: String, completion: @escaping ResponseClosure) {
        requestFromUrl(url: url, method:.get, completion:completion)
    }
    
    /// Performs a post request to the spcified path.
    ///
    /// - parameter path:  A path relative to the baseURL. If URL parameters have to be sent they can be encoded in this parameter as you would do it with regular URLs.
    /// - parameter body:  An optional parameter with the data that should be contained in the request body
    /// - parameter response:   The closure to be called upon response.
    open func POSTRequestWithPath(path: String, body:Data? = nil, completion: @escaping ResponseClosure) {
        requestFromUrl(url: baseURL + path, method:.post, body:body, completion:completion)
    }
    
    open func requestFromUrl(url: String, method: HTTPMethod, body:Data? = nil, completion: @escaping ResponseClosure) {
        let url = URL(string: url)!
        var urlRequest = URLRequest(url: url)
        
        switch method {
        case .get:
            break
        case .post:
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = body
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if error != nil {
                completion(.failure(error:.invalidRequest))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                var message:String!
                if let data = data {
                    message = String(data: data, encoding: String.Encoding.utf8)
                    if message == nil {
                        message = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                    }
                } else {
                    message = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                }
                
                switch httpResponse.statusCode {
                case 200:
                    break
                default:
                    completion(.failure(error:.invalidRequest))
                    return
                }
            }
            
            if let data = data {
                completion(.success(data: data))
            } else {
                completion(.failure(error:.invalidRequest))
            }
        }
        
        task.resume()
    }
    
}
