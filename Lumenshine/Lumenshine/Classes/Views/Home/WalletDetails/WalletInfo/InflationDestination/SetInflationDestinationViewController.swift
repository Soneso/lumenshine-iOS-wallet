//
//  SetInflationDestinationViewController.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit
import Material

fileprivate enum SegmentedControlIndexes: Int {
    case provideDestinationData = 0
    case knownDestinations = 1
}

class SetInflationDestinationViewController: UIViewController {
    @IBOutlet weak var destinationContainer: UIView!
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == SegmentedControlIndexes.knownDestinations.rawValue {
            showKnownDestinations()
        } else {
            showProvideDestinationData()
        }
    }
    
    var wallet: FundedWallet!
    var currentInflationDestination: String?
    
    private var titleView: TitleView!
    private var provideInflationDestinationViewController: ProvideInflationDestinationViewController!
    private var knownInflationDestinationsViewController: KnownInflationDestinationsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupSegmentedContent()
        showProvideDestinationData()
        view.backgroundColor = Stylesheet.color(.veryLightGray)
    }
    
    private func setupSegmentedContent() {
        knownInflationDestinationsViewController = KnownInflationDestinationsViewController(nibName: "KnownInflationDestinationsViewController", bundle: Bundle.main)
        knownInflationDestinationsViewController.currentInflationDestination = currentInflationDestination
        knownInflationDestinationsViewController.wallet = wallet
        
        provideInflationDestinationViewController = ProvideInflationDestinationViewController(nibName: "ProvideInflationDestinationViewController", bundle: Bundle.main)
        provideInflationDestinationViewController.wallet = wallet
    }
    
    private func showKnownDestinations() {
        if destinationContainer.subviews.count > 0 {
            destinationContainer.subviews[0].removeFromSuperview()
        }
        
        if let knownInflationDestinationsViewController = knownInflationDestinationsViewController {
            addChild(knownInflationDestinationsViewController)
            destinationContainer.addSubview(knownInflationDestinationsViewController.view)
            
            knownInflationDestinationsViewController.view.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            knownInflationDestinationsViewController.didMove(toParent: self)
        }
    }
    
    private func showProvideDestinationData() {
        if destinationContainer.subviews.count > 0 {
            destinationContainer.subviews[0].removeFromSuperview()
        }
        
        if let provideInflationDestinationViewController = provideInflationDestinationViewController {
            addChild(provideInflationDestinationViewController)
            destinationContainer.addSubview(provideInflationDestinationViewController.view)
            
            provideInflationDestinationViewController.view.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            provideInflationDestinationViewController.didMove(toParent: self)
        }
    }
    
    @IBAction func didTapHelp(_ sender: Any) {
    }
    
    private func setupNavigationItem() {
        navigationItem.titleLabel.text = R.string.localizable.inflation_destination()
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        
    }
}
