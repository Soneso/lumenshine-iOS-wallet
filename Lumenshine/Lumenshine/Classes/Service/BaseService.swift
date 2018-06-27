//
//  BaseService.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 3/19/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public enum ServiceError: Error {
    case userNotLoggedIn
    case unexpectedDataType
    case invalidRequest
    case badCredentials
    case parsingFailed(message: String)
    case encryptionFailed(message: String)
    case validationFailed(error: ErrorResponse)
}

extension ServiceError: LocalizedError {
    
    public var errorCode: String? {
        switch self {
        case .validationFailed(let error):
            return "Error code: \(error.errorCode ?? 1)"
        default:
            return "Error"
        }
    }
    
    public var parameterName: String? {
        switch self {
        case .validationFailed(let error):
            return error.parameterName
        default:
            return nil
        }
    }
    
    
    public var errorDescription: String? {
        switch self {
        case .userNotLoggedIn:
            return R.string.localizable.user_not_logged_in()
        case .unexpectedDataType:
            return R.string.localizable.unexpected_data_type()
        case .invalidRequest:
            return R.string.localizable.invalid_request()
        case .badCredentials:
            return R.string.localizable.bad_credentials()
        case .parsingFailed(let message):
            return message
        case .encryptionFailed(let message):
            return message
        case .validationFailed(let error):
            return error.errorMessage ?? ""
        }
    }
}

/// An enum for HTTP methods
public enum HTTPMethod {
    case get
    case post
}

/// An enum to diferentiate between succesful and failed responses
public enum Result {
    case success(data: Data)
    case failure(error: ServiceError)
}

enum JwtTokenType {
    case partial
    case full
    case lost
}

/// A closure to be called when a HTTP response is received
public typealias ResponseClosure = (_ response:Result) -> (Void)

public class BaseService: NSObject {
    
    internal let baseURL: String
    internal let jsonDecoder = JSONDecoder()
    
    static var jwtToken: String?
    static var jwtTokenType: JwtTokenType?
    
    private override init() {
        baseURL = ""
    }
    
    init(baseURL: String) {
        self.baseURL = baseURL
        jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601)
    }
    
    static func removeToken() {
        jwtToken = nil
        jwtTokenType = nil
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
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        
        urlRequest.setValue(BaseService.jwtToken, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            
            if let httpResponse = response as? HTTPURLResponse {
                if let token = httpResponse.allHeaderFields["Authorization"] as? String {
                    BaseService.jwtToken = token
                }
                
                switch httpResponse.statusCode {
                case 200:
                    break
                case 400...500:
                    if let errorData = data {
                        do {
                            let errorResponses = try self.jsonDecoder.decode(Array<ErrorResponse>.self, from: errorData)
                            if let err = errorResponses.first {
                                completion(.failure(error: .validationFailed(error: err)))
                                return
                            } else {
                                completion(.failure(error: .unexpectedDataType))
                                return
                            }
                        } catch {
                            do {
                                let errorResponse = try self.jsonDecoder.decode(ErrorResponse.self, from: errorData)
                                completion(.failure(error: .validationFailed(error: errorResponse)))
                                return
                            } catch {
                                completion(.failure(error: .unexpectedDataType))
                                return
                            }
                        }
                    }
                default:
                    completion(.failure(error:.invalidRequest))
                    return
                }
            }
            
            if let error = error {
                completion(.failure(error: .parsingFailed(message: error.localizedDescription)))
                return
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
