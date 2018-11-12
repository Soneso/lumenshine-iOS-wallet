//
//  UserDataService.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 10/19/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public enum UserDataResponseEnum {
    case success(response: UserData)
    case failure(error: ServiceError)
}

public typealias UserDataResponseClosure = ( _ response: UserDataResponseEnum) -> (Void)

public class UserDataService: BaseService {
    override init(baseURL: String) {
        super.init(baseURL: baseURL)
    }
    
    func countryList(response: @escaping CountryListResponseClosure) {
        
        GETRequestWithPath(path: "/portal/user/country_list") { (result) -> (Void) in
            switch result {
            case .success(let data):
                do {
                    let countryListResponse = try self.jsonDecoder.decode(CountryListResponse.self, from: data)
                    response(.success(response: countryListResponse))
                } catch {
                    response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                }
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    func salutationList(response: @escaping SalutationsResponseClosure) {
        
        GETRequestWithPath(path: "/portal/user/salutation_list") { (result) -> (Void) in
            switch result {
            case .success(let data):
                do {
                    let salutationsResponse = try self.jsonDecoder.decode(SalutationsResponse.self, from: data)
                    response(.success(response: salutationsResponse))
                } catch {
                    response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                }
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    func getUserData(response: @escaping UserDataResponseClosure) {
        GETRequestWithPath(path: "/portal/user/dashboard/get_user_data") { (result) -> (Void) in
            switch result {
            case .success(let data):
                do {
                    let userData = try self.jsonDecoder.decode(UserData.self, from: data)
                    response(.success(response: userData))
                } catch {
                    response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                }
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    func updateUserData(userData: Dictionary<String, String>, response: @escaping EmptyResponseClosure) {
        POSTRequestWithPath(path: "/portal/user/dashboard/update_user_data", parameters: userData) { (result) -> (Void) in
            switch result {
            case .success:
                response(.success)
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
}

