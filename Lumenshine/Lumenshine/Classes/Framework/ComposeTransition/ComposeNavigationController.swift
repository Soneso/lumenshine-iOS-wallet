//
//  ComposeNavigationController.swift
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

class ComposeNavigationController: NavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.clipsToBounds = true
        view.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 16)
    }
    
    override func prepare() {
        super.prepare()

        definesPresentationContext = true
        providesPresentationContextTransitionStyle = true
        modalPresentationCapturesStatusBarAppearance = false
        modalPresentationStyle = .custom
        
        navigationBar.backIndicatorImage = Icon.arrowBack?.tint(with: Stylesheet.color(.gray))
        navigationBar.backgroundColor = Stylesheet.color(.white)
        navigationBar.depthPreset = .depth2
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension ComposeNavigationController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ComposePresentTransitionController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ComposeDismissTransitionController()
    }
}
