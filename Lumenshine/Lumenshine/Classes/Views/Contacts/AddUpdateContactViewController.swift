//
//  AddUpdateContactViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 10/3/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material
import ContactsUI

class AddUpdateContactViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate let viewModel: ContactsViewModelType
    
    // MARK: - UI properties
    fileprivate let nameField = LSTextField()
    fileprivate let addressField = LSTextField()
    fileprivate let submitButton = LSButton()
    fileprivate let removeButton = LSButton()
    
    fileprivate let nameErrorLabel = UILabel()
    fileprivate let addressErrorLabel = UILabel()
    
    fileprivate let verticalSpacing: CGFloat = 30.0
    fileprivate let horizontalSpacing: CGFloat = 15.0
    
    init(viewModel: ContactsViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareView()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
    
extension AddUpdateContactViewController {
    @objc
    func submitAction(sender: UIButton) {
        nameErrorLabel.text = nil
        addressErrorLabel.text = nil
        
        guard let name = nameField.text,
            !name.isEmpty else {
                nameErrorLabel.text = R.string.localizable.name_mandatory()
                return
        }
        _ = resignFirstResponder()
        
        viewModel.addUpdateContact(name: name, address: addressField.text ?? "") { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    self?.present(error: error)
                }
            }
        }
    }
    
    @objc
    func removeAction(sender: UIButton) {
        viewModel.removeContact() { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    self?.present(error: error)
                }
            }
        }
    }
    
    @objc
    func contactsAction(sender: UIButton) {
        let cnPicker = CNContactPickerViewController()
        cnPicker.delegate = self
        present(cnPicker, animated: true, completion: nil)
    }
    
    func present(error: ServiceError) {
        if let parameter = error.parameterName {
            if parameter == "address" {
                addressErrorLabel.text = error.errorDescription
                return
            }
        }
        let alert = AlertFactory.createAlert(error: error)
        present(alert, animated: true)
    }
}

//MARK:- CNContactPickerDelegate Method
extension AddUpdateContactViewController: CNContactPickerDelegate {
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        nameField.text = "\(contact.givenName) \(contact.familyName)"
    }
}

fileprivate extension AddUpdateContactViewController {
    func prepareView() {
        view.backgroundColor = Stylesheet.color(.veryLightGray)
        prepareNavigationItem()
        prepareTextFields()
        prepareLabels()
        prepareButtons()
    }
    
    func prepareNavigationItem() {
        navigationItem.titleLabel.text = viewModel.contactTitle
        navigationItem.titleLabel.textColor = Stylesheet.color(.blue)
        navigationItem.titleLabel.font = R.font.encodeSansBold(size: 15)
    }
    
    func prepareTextFields() {
        
        nameField.text = viewModel.inputText1
        nameField.placeholder = R.string.localizable.name()
        nameField.borderWidthPreset = .border2
        nameField.borderColor = Stylesheet.color(.gray)
        nameField.dividerNormalHeight = 1
        nameField.dividerActiveHeight = 1
        nameField.dividerNormalColor = Stylesheet.color(.gray)
        nameField.backgroundColor = .white
        nameField.textInset = horizontalSpacing
        
        let icon = IconButton(frame: .zero)
        icon.image = R.image.contact_add()
        icon.addTarget(self, action: #selector(contactsAction(sender:)), for: .touchUpInside)
        
        nameField.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.right.equalTo(-5)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(35)
        }
        
        addressField.text = viewModel.inputText2
        addressField.keyboardType = .emailAddress
        addressField.placeholder = R.string.localizable.stellar_address()
        addressField.borderWidthPreset = .border2
        addressField.borderColor = Stylesheet.color(.gray)
        addressField.dividerNormalHeight = 1
        addressField.dividerActiveHeight = 1
        addressField.dividerNormalColor = Stylesheet.color(.gray)
        addressField.backgroundColor = .white
        addressField.textInset = horizontalSpacing
        addressField.detail = R.string.localizable.stellar_address_hint()
        addressField.detailColor = Stylesheet.color(.gray)
        addressField.detailLabel.numberOfLines = 1
        
        view.addSubview(nameField)
        nameField.snp.makeConstraints { make in
            make.top.equalTo(verticalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
            make.height.equalTo(50)
        }
        
        view.addSubview(addressField)
        addressField.snp.makeConstraints { make in
            make.top.equalTo(nameField.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(nameField)
            make.right.equalTo(nameField)
            make.height.equalTo(nameField)
        }
    }
    
    func prepareLabels() {
        nameErrorLabel.font = R.font.encodeSansRegular(size: 13)
        nameErrorLabel.adjustsFontSizeToFitWidth = true
        nameErrorLabel.textColor = Stylesheet.color(.red)
        nameErrorLabel.backgroundColor = view.backgroundColor
        
        view.addSubview(nameErrorLabel)
        nameErrorLabel.snp.makeConstraints { make in
            make.top.equalTo(nameField.snp.bottom)
            make.left.equalTo(nameField).offset(horizontalSpacing)
            make.right.equalTo(nameField)
        }
        
        addressErrorLabel.font = R.font.encodeSansRegular(size: 13)
        addressErrorLabel.adjustsFontSizeToFitWidth = true
        addressErrorLabel.textColor = Stylesheet.color(.red)
        addressErrorLabel.backgroundColor = view.backgroundColor
        
        view.addSubview(addressErrorLabel)
        addressErrorLabel.snp.makeConstraints { make in
            make.top.equalTo(addressField.snp.bottom)
            make.left.equalTo(addressField).offset(horizontalSpacing)
            make.right.equalTo(addressField)
        }
    }
    
    func prepareButtons() {
        submitButton.title = viewModel.submitTitle
        submitButton.backgroundColor = Stylesheet.color(.blue)
        submitButton.addTarget(self, action: #selector(submitAction(sender:)), for: .touchUpInside)
        
        removeButton.isHidden = viewModel.removeIsHidden
        removeButton.title = R.string.localizable.remove().uppercased()
        removeButton.backgroundColor = Stylesheet.color(.red)
        removeButton.addTarget(self, action: #selector(removeAction(sender:)), for: .touchUpInside)
        
        view.addSubview(removeButton)
        removeButton.snp.makeConstraints { make in
            make.top.equalTo(addressField.snp.bottom).offset(verticalSpacing+10)
            make.left.equalTo(2*horizontalSpacing)
            make.width.equalTo(100)
            make.height.equalTo(38)
        }
        
        view.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(removeButton.snp.top)
            make.right.equalTo(addressField.snp.right).offset(-1*horizontalSpacing)
            make.width.equalTo(removeButton)
            make.height.equalTo(38)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
}
