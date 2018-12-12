//
//  ContactTableViewCell.swift
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
import stellarsdk

protocol ContactCellDelegate: class {
    func contactCellDidTapEdit(cell: ContactTableViewCell)
}

protocol ContactCellProtocol {
    func setName(_ name: String?)
    func setAddress(_ address: String?)
    func setPublicKey(_ publicKey: String?)
    func setDelegate(_ delegate: ContactCellDelegate)
}

class ContactTableViewCell: UITableViewCell {
    
    fileprivate let nameLabel = UILabel()
    fileprivate let addressLabel = UILabel()
    fileprivate let publicKeyLabel = UILabel()
    
    fileprivate let editButton = RaisedButton()
    fileprivate let sendButton = RaisedButton()
    
    fileprivate let verticalSpacing = 31.0
    fileprivate let horizontalSpacing: CGFloat = 15.0
    
    weak var delegate: ContactCellDelegate?
    
    private var paymentOperationsVCManager: PaymentOperationsVCManager!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
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
        contentView.backgroundColor = Stylesheet.color(.white)
        backgroundColor = .clear
        selectionStyle = .none
        
        prepareLabels()
        prepareButtons()
    }
    
    func prepareLabels() {
        nameLabel.textColor = Stylesheet.color(.lightBlack)
        nameLabel.font = R.font.encodeSansBold(size: 15)
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(horizontalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        addressLabel.textColor = Stylesheet.color(.orange)
        addressLabel.font = R.font.encodeSansRegular(size: 15)
        
        contentView.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        publicKeyLabel.textColor = Stylesheet.color(.gray)
        publicKeyLabel.font = R.font.encodeSansSemiBold(size: 15)
        publicKeyLabel.numberOfLines = 0
        
        contentView.addSubview(publicKeyLabel)
        publicKeyLabel.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }

    func prepareButtons() {
        sendButton.title = R.string.localizable.send_payment()
        sendButton.titleColor = Stylesheet.color(.blue)
        sendButton.cornerRadiusPreset = .cornerRadius5
        sendButton.titleLabel?.font = R.font.encodeSansSemiBold(size: 12)
        sendButton.borderWidthPreset = .border1
        sendButton.borderColor = Stylesheet.color(.blue)
        sendButton.addTarget(self, action: #selector(sendAction(sender:)), for: .touchUpInside)
        
        contentView.addSubview(sendButton)
        sendButton.snp.makeConstraints { make in
            make.top.equalTo(publicKeyLabel.snp.bottom).offset(10)
            make.right.equalTo(-horizontalSpacing)
            make.width.equalTo(100)
            make.height.equalTo(35)
            make.bottom.equalTo(-10)
        }
        
        editButton.title = R.string.localizable.edit()
        editButton.titleColor = Stylesheet.color(.blue)
        editButton.cornerRadiusPreset = .cornerRadius5
        editButton.titleLabel?.font = R.font.encodeSansSemiBold(size: 12)
        editButton.borderWidthPreset = .border1
        editButton.borderColor = Stylesheet.color(.blue)
        editButton.addTarget(self, action: #selector(editAction(sender:)), for: .touchUpInside)
        
        contentView.addSubview(editButton)
        editButton.snp.makeConstraints { make in
            make.top.equalTo(publicKeyLabel.snp.bottom).offset(10)
            make.right.equalTo(sendButton.snp.left).offset(-10)
            make.width.equalTo(60)
            make.height.equalTo(35)
        }
    }
    
    @objc
    func editAction(sender: UIButton) {
        delegate?.contactCellDidTapEdit(cell: self)
    }
    
    @objc
    func sendAction(sender: UIButton) {
        if let parentViewController = viewContainingController() {
            if paymentOperationsVCManager == nil {
                paymentOperationsVCManager = PaymentOperationsVCManager(parentViewController: parentViewController)
            }
            var stellarAddress = addressLabel.text
            var publicKey = publicKeyLabel.text
            if publicKey != nil, publicKey?.trimmed == "" {
                publicKey = nil
            }
            if stellarAddress != nil, stellarAddress?.trimmed == "" {
                stellarAddress = nil
            }
            paymentOperationsVCManager.setupSendViewControllerWithMultipleWallets(stellarAddress: stellarAddress, publicKey: publicKey)
        }
    }
}

extension ContactTableViewCell: ContactCellProtocol {
    func setName(_ name: String?) {
        nameLabel.text = name
    }
    
    func setAddress(_ address: String?) {
        addressLabel.text = address
    }
    
    func setPublicKey(_ publicKey: String?) {
        publicKeyLabel.text = publicKey
    }
    
    func setDelegate(_ delegate: ContactCellDelegate) {
        self.delegate = delegate
    }
}
