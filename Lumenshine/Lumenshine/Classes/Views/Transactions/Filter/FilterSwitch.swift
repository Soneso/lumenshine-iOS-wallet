//
//  FilterSwitch.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 20/11/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

protocol FilterSwitchProtocol  {
    func show(tags: [String], color: UIColor)
    func setTitle(_ text: String)
}

class FilterSwitch: View {
    
    let `switch` = UISwitch()
    let titleLabel = UILabel()
    let tagsView = TagsCollectionView()
    
    fileprivate let horizontalSpacing: CGFloat = 15.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        
        isUserInteractionEnabled = true
        borderWidthPreset = .border1
        borderColor = Stylesheet.color(.gray)
        
        addSubview(self.switch)
        self.switch.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(horizontalSpacing)
        }
        
        titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textColor = Stylesheet.color(.blue)
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(self.switch.snp.right).offset(2*horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        addSubview(tagsView)
        tagsView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.equalTo(titleLabel)
            make.right.equalTo(-horizontalSpacing)
            make.bottom.equalToSuperview()
        }
        
        let arrow = UIImageView(image: R.image.accessory_arrow())
        
        addSubview(arrow)
        arrow.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-5)
        }
    }
}
extension FilterSwitch: FilterSwitchProtocol {
    func show(tags: [String], color: UIColor) {
        tagsView.items = tags
        tagsView.color = color
//        tagsView.layoutIfNeeded()
    }
    
    func setTitle(_ text: String) {
        titleLabel.text = text
    }
}
