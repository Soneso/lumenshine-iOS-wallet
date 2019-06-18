//
//  HelpTableViewCell.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

protocol HelpCellProtocol {
    func setText(_ text: String?)
    func setDetail(_ detail: String?)
    func setImage(_ image: UIImage?)
}

class HelpTableViewCell: UITableViewCell {
    
    fileprivate let titleLabel = UILabel()
    fileprivate let iconImageView = UIImageView()
    
    fileprivate let verticalSpacing = 31.0
    fileprivate let horizontalSpacing: CGFloat = 15.0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: horizontalSpacing, bottom: 0, right: horizontalSpacing))
    }
    
    func commonInit() {
        contentView.backgroundColor = Stylesheet.color(.white)
        backgroundColor = .clear
        
        iconImageView.contentMode = .scaleAspectFit
        
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.left.equalTo(horizontalSpacing)
            make.top.bottom.equalToSuperview()
        }
        
        titleLabel.textColor = Stylesheet.color(.lightBlack)
        titleLabel.font = R.font.encodeSansSemiBold(size: 14)
        titleLabel.numberOfLines = 0
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(iconImageView.snp.right).offset(horizontalSpacing)
            make.right.lessThanOrEqualToSuperview()
            make.bottom.equalToSuperview()
        }
        
        let selection = UIView()
        selection.backgroundColor = Stylesheet.color(.lightGray)
        selectedBackgroundView = selection
    }
}

extension HelpTableViewCell: HelpCellProtocol {
    func setText(_ text: String?) {
        titleLabel.text = text
    }
    
    func setDetail(_ detail: String?) {

        if let title = titleLabel.text,
            let d = detail, !d.isEmpty {
            
            let prefix_font = R.font.encodeSansBold(size: 14) ?? Stylesheet.font(.body)
            let font = R.font.encodeSansRegular(size: 14) ?? Stylesheet.font(.body)
            let attrStr = NSMutableAttributedString(string: title+"\n",
                                             attributes: [.font : prefix_font,
                                                          .foregroundColor : Stylesheet.color(.lightBlack)])
            
            let attrStr2 = NSAttributedString(string: d,
                                              attributes: [.font : font,
                                                           .foregroundColor : Stylesheet.color(.darkGray)])
            attrStr.append(attrStr2)
            titleLabel.attributedText = attrStr
        }
    }
    
    func setImage(_ image: UIImage?) {
        iconImageView.image = image?.tint(with: Stylesheet.color(.blue))
    }
}
