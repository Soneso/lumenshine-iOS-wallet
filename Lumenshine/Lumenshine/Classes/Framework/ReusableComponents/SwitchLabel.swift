//
//  SwitchLabel.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 26/11/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class SwitchLabel: UIView {
    
    let label = UILabel()
    let `switch` = UISwitch()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        
        addSubview(self.switch)
        self.switch.snp.makeConstraints { make in
            make.top.bottom.left.equalToSuperview()
        }
        
        label.font = R.font.encodeSansRegular(size: 13)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = Stylesheet.color(.lightBlack)
        
        addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(self.switch.snp.right).offset(15)
            make.top.bottom.right.equalToSuperview()
        }
    }
}
