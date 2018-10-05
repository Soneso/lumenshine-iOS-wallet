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
        textField1.detail = nil
        
        guard let name = textField1.text,
            !name.isEmpty else {
                textField1.detail = R.string.localizable.invalid_input()
                return
        }
        _ = resignFirstResponder()
        
        viewModel.addUpdateContact(name: name, address: textField2.text, publicKey: textField3.text) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.dismiss(animated: true)
                case .failure(let error):
                    let alert = AlertFactory.createAlert(error: error)
                    self?.present(alert, animated: true)
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
                    self?.dismiss(animated: true)
                case .failure(let error):
                    let alert = AlertFactory.createAlert(error: error)
                    self?.present(alert, animated: true)
                }
            }
        }
    }

    @objc
    func closeAction(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func contactsAction(sender: UIButton) {
        let cnPicker = CNContactPickerViewController()
        cnPicker.delegate = self
        present(cnPicker, animated: true, completion: nil)
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
        prepareButtons()
    }
    
    func prepareNavigationItem() {
        
        let backButton = Button()
        backButton.image = Icon.arrowBack?.tint(with: Stylesheet.color(.white))
        backButton.addTarget(self, action: #selector(closeAction(sender:)), for: .touchUpInside)
        
        navigationItem.leftViews = [backButton]
        
        navigationItem.titleLabel.text = viewModel.contactTitle
        navigationItem.titleLabel.textColor = .white
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
