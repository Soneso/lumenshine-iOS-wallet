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
    func setItems(_ items: [(String, String)], selectedAt index: Int)
    func selectItem(at index: Int)
    
    var delegate: ToolbarHeaderDelegate? { get set }
}

protocol ToolbarHeaderDelegate {
    func toolbar(_ toolbar: ToolbarHeader, didSelectAt index: Int)
}

class ToolbarHeader: UIView {
    
    fileprivate let titleLabel = UILabel()
    fileprivate let detailLabel = UILabel()
    fileprivate let tabBar = UITabBar()
    fileprivate var selectedIndex: Int?
    
    var delegate: ToolbarHeaderDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        
        selectedIndex = 0
        backgroundColor = Stylesheet.color(.cyan)
        
        titleLabel.font = UIFont.systemFont(ofSize: 25.0)
        titleLabel.textColor = Stylesheet.color(.orange)
        titleLabel.textAlignment = .center
        titleLabel.sizeToFit()
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        detailLabel.font = UIFont.systemFont(ofSize: 16.0)
        detailLabel.textColor = Stylesheet.color(.white)
        detailLabel.textAlignment = .center
        detailLabel.numberOfLines = 0
        detailLabel.sizeToFit()
        
        addSubview(detailLabel)
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.right.equalToSuperview()
        }
        
        tabBar.delegate = self
        tabBar.backgroundImage = UIImage.image(with: Stylesheet.color(.clear), size: CGSize(width: 10, height: 10))
        tabBar.tintColor = Stylesheet.color(.yellow)
        tabBar.unselectedItemTintColor = Stylesheet.color(.white)
        tabBar.shadowImage = UIImage.image(with: Stylesheet.color(.clear), size: CGSize(width: 10, height: 10))
        tabBar.itemWidth = 90
        tabBar.itemSpacing = 50
        
        addSubview(tabBar)
        tabBar.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(10)
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
        detailLabel.text = detail
    }
    
    func setItems(_ items: [(String, String)], selectedAt index: Int = 0) {
        var barItems = [UITabBarItem]()
        var selectedItem: UITabBarItem?
        for (i, value) in items.enumerated() {
            let image = UIImage(named: value.1)
            let item = UITabBarItem(title: value.0, image: image, tag: i)
            barItems.append(item)
            if i == index { selectedItem = item }
        }
        tabBar.items = barItems
        tabBar.selectedItem = selectedItem
    }
    
    func selectItem(at index: Int) {
        tabBar.selectedItem = tabBar.items?[index]
        selectedIndex = index
    }
}

