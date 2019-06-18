//
//  ToolbarHeader.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

protocol ToolbarHeaderProtocol {
    func setTitle(_ title: String?)
    func setDetail(_ detail: String?)
    func setItems(_ items: [(String, String)], selectedAt index: Int?)
    func selectItem(at index: Int)
    func deselectItem()
    
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
        
        addSubview(logoImage)
        logoImage.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(-29)
            } else {
                make.top.equalTo(self.snp.top)
            }
            
            make.centerX.equalToSuperview()
            make.height.equalTo(logoImage.snp.width)
        }
        
        titleLabel.font = R.font.encodeSansSemiBold(size: 19)
        titleLabel.textColor = Stylesheet.color(.blue)
        titleLabel.textAlignment = .center
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImage.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        
        detailLabel.font = R.font.encodeSansLight(size: 15)
        detailLabel.textColor = Stylesheet.color(.orange)
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
            make.bottom.equalTo(-13)
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
        var attributes: Dictionary<NSAttributedString.Key, Any>? = nil
        if let font = R.font.encodeSansRegular(size: 10) {
            attributes = [NSAttributedString.Key.font : font]
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
    
    func deselectItem() {
        tabBar.selectedItem = nil
        selectedIndex = nil
    }
}
