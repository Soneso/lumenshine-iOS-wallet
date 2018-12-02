//
//  SortSwitch.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 01/12/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class SortSwitch: SwitchLabel {
    
    let button = Button()
    
    override func commonInit() {
        super.commonInit()
        
        self.switch.addTarget(self, action: #selector(switchChangedValue(sender:)), for: .valueChanged)        
        button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
        
        addSubview(button)
        button.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
            make.width.height.equalTo(40)
        }
    }
    
    @objc
    func switchChangedValue(sender: UISwitch) {
        button.isEnabled = sender.isOn
    }
    
    @objc
    func buttonTapped(sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
}

