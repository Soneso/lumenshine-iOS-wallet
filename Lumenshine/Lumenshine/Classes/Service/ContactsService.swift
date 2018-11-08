//
//  ContactsService.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 10/2/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public enum ContactsResponseEnum {
    case success(response: [ContactResponse])
    case failure(error: ServiceError)
}

public typealias ContactsResponseClosure = ( _ response: ContactsResponseEnum) -> (Void)

public class ContactsService: BaseService {
    override init(baseURL: String) {
        super.init(baseURL: baseURL)
    }
    
    func getContactList(response: @escaping ContactsResponseClosure) {
        GETRequestWithPath(path: "/portal/user/dashboard/contact_list") { (result) -> (Void) in
            switch result {
            case .success(let data):
                do {
                    let contacts = try self.jsonDecoder.decode(Array<ContactResponse>.self, from: data)
                    response(.success(response: contacts))
                } catch {
                    response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                }
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    func addContact(name: String, address: String?, publicKey: String?, response: @escaping ContactsResponseClosure) {
        var params = Dictionary<String, String>()
        params["contact_name"] = name
        params["stellar_address"] = address
        params["public_key"] = publicKey

        POSTRequestWithPath(path: "/portal/user/dashboard/add_contact", parameters: params) { (result) -> (Void) in
            switch result {
            case .success(let data):
                do {
                    let addContactResponse = try self.jsonDecoder.decode(AddContactResponse.self, from: data)
                    response(.success(response: addContactResponse.contacts))
                } catch {
                    response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                }
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    func editContact(id: Int, name: String, address: String?, publicKey: String?, response: @escaping ContactsResponseClosure) {
        var params = Dictionary<String, Any>()
        params["id"] = id
        params["contact_name"] = name
        params["stellar_address"] = address
        params["public_key"] = publicKey
        
        POSTRequestWithPath(path: "/portal/user/dashboard/edit_contact", parameters: params) { (result) -> (Void) in
            switch result {
            case .success(let data):
                do {
                    let contacts = try self.jsonDecoder.decode(Array<ContactResponse>.self, from: data)
                    response(.success(response: contacts))
                } catch {
                    response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                }
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    func removeContact(id: Int, response: @escaping ContactsResponseClosure) {
        let params = ["id": id]
        
        POSTRequestWithPath(path: "/portal/user/dashboard/remove_contact", parameters: params) { (result) -> (Void) in
            switch result {
            case .success(let data):
                do {
                    let contacts = try self.jsonDecoder.decode(Array<ContactResponse>.self, from: data)
                    response(.success(response: contacts))
                } catch {
                    response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                }
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
}
