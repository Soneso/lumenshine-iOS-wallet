//
//  InputField.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 7/22/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class InputField: UIView {
    
    let textField = UITextField()
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        
        label.adjustsFontSizeToFitWidth = true
        
        addSubview(label)
        label.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(80)
        }
        
        textField.placeholder = R.string.localizable.position()
        textField.borderStyle = .bezel
        textField.keyboardType = .decimalPad
        textField.borderColor = Stylesheet.color(.red)
        
        addSubview(textField)
        textField.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.left.equalTo(label.snp.right).offset(5)
            make.width.equalTo(80)
        }
    }
    
    func makeInvalid(_ invalid: Bool) {
        if invalid {
            textField.borderWidthPreset = .border3
            label.textColor = Stylesheet.color(.red)
        } else {
            textField.borderWidthPreset = .none
            label.textColor = Stylesheet.color(.black)
        }
    }
}
