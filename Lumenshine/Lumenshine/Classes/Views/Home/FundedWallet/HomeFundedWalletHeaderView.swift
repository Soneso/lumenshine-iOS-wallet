//
//  HomeFundedWalletHeaderView.swift
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

class HomeFundedWalletHeaderView: UIView, UITabBarDelegate {

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var tickerLabel: UILabel!
    @IBOutlet weak var sendButton: UITabBarItem!
    @IBOutlet weak var receiveButton: UITabBarItem!
    @IBOutlet weak var moreButton: UITabBarItem!
    @IBOutlet weak var tabBar: UITabBar!
    
    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    
    private var paymentOperationsVCManager: PaymentOperationsVCManager!
    
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
        tabBar.delegate = self
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
        moreButton.selectedImage = R.image.depositActive()?.tint(with: Stylesheet.color(.white))
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let parentViewController = viewContainingController() {
            if paymentOperationsVCManager == nil {
                paymentOperationsVCManager = PaymentOperationsVCManager(parentViewController: parentViewController)
            }
            
            if item == sendButton {
                paymentOperationsVCManager.setupSendViewControllerWithMultipleWallets()
            } else if item == receiveButton {
                paymentOperationsVCManager.setupViewControllerWithMultipleWallets(forAction: .receive)
            } else if item == moreButton {
                paymentOperationsVCManager.setupViewControllerWithMultipleWallets(forAction: .deposit)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                tabBar.selectedItem = nil
            }
        }
    }
}
