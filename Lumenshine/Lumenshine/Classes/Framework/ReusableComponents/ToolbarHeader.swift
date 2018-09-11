//
//  ToolbarHeader.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 6/28/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

protocol ToolbarHeaderProtocol {
    func setTitle(_ title: String?)
    func setDetail(_ detail: String?)
    func setItems(_ items: [(String, String)], selectedAt index: Int?)
    func selectItem(at index: Int)
    
    var delegate: ToolbarHeaderDelegate? { get set }
}

protocol ToolbarHeaderDelegate: NSObjectProtocol {
    func toolbar(_ toolbar: ToolbarHeader, didSelectAt index: Int)
}

class ToolbarHeader: UIView {
    
    fileprivate let backgroundImage = UIImageView()
    fileprivate let logoImage = UIImageView()
    fileprivate let titleLabel = UILabel()
    fileprivate let detailLabel = UILabel()
    fileprivate let tabBar = UITabBar()
    fileprivate var selectedIndex: Int?
    
    weak var delegate: ToolbarHeaderDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        backgroundImage.image = R.image.header_background()
        
        addSubview(backgroundImage)
        backgroundImage.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        logoImage.image = R.image.logo()
        logoImage.contentMode = .scaleAspectFit
        
        let topOffset = UIScreen.main.scale > 2 ? 46.0 : 10.0
        addSubview(logoImage)
        logoImage.snp.makeConstraints { make in
            make.top.equalTo(topOffset)
            make.centerX.equalToSuperview()
        }
        
        titleLabel.font = R.font.encodeSansSemiBold(size: 19)
        titleLabel.textColor = Stylesheet.color(.blue)
        titleLabel.textAlignment = .center
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImage.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        
        detailLabel.font = R.font.encodeSansBold(size: 16)
        detailLabel.textColor = Stylesheet.color(.white)
        detailLabel.textAlignment = .center
        detailLabel.numberOfLines = 0
        
        addSubview(detailLabel)
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.right.equalToSuperview()
        }
        
        tabBar.delegate = self
        tabBar.backgroundImage = UIImage.image(with: Stylesheet.color(.clear), size: CGSize(width: 10, height: 10))
        tabBar.tintColor = Stylesheet.color(.lightBlue)
        tabBar.unselectedItemTintColor = Stylesheet.color(.darkBlue)
        tabBar.shadowImage = UIImage.image(with: Stylesheet.color(.clear), size: CGSize(width: 10, height: 10))
        tabBar.itemWidth = 90
        tabBar.itemSpacing = 50
        
        addSubview(tabBar)
        tabBar.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(20)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(-10)
        }
    }
}

extension ToolbarHeader: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if selectedIndex != item.tag {
            delegate?.toolbar(self, didSelectAt: item.tag)
            selectedIndex = item.tag
        }
    }
}

extension ToolbarHeader: ToolbarHeaderProtocol {
    func setTitle(_ title: String?) {
        titleLabel.text = title
    }
    
    func setDetail(_ detail: String?) {
        if detail?.isEmpty == false {
            titleLabel.font = R.font.encodeSansBold(size: 19)
        }
        detailLabel.text = detail
    }
    
    func setItems(_ items: [(String, String)], selectedAt index: Int? = 0) {
        var attributes: Dictionary<NSAttributedStringKey, Any>? = nil
        if let font = R.font.encodeSansRegular(size: 10) {
            attributes = [NSAttributedStringKey.font : font]
        }
        var barItems = [UITabBarItem]()
        var selectedItem: UITabBarItem?
        for (i, value) in items.enumerated() {
            let image = UIImage(named: value.1)
            let item = UITabBarItem(title: value.0.uppercased(), image: image, tag: i)
            item.setTitleTextAttributes(attributes, for: .normal)
            item.setTitleTextAttributes(attributes, for: .selected)
            barItems.append(item)
            if i == index {
                selectedItem = item
                selectedIndex = index
            }
        }
        tabBar.items = barItems
        tabBar.selectedItem = selectedItem
    }
    
    func selectItem(at index: Int) {
        tabBar.selectedItem = tabBar.items?[index]
        selectedIndex = index
    }
}

