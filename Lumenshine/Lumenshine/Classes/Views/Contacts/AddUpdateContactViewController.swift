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
    fileprivate let textField1 = LSTextField()
    fileprivate let textField2 = LSTextField()
    fileprivate let textField3 = LSTextField()
    fileprivate let submitButton = LSButton()
    fileprivate let removeButton = LSButton()
    
    fileprivate let errorLabel1 = UILabel()
    fileprivate let errorLabel2 = UILabel()
    fileprivate let errorLabel3 = UILabel()
    
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
        errorLabel1.text = nil
        errorLabel2.text = nil
        errorLabel3.text = nil
        
        guard let name = textField1.text,
            !name.isEmpty else {
                errorLabel1.text = R.string.localizable.name_mandatory()
                return
        }
        _ = resignFirstResponder()
        
        viewModel.addUpdateContact(name: name, address: textField2.text, publicKey: textField3.text) { [weak self] result in
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
                errorLabel2.text = error.errorDescription
                return
            } else if parameter == "public_key" {
//                errorLabel3.text = error.errorDescription
                errorLabel3.text = R.string.localizable.invalid_public_key()
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
        textField1.text = "\(contact.givenName) \(contact.familyName)"
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
        
        textField1.text = viewModel.inputText1
        textField1.placeholder = R.string.localizable.name()
        textField1.borderWidthPreset = .border2
        textField1.borderColor = Stylesheet.color(.gray)
        textField1.dividerNormalHeight = 1
        textField1.dividerActiveHeight = 1
        textField1.dividerNormalColor = Stylesheet.color(.gray)
        textField1.backgroundColor = .white
        textField1.textInset = horizontalSpacing
        
        let icon = IconButton(frame: .zero)
        icon.image = R.image.contact_add()
        icon.addTarget(self, action: #selector(contactsAction(sender:)), for: .touchUpInside)
        
        textField1.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.right.equalTo(-5)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(35)
        }
        
        textField2.text = viewModel.inputText2
        textField2.keyboardType = .emailAddress
        textField2.placeholder = R.string.localizable.stellar_address()
        textField2.borderWidthPreset = .border2
        textField2.borderColor = Stylesheet.color(.gray)
        textField2.dividerNormalHeight = 1
        textField2.dividerActiveHeight = 1
        textField2.dividerNormalColor = Stylesheet.color(.gray)
        textField2.backgroundColor = .white
        textField2.textInset = horizontalSpacing
        textField2.detail = R.string.localizable.stellar_address_hint()
        textField2.detailColor = Stylesheet.color(.gray)
        textField2.detailLabel.numberOfLines = 1
        
        textField3.text = viewModel.inputText3
        textField3.placeholder = R.string.localizable.stellar_public_key()
        textField3.borderWidthPreset = .border2
        textField3.borderColor = Stylesheet.color(.gray)
        textField3.dividerNormalHeight = 1
        textField3.dividerActiveHeight = 1
        textField3.dividerNormalColor = Stylesheet.color(.gray)
        textField3.backgroundColor = .white
        textField3.textInset = horizontalSpacing
        textField3.detail = R.string.localizable.stellar_public_key_hint()
        textField3.detailColor = Stylesheet.color(.gray)
        textField3.detailLabel.numberOfLines = 1
        
        view.addSubview(textField1)
        textField1.snp.makeConstraints { make in
            make.top.equalTo(verticalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
            make.height.equalTo(50)
        }
        
        view.addSubview(textField2)
        textField2.snp.makeConstraints { make in
            make.top.equalTo(textField1.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(textField1)
            make.right.equalTo(textField1)
            make.height.equalTo(textField1)
        }
        
        view.addSubview(textField3)
        textField3.snp.makeConstraints { make in
            make.top.equalTo(textField2.snp.bottom).offset(verticalSpacing+horizontalSpacing)
            make.left.equalTo(textField1)
            make.right.equalTo(textField1)
            make.height.equalTo(textField1)
        }
    }
    
    func prepareLabels() {
        errorLabel1.font = R.font.encodeSansRegular(size: 13)
        errorLabel1.adjustsFontSizeToFitWidth = true
        errorLabel1.textColor = Stylesheet.color(.red)
        errorLabel1.backgroundColor = view.backgroundColor
        
        view.addSubview(errorLabel1)
        errorLabel1.snp.makeConstraints { make in
            make.top.equalTo(textField1.snp.bottom)
            make.left.equalTo(textField1).offset(horizontalSpacing)
            make.right.equalTo(textField1)
        }
        
        errorLabel2.font = R.font.encodeSansRegular(size: 13)
        errorLabel2.adjustsFontSizeToFitWidth = true
        errorLabel2.textColor = Stylesheet.color(.red)
        errorLabel2.backgroundColor = view.backgroundColor
        
        view.addSubview(errorLabel2)
        errorLabel2.snp.makeConstraints { make in
            make.top.equalTo(textField2.snp.bottom)
            make.left.equalTo(textField2).offset(horizontalSpacing)
            make.right.equalTo(textField2)
        }
        
        errorLabel3.font = R.font.encodeSansRegular(size: 13)
        errorLabel3.adjustsFontSizeToFitWidth = true
        errorLabel3.textColor = Stylesheet.color(.red)
        errorLabel3.backgroundColor = view.backgroundColor
        
        view.addSubview(errorLabel3)
        errorLabel3.snp.makeConstraints { make in
            make.top.equalTo(textField3.snp.bottom)
            make.left.equalTo(textField3).offset(horizontalSpacing)
            make.right.equalTo(textField3)
        }
    }
    
    func prepareButtons() {
        submitButton.title = viewModel.submitTitle
        submitButton.backgroundColor = Stylesheet.color(.blue)
        submitButton.addTarget(self, action: #selector(submitAction(sender:)), for: .touchUpInside)
        
        view.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(textField3.snp.bottom).offset(verticalSpacing+10)
            make.left.equalTo(2*horizontalSpacing)
            make.width.equalTo(100)
            make.height.equalTo(38)
        }
        
        removeButton.isHidden = viewModel.removeIsHidden
        removeButton.title = R.string.localizable.remove().uppercased()
        removeButton.backgroundColor = Stylesheet.color(.red)
        removeButton.addTarget(self, action: #selector(removeAction(sender:)), for: .touchUpInside)
        
        view.addSubview(removeButton)
        removeButton.snp.makeConstraints { make in
            make.top.equalTo(submitButton.snp.bottom).offset(20)
            make.left.equalTo(submitButton)
            make.width.equalTo(submitButton)
            make.height.equalTo(38)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
}
