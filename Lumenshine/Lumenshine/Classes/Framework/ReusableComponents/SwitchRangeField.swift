//
//  SwitchRangeField.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 26/11/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class SwitchRangeField: SwitchInputField {
    
    let rangeTextField = LSTextField()
    
    override func commonInit() {
        super.commonInit()
        
        textField.snp.remakeConstraints { make in
            make.right.equalTo(self.snp.centerX).offset(-15/2)
            make.top.equalTo(self.switch.snp.bottom).offset(5)
            make.left.equalTo(self.switch)
            make.height.equalTo(40)
            make.bottom.equalToSuperview()
        }
        
        rangeTextField.borderWidthPreset = .border2
        rangeTextField.borderColor = Stylesheet.color(.gray)
        rangeTextField.dividerNormalHeight = 1
        rangeTextField.dividerActiveHeight = 1
        rangeTextField.dividerNormalColor = Stylesheet.color(.gray)
        
        addSubview(rangeTextField)
        rangeTextField.snp.makeConstraints { make in
            make.top.bottom.equalTo(textField)
            make.left.equalTo(textField.snp.right).offset(15)
            make.right.equalToSuperview()
        }
    }
    
    override func switchChangedValue(sender: UISwitch) {
        super.switchChangedValue(sender: sender)
        rangeTextField.isEnabled = sender.isOn
        if sender.isOn {
            rangeTextField.backgroundColor = Stylesheet.color(.white)
            rangeTextField.textColor = Stylesheet.color(.black)
        } else {
            rangeTextField.backgroundColor = Stylesheet.color(.gray)
            rangeTextField.textColor = Stylesheet.color(.white)
        }
    }
}


