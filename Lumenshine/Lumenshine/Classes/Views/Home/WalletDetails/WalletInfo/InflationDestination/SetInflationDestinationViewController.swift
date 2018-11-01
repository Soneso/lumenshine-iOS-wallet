//
//  SetInflationDestinationViewController.swift
//  Lumenshine
//
//  Created by Soneso on 05/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit
import Material

fileprivate enum SegmentedControlIndexes: Int {
    case knownDestinations = 0
    case provideDestinationData = 1
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
    var reloadDelegate: ReloadDelegate?
    
    private var titleView: TitleView!
    private var provideInflationDestinationViewController: ProvideInflationDestinationViewController!
    private var knownInflationDestinationsViewController: KnownInflationDestinationsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupSegmentedContent()
        showKnownDestinations()
        view.backgroundColor = Stylesheet.color(.veryLightGray)
    }
    
    private func setupSegmentedContent() {
        knownInflationDestinationsViewController = KnownInflationDestinationsViewController(nibName: "KnownInflationDestinationsViewController", bundle: Bundle.main)
        knownInflationDestinationsViewController.currentInflationDestination = currentInflationDestination
        knownInflationDestinationsViewController.wallet = wallet
        knownInflationDestinationsViewController.reloadDelegate = reloadDelegate
        
        provideInflationDestinationViewController = ProvideInflationDestinationViewController(nibName: "ProvideInflationDestinationViewController", bundle: Bundle.main)
        provideInflationDestinationViewController.wallet = wallet
        provideInflationDestinationViewController.reloadDelegate = reloadDelegate
    }
    
    private func showKnownDestinations() {
        if destinationContainer.subviews.count > 0 {
            destinationContainer.subviews[0].removeFromSuperview()
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
        if destinationContainer.subviews.count > 0 {
            destinationContainer.subviews[0].removeFromSuperview()
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
    
    @IBAction func didTapHelp(_ sender: Any) {
    }
    
    private func setupNavigationItem() {
        navigationItem.titleLabel.text = "Set inflation destination"
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        
        let helpButton = Material.IconButton()
        helpButton.image = R.image.question()?.crop(toWidth: 15, toHeight: 15)?.tint(with: Stylesheet.color(.white))
        helpButton.addTarget(self, action: #selector(didTapHelp(_:)), for: .touchUpInside)
        navigationItem.rightViews = [helpButton]
    }
}
