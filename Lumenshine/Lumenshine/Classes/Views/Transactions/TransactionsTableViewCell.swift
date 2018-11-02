//
//  TransactionsTableViewCell.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 02/11/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

protocol TransactionsCellProtocol {
    func setName(_ name: String?)
    func setAddress(_ address: String?)
    func setPublicKey(_ publicKey: String?)
}

class TransactionsTableViewCell: UITableViewCell {
    
    fileprivate let nameLabel = UILabel()
    fileprivate let addressLabel = UILabel()
    fileprivate let publicKeyLabel = UILabel()
    
    fileprivate let verticalSpacing = 31.0
    fileprivate let horizontalSpacing: CGFloat = 15.0
    
    weak var delegate: ContactCellDelegate?
    
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
}

extension TransactionsTableViewCell: TransactionsCellProtocol {
    func setName(_ name: String?) {
        nameLabel.text = name
    }
    
    func setAddress(_ address: String?) {
        addressLabel.text = address
    }
    
    func setPublicKey(_ publicKey: String?) {
        publicKeyLabel.text = publicKey
    }
}


