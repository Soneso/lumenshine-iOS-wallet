//
//  InputTextField.swift
//  Lumenshine
//
//  Created by Soneso on 19/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class InputTextField: UITextField {
    private var showPasswordButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        borderStyle = .none
        layer.borderWidth = 0.33
        layer.borderColor = Stylesheet.color(.borderGray).cgColor
        font = R.font.encodeSansSemiBold(size: 12)
        textColor = Stylesheet.color(.lightBlack)
        backgroundColor = Stylesheet.color(.white)
        
        if let placeholder = placeholder {
            attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor : Stylesheet.color(.lightBlack)])
        }
        
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: frame.height))
        leftViewMode = UITextField.ViewMode.always
        
        snp.makeConstraints { (make) in
            make.height.equalTo(40)
        }
        
        if isSecureTextEntry {
            addShowPasswordButton()
        }
    }
    
    private func updateShowPasswordButtonImage() {
        if isSecureTextEntry {
            showPasswordButton.setImage(Icon.visibility?.tint(with: Stylesheet.color(.gray)), for: .normal)
        } else {
            showPasswordButton.setImage(Icon.visibilityOff?.tint(with: Stylesheet.color(.gray)), for: .normal)
        }
    }
    
    private func addShowPasswordButton() {
        showPasswordButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        showPasswordButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        updateShowPasswordButtonImage()
        showPasswordButton.addTarget(self, action: #selector(showPasswordButtonAction), for: .touchUpInside)
        
        rightView = showPasswordButton
        rightViewMode = .whileEditing
    }
    
    @objc func showPasswordButtonAction() {
        isSecureTextEntry = !isSecureTextEntry
        updateShowPasswordButtonImage()
    }
}
