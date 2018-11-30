//
//  InputTableViewCell.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 4/21/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

protocol InputTableCellProtocol {
    func setPlaceholder(_ placeholder: String?)
    func setText(_ text: String?)
    func setSecureText(_ isSecure: Bool)
    func setInputViewOptions(_ options: [String]?, selectedIndex: Int?)
    func setDateInputView(_ date: Date?)
    func setKeyboardType(_ type: UIKeyboardType)
}

class InputTableViewCell: UITableViewCell, InputTableCellProtocol {
    
    // MARK: - Parameters & Constants
    
    class var CellIdentifier: String {
        return "InputDataCell"
    }
    
    // MARK: - Properties
    
    fileprivate let horizontalSpacing: CGFloat = 15.0
    fileprivate let textField = LSTextField()
    
    var textEditingCallback: ((_ text:String) -> (Void))?
    var shouldBeginEditingCallback: (() -> (Bool))?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textEditingCallback = nil
        shouldBeginEditingCallback = nil
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
    
    
    // MARK: - InputTableCellProtocol methods
    
    func setInputViewOptions(_ options: [String]?, selectedIndex: Int? = nil) {
        if let opt = options {
            textField.setInputViewOptions(options: opt, selectedIndex: selectedIndex) { newIndex in
                self.editingDidChange(self.textField)
            }
        } else {
            textField.inputView = nil
        }
    }
    
    func setDateInputView(_ date: Date?) {
        if let d = date {
            setDatePickerInputView(d)
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

extension InputTableViewCell: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard let callback = shouldBeginEditingCallback else {
            return true
        }        
        return callback()
    }
    
}

fileprivate extension InputTableViewCell {
    func setDatePickerInputView(_ date: Date) {
        var minYear = DateComponents()
        minYear.year = 1910
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        datePicker.minimumDate = Calendar.current.date(from: minYear)
        datePicker.addTarget(self, action: #selector(birthdayDidChange(sender:)), for: .valueChanged)
        
        textField.inputView = datePicker
        
        datePicker.date = date
    }
    
    @objc
    fileprivate func birthdayDidChange(sender: UIDatePicker) {
        textField.text = DateUtils.format(sender.date, in: .date)
        editingDidChange(textField)
    }
}
