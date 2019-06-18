//
//  AddCurrencyViewController.swift
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

fileprivate enum SegmentendControlIndexes: Int {
    case knownCurrencies = 0
    case provideCurrencyData = 1
}

class AddCurrencyViewController: UIViewController {
    private var titleView: TitleView!
    private var provideCurrencyDataViewController: ProvideCurrencyDataViewController!
    private var knownCurrenciesTableViewController: KnownCurrenciesTableViewController!
    
    var wallet: FundedWallet!

    @IBOutlet weak var currencyContainer: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == SegmentendControlIndexes.knownCurrencies.rawValue {
            showKnownCurrencies()
        } else {
            showProvideCurrencyData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupSegmentedContent()

        segmentedControl.removeFromSuperview()
        currencyContainer.snp.makeConstraints { (make) in
            make.top.equalTo(16)
        }
        
        //showKnownCurrencies()
        showProvideCurrencyData()
        view.backgroundColor = Stylesheet.color(.veryLightGray)
    }
    
    private func setupSegmentedContent() {
        knownCurrenciesTableViewController = KnownCurrenciesTableViewController(nibName: "KnownCurrenciesTableViewController", bundle: Bundle.main)
        knownCurrenciesTableViewController.wallet = wallet
        
        provideCurrencyDataViewController = ProvideCurrencyDataViewController(nibName: "ProvideCurrencyDataViewController", bundle: Bundle.main)
    }
    
    private func showKnownCurrencies() {
        if currencyContainer.subviews.count > 0 {
            currencyContainer.subviews[0].removeFromSuperview()
        }

        if let knownCurrenciesTableViewController = knownCurrenciesTableViewController {
            addChild(knownCurrenciesTableViewController)
            currencyContainer.addSubview(knownCurrenciesTableViewController.view)

            knownCurrenciesTableViewController.view.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }

            knownCurrenciesTableViewController.didMove(toParent: self)
        }
    }
    
    private func showProvideCurrencyData() {
        if currencyContainer.subviews.count > 0 {
            currencyContainer.subviews[0].removeFromSuperview()
        }
        
        if let provideCurrencyDataViewController = provideCurrencyDataViewController {
            provideCurrencyDataViewController.wallet = wallet
            addChild(provideCurrencyDataViewController)
            currencyContainer.addSubview(provideCurrencyDataViewController.view)
            
            provideCurrencyDataViewController.view.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            provideCurrencyDataViewController.didMove(toParent: self)
        }
    }
        
    @IBAction func didTapHelp(_ sender: Any) {
    }
    
    private func setupNavigationItem() {        
        navigationItem.titleLabel.text = "Add currency"
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
    }
}
