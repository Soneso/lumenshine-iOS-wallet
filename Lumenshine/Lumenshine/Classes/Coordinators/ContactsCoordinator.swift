//
//  ContactsCoordinator.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 10/2/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class ContactsCoordinator: CoordinatorType {
    var baseController: UIViewController
    unowned var mainCoordinator: MainCoordinator
    
    fileprivate let viewModel: ContactsViewModel
    
    init(mainCoordinator: MainCoordinator, service: Services, user: User) {
        self.viewModel = ContactsViewModel(service: service.contacts, user: user)
        let viewController = ContactsViewController(viewModel: viewModel)
        
        self.mainCoordinator = mainCoordinator
        self.baseController = viewController
        viewModel.navigationCoordinator = self
        mainCoordinator.currentCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .showAddUpdateContact(let contact):
            showAddUpdateContact(contact)
        default:
            break
        }
    }
}

fileprivate extension ContactsCoordinator {
    func showAddUpdateContact(_ contact: ContactResponse?) {
        viewModel.selectedContact = contact
        let addContactVC = AddUpdateContactViewController(viewModel: viewModel)
        baseController.navigationController?.pushViewController(addContactVC, animated: true)
    }
}
