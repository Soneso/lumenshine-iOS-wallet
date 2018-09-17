//
//  SettingsTableViewCell.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 6/6/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

protocol SettingsCellProtocol {
    func setText(_ text: String?)
    func hideSwitch(_ hidden: Bool)
}

protocol SettingsCellDelegate {
    func switchStateChanged(cell: SettingsTableViewCell, state: Bool)
}

class SettingsTableViewCell: UITableViewCell {
    
    let stateSwitch = UISwitch()
    var delegate: SettingsCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
//        textLabel?.textColor = Stylesheet.color(.white)
        textLabel?.font = R.font.encodeSansRegular(size: 12)
        backgroundColor = Stylesheet.color(.clear)
        stateSwitch.isHidden = true
        stateSwitch.addTarget(self, action: #selector(switchChanged(sender:)), for: .valueChanged)
        
        contentView.addSubview(stateSwitch)
        stateSwitch.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.top.equalTo(10)
            make.bottom.equalTo(-10)
        }
    }
    
    @objc
    func switchChanged(sender: UISwitch) {
        delegate?.switchStateChanged(cell: self, state: sender.isOn)
    }
}

extension SettingsTableViewCell: SettingsCellProtocol {
    func setText(_ text: String?) {
        textLabel?.text = text
    }
    
    func hideSwitch(_ hidden: Bool) {
        stateSwitch.isHidden = hidden
    }
}
