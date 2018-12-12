//
//  SwitchInputField.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class SwitchInputField: UIView {
    
    let label = UILabel()
    let `switch` = UISwitch()
    let textField = LSTextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        
        self.switch.addTarget(self, action: #selector(switchChangedValue(sender:)), for: .valueChanged)
        
        addSubview(self.switch)
        self.switch.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
        }
        
        label.font = R.font.encodeSansRegular(size: 13)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = Stylesheet.color(.lightBlack)
        
        addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalTo(self.switch)
            make.left.equalTo(self.switch.snp.right).offset(5)
        }
        
        textField.borderWidthPreset = .border2
        textField.borderColor = Stylesheet.color(.gray)
        textField.dividerNormalHeight = 1
        textField.dividerActiveHeight = 1
        textField.dividerNormalColor = Stylesheet.color(.gray)
        
        addSubview(textField)
        textField.snp.makeConstraints { make in
            make.top.equalTo(self.switch.snp.bottom).offset(5)
            make.left.equalTo(self.switch)
            make.right.equalToSuperview()
            make.height.equalTo(40)
            make.bottom.equalToSuperview()
        }
    }
    
    @objc
    func switchChangedValue(sender: UISwitch) {
        textField.isEnabled = sender.isOn
        if sender.isOn {
            textField.backgroundColor = Stylesheet.color(.white)
            textField.textColor = Stylesheet.color(.black)
        } else {
            textField.backgroundColor = Stylesheet.color(.gray)
            textField.textColor = Stylesheet.color(.white)
        }
    }
    
    func update(value: String?, animated: Bool = false) {
        if let value = value {
            self.switch.setOn(true, animated: animated)
            textField.text = value
        } else {
            self.switch.setOn(false, animated: animated)
        }
        switchChangedValue(sender: self.switch)
    }
}
