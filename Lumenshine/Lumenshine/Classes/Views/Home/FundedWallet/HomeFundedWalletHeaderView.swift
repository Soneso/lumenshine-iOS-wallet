//
//  HomeFundedWalletHeaderView.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 13/06/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class HomeFundedWalletHeaderView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var foundAccountButton: UILabel!
    @IBOutlet weak var sendButton: UITabBarItem!
    @IBOutlet weak var receiveButton: UITabBarItem!
    @IBOutlet weak var moreButton: UITabBarItem!
    @IBOutlet weak var tabBar: UITabBar!
    
    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        setupTabBar()
        setupButtons()
        titleLabel.text = R.string.localizable.homeScreenTitle()
        
        guard #available(iOS 11, *) else {
            logoTopConstraint.constant = 0
            return
        }
    }
    
    private func setupTabBar() {
        tabBar.backgroundImage = UIImage.image(with: Stylesheet.color(.clear), size: CGSize(width: 10, height: 10))
        tabBar.tintColor = Stylesheet.color(.lightBlue)
        tabBar.unselectedItemTintColor = Stylesheet.color(.darkBlue)
        tabBar.shadowImage = UIImage.image(with: Stylesheet.color(.clear), size: CGSize(width: 10, height: 10))
        tabBar.itemWidth = 90
        tabBar.itemSpacing = 50
    }
    
    private func setupButtons() {
        var attributes: Dictionary<NSAttributedStringKey, Any>? = nil
        if let font = R.font.encodeSansRegular(size: 10) {
            attributes = [NSAttributedStringKey.font : font]
        }
        
        sendButton.setTitleTextAttributes(attributes, for: .normal)
        sendButton.setTitleTextAttributes(attributes, for: .selected)
        sendButton.selectedImage = R.image.sendActive()?.tint(with: Stylesheet.color(.white))
        
        receiveButton.setTitleTextAttributes(attributes, for: .normal)
        receiveButton.setTitleTextAttributes(attributes, for: .selected)
        receiveButton.selectedImage = R.image.receiveActive()?.tint(with: Stylesheet.color(.white))
        
        moreButton.setTitleTextAttributes(attributes, for: .normal)
        moreButton.setTitleTextAttributes(attributes, for: .selected)
        moreButton.selectedImage = R.image.moreActive()?.tint(with: Stylesheet.color(.white))
    }
}
