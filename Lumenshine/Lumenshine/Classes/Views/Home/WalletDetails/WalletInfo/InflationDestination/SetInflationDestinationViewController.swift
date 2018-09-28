//
//  SetInflationDestinationViewController.swift
//  Lumenshine
//
//  Created by Soneso on 05/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit

class SetInflationDestinationViewController: UIViewController {
    @IBOutlet weak var destinationContainer: UIView!
    
    @IBOutlet weak var knownDestinationsButton: UIButton!
    @IBOutlet weak var provideDestinationDataButton: UIButton!
    
    @IBAction func knownDestinationsButtonAction(_ sender: UIButton) {
        if sender.isSelected {
            return
        }
        
        showKnownDestinations()
    }
    
    @IBAction func provideDestinationDataButtonAction(_ sender: UIButton) {
        if sender.isSelected {
            return
        }
        
       showProvideDestinationData()
    }
    
    var wallet: FundedWallet!
    var currentInflationDestination: String?
    
    private var titleView: TitleView!
    private var provideInflationDestinationViewController: ProvideInflationDestinationViewController!
    private var knownInflationDestinationsViewController: KnownInflationDestinationsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        showKnownDestinations()
    }
    
    private func showKnownDestinations() {
        knownDestinationsButton.isSelected = true
        provideDestinationDataButton.isSelected = false
        
        if destinationContainer.subviews.count > 0 {
            destinationContainer.subviews[0].removeFromSuperview()
        }
        
        if knownInflationDestinationsViewController == nil {
            knownInflationDestinationsViewController = KnownInflationDestinationsViewController(nibName: "KnownInflationDestinationsViewController", bundle: Bundle.main)
            knownInflationDestinationsViewController.currentInflationDestination = currentInflationDestination
        }
        
        if let knownInflationDestinationsViewController = knownInflationDestinationsViewController {
            addChildViewController(knownInflationDestinationsViewController)
            destinationContainer.addSubview(knownInflationDestinationsViewController.view)
            
            knownInflationDestinationsViewController.view.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            knownInflationDestinationsViewController.didMove(toParentViewController: self)
        }
    }
    
    private func showProvideDestinationData() {
        knownDestinationsButton.isSelected = false
        provideDestinationDataButton.isSelected = true
        
        if destinationContainer.subviews.count > 0 {
            destinationContainer.subviews[0].removeFromSuperview()
        }
        
        if provideInflationDestinationViewController == nil {
            provideInflationDestinationViewController = ProvideInflationDestinationViewController(nibName: "ProvideInflationDestinationViewController", bundle: Bundle.main)
            provideInflationDestinationViewController.wallet = wallet
        }
        
        if let provideInflationDestinationViewController = provideInflationDestinationViewController {
            addChildViewController(provideInflationDestinationViewController)
            destinationContainer.addSubview(provideInflationDestinationViewController.view)
            
            provideInflationDestinationViewController.view.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            provideInflationDestinationViewController.didMove(toParentViewController: self)
        }
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.dismiss(animated: true)
    }
    
    @IBAction func didTapHelp(_ sender: Any) {
    }
    
    private func setupNavigationItem() {
        titleView = Bundle.main.loadNibNamed("TitleView", owner:self, options:nil)![0] as! TitleView
        titleView.label.text = "\(wallet.name)\nInflation destination"
        titleView.frame.size = titleView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        
        navigationItem.titleView = titleView
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image:UIImage(named: "arrow-left"), style:.plain, target: self, action: #selector(didTapBack(_:)))
        navigationItem.leftBarButtonItem?.tintColor = Stylesheet.color(.white)
        navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsetsMake(0, 2, 0, -2)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image:UIImage(named: "question"), style:.plain, target: self, action: #selector(didTapHelp(_:)))
        navigationItem.rightBarButtonItem?.tintColor = Stylesheet.color(.white)
        navigationItem.rightBarButtonItem?.imageInsets = UIEdgeInsetsMake(0, 2, 0, -2)
    }
}
