//
//  RegistrationTableViewCell.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 4/21/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

protocol RegistrationTableCellProtocol {
    func setPlaceholder(_ placeholder: String?)
    func setText(_ text: String?)
    func setSecureText(_ isSecure: Bool)
    func setInputViewOptions(_ options: [String]?, selectedIndex: Int?)
    func setDateInputView(_ isDate: Bool)
    func setKeyboardType(_ type: UIKeyboardType)
}

typealias TextChangedClosure = (_ text:String) -> (Void)

class RegistrationTableViewCell: UITableViewCell {
    
    fileprivate let horizontalSpacing: CGFloat = 15.0
    fileprivate let textField = LSTextField()
    
    var textEditingCallback: TextChangedClosure?
    var shouldBeginEditingCallback: (() -> (Bool))?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = UIEdgeInsetsInsetRect(contentView.frame, UIEdgeInsetsMake(0, horizontalSpacing, 0, horizontalSpacing))
    }
    
    func commonInit() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = Stylesheet.color(.white)
        
        textField.addTarget(self, action: #selector(editingDidChange(_:)), for: .editingChanged)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.delegate = self
        
        contentView.addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.top.equalTo(horizontalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
            make.bottom.equalTo(-horizontalSpacing)
        }
    }
    
    @objc
    func editingDidChange(_ textField: TextField) {
        guard let text = textField.text else {
            return
        }
        guard let callback = textEditingCallback else {
            return
        }
        callback(text)
    }

}

extension RegistrationTableViewCell: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard let callback = shouldBeginEditingCallback else {
            return true
        }        
        return callback()
    }
    
}

extension RegistrationTableViewCell: RegistrationTableCellProtocol {
    func setInputViewOptions(_ options: [String]?, selectedIndex: Int? = nil) {
        if let opt = options {
            let enumPicker = EnumPicker()
            enumPicker.setValues(opt, currentSelection: selectedIndex) { (newIndex) in
                self.textField.text = opt[newIndex]
                self.editingDidChange(self.textField)
            }
            textField.inputView = enumPicker
        } else {
            textField.inputView = nil
        }
    }
    
    func setDateInputView(_ isDate: Bool) {
        if isDate == true {
            setDatePickerInputView()
        }
    }
    
    func setKeyboardType(_ type: UIKeyboardType) {
        textField.keyboardType = type
    }
    
    func setPlaceholder(_ placeholder: String?) {
        textField.placeholder = placeholder
    }
    
    func setText(_ text: String?) {
        textField.text = text
    }
    
    func setSecureText(_ isSecure: Bool) {
        textField.isSecureTextEntry = isSecure
    }
}

fileprivate extension RegistrationTableViewCell {
    func setDatePickerInputView() {
        var minYear = DateComponents()
        minYear.year = 1910
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        datePicker.minimumDate = Calendar.current.date(from: minYear)
        datePicker.addTarget(self, action: #selector(birthdayDidChange(sender:)), for: .valueChanged)
        
        textField.inputView = datePicker
    }
    
    @objc
    fileprivate func birthdayDidChange(sender: UIDatePicker) {
        textField.text = DateUtils.format(sender.date, in: .date)
        editingDidChange(textField)
    }
}
