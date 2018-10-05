//
//  ContactsViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 10/2/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

protocol ContactsViewModelType: Transitionable {
    var reloadClosure: (() -> ())? { get set }
    var itemDistribution: [Int] { get }
    
    var isFiltering: Bool { get set }
    func filterItems(searchText: String)
    
    func name(at indexPath: IndexPath) -> String?
    func address(at indexPath: IndexPath) -> String?
    func publicKey(at indexPath: IndexPath) -> String?
    
    func headerTitle(at section: Int) -> String?
    func itemSelected(at indexPath: IndexPath)
    func editItemSelected(at indexPath: IndexPath)
    
    var contactTitle: String { get }
    var inputText1: String? { get }
    var inputText2: String? { get }
    var inputText3: String? { get }
    
    var submitTitle: String { get }
    var removeIsHidden: Bool { get }
    
    func showAddContact()
    func addUpdateContact(name: String, address: String?, publicKey: String?, response: @escaping ContactsResponseClosure)
    func removeContact(response: @escaping ContactsResponseClosure)
}

class ContactsViewModel : ContactsViewModelType {
    
    fileprivate let service: ContactsService
    fileprivate let user: User
    fileprivate var entries: [ContactResponse] = []
    fileprivate var filteredEntries: [ContactResponse] = []
    
    weak var navigationCoordinator: CoordinatorType?
    
    var selectedContact: ContactResponse?
    var reloadClosure: (() -> ())?
    
    init(service: ContactsService, user: User) {
        self.service = service
        self.user = user
        
        service.getContactList { [weak self] result in
            switch result {
            case .success(let contacts):
                self?.entries = contacts
                self?.reloadClosure?()
            case .failure(let error):
                print("Contact list failure: \(error)")
            }
        }
    }
    
    var itemDistribution: [Int] {
        if isFiltering {
            return [filteredEntries.count]
        }
        return [entries.count]
    }
    
    var isFiltering: Bool = false
    
    func name(at indexPath: IndexPath) -> String? {
        return entry(at: indexPath).name
    }
    
    func address(at indexPath: IndexPath) -> String? {
        return entry(at: indexPath).address
    }
    
    func publicKey(at indexPath: IndexPath) -> String? {
        return entry(at: indexPath).publicKey
    }
    
    func filterItems(searchText: String) {
        filteredEntries = entries.filter({( contact : ContactResponse) -> Bool in
            return contact.name.lowercased().contains(searchText.lowercased()) ||
                contact.address.lowercased().contains(searchText.lowercased()) ||
                contact.publicKey.lowercased().contains(searchText.lowercased())
        })
    }
    
    func headerTitle(at section: Int) -> String? {
        switch section {
        case 0:
            return R.string.localizable.contacts()
        default:
            return nil
        }
    }
    
    func itemSelected(at indexPath:IndexPath) {
        
    }
    
    func editItemSelected(at indexPath: IndexPath) {
        let contact = isFiltering ? filteredEntries[indexPath.row] : entries[indexPath.row]
        navigationCoordinator?.performTransition(transition: .showAddUpdateContact(contact))
    }
    
    // MARK: Add/Update contact
    
    func showAddContact() {
        navigationCoordinator?.performTransition(transition: .showAddUpdateContact(nil))
    }
    
    var contactTitle: String {
        return selectedContact == nil ? R.string.localizable.new_contact() : R.string.localizable.edit_contact()
    }
    
    var inputText1: String? {
        return selectedContact?.name
    }
    
    var inputText2: String? {
        return selectedContact?.address
    }
    
    var inputText3: String? {
        return selectedContact?.publicKey
    }
    
    var submitTitle: String {
        return selectedContact == nil ? R.string.localizable.add().uppercased() : R.string.localizable.update().uppercased()
    }
    
    var removeIsHidden: Bool {
        return selectedContact == nil
    }
    
    func addUpdateContact(name: String, address: String?, publicKey: String?, response: @escaping ContactsResponseClosure) {
        
        if address?.isEmpty ?? true, publicKey?.isEmpty ?? true {
            let error = ErrorResponse()
            error.errorMessage = R.string.localizable.stellar_address_error()
            response(.failure(error: .validationFailed(error: error)))
            return
        }

        if let address = address, !address.isEmpty, !address.isStellarAddress() {
            let error = ErrorResponse()
            error.errorMessage = R.string.localizable.invalid_address()
            error.parameterName = "address"
            response(.failure(error: .validationFailed(error: error)))
            return
        }

        if let publicKey = publicKey, !publicKey.isEmpty, !publicKey.isPublicKey() {
            let error = ErrorResponse()
            error.errorMessage = R.string.localizable.invalid_public_key()
            error.parameterName = "public_key"
            response(.failure(error: .validationFailed(error: error)))
            return
        }
        
        if let contactId = selectedContact?.id {
            service.editContact(id: contactId, name: name, address: address, publicKey: publicKey) { [weak self] result in
                switch result {
                case .success(let contacts):
                    self?.entries = contacts
                    self?.reloadClosure?()
                    response(result)
                case .failure:
                    response(result)
                }
            }
        } else {
            service.addContact(name: name, address: address, publicKey: publicKey) { [weak self] result in
                switch result {
                case .success(let contacts):
                    self?.entries = contacts
                    self?.reloadClosure?()
                    response(result)
                case .failure:
                    response(result)
                }
            }
        }
    }
    
    func removeContact(response: @escaping ContactsResponseClosure) {
        if let contactId = selectedContact?.id {
            service.removeContact(id: contactId) { [weak self] result in
                switch result {
                case .success(let contacts):
                    self?.entries = contacts
                    self?.reloadClosure?()
                    response(result)
                case .failure:
                    response(result)
                }
            }
        }
    }
}

fileprivate extension ContactsViewModel {
    func entry(at indexPath: IndexPath) -> ContactResponse {
        if isFiltering {
            return filteredEntries[indexPath.row]
        }
        return entries[indexPath.row]
    }
}
