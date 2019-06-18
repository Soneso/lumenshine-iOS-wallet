//
//  AvatarTableViewCell.swift
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

class AvatarTableViewCell: UITableViewCell {
    
    fileprivate let _textLabel = UILabel()
    fileprivate let _imageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        
        contentView.addSubview(_imageView)
        _imageView.snp.makeConstraints { make in
            make.top.equalTo(30)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(80)
        }
        
        contentView.addSubview(_textLabel)
        _textLabel.snp.makeConstraints { make in
            make.top.equalTo(_imageView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-10)
        }
        
        _textLabel.textColor = Stylesheet.color(.white)
        _textLabel.font = R.font.encodeSansRegular(size: 12)
        _textLabel.textAlignment = .center
        
        _imageView.tintColor = Stylesheet.color(.white)
        _imageView.shapePreset = .circle
        _imageView.borderColor = Stylesheet.color(.white)
        _imageView.borderWidthPreset = .border2
        _imageView.clipsToBounds = true
        _imageView.layer.cornerRadius = 40
        
        
        let selection = UIView()
        selection.backgroundColor = Stylesheet.color(.whiteWith(alpha: 0.3))
        selectedBackgroundView = selection
        backgroundColor = Stylesheet.color(.clear)
    }
}

extension AvatarTableViewCell: MenuCellProtocol {
    func setText(_ text: String?) {
        _textLabel.text = text
    }
    
    func setImage(_ image: UIImage?) {
        _imageView.image = image
    }
}
