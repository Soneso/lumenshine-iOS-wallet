//
//  ComposeNavigationController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 9/19/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class ComposeNavigationController: NavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.clipsToBounds = true
        view.layer.cornerRadius = 16.0
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    override func prepare() {
        super.prepare()
        
//        transitioningDelegate = self
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
