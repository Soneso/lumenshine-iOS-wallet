//
//  ImageBackgroundNavigationController.swift
//  Lumenshine
//
//  Created by Soneso on 25/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class ImageBackgroundNavigationController: NavigationController {
    private let rootIndex = 0
    private var alwaysShowBackgroundImage = false
    
    convenience init(rootViewController: UIViewController, alwaysShowBackgroundImage: Bool) {
        self.init(rootViewController: rootViewController)
        self.alwaysShowBackgroundImage = alwaysShowBackgroundImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.backIndicatorImage = R.image.arrowLeft()?.crop(toWidth: 15, toHeight: 15)?.tint(with: Stylesheet.color(.white))
        view.backgroundColor = .clear
        
        if alwaysShowBackgroundImage {
            setupBackgroundImage()
        } else {
            setupRootViewControllerIfNeeded()
        }
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        setupBackgroundImage()
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        let poppedViewController = super.popViewController(animated: animated)
        setupRootViewControllerIfNeeded()
        
        return poppedViewController
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        let rootViewController = super.popToRootViewController(animated: animated)
        setupRootViewControllerIfNeeded()
        
        return rootViewController
    }
    
    private func setupBackgroundImage() {
        navigationBar.backgroundColor = Stylesheet.color(.clear)
        if let cgImage = R.image.header_background()?.cgImage {
            let backgroundImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .down).crop(toWidth: navigationBar.frame.width, toHeight: navigationBar.frame.width)
            navigationBar.setBackgroundImage(backgroundImage, for: .default)
        }
        
        statusBarVisibility(isHidden: false)
        navigationBar.isTranslucent = false
    }
    
    private func setupRootViewControllerIfNeeded() {
        if viewControllers.count == 1 && !alwaysShowBackgroundImage{
            removeBackgroundImage()
            statusBarVisibility(isHidden: true)
        }
    }
    
    private func removeBackgroundImage() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
    }
    
    private func statusBarVisibility(isHidden: Bool) {
        (drawerController as? AppNavigationDrawerController)?.hideStatusBar = isHidden
        drawerController?.setNeedsStatusBarAppearanceUpdate()
    }
}
