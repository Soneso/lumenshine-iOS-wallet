//
//  AddCurrencyViewController.swift
//  Lumenshine
//
//  Created by Soneso on 24/08/2018.
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
    var reloadDelegate: ReloadDelegate?

    @IBOutlet weak var currencyContainer: UIView!
    
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
        showKnownCurrencies()
        view.backgroundColor = Stylesheet.color(.veryLightGray)
    }
    
    private func setupSegmentedContent() {
        knownCurrenciesTableViewController = KnownCurrenciesTableViewController(nibName: "KnownCurrenciesTableViewController", bundle: Bundle.main)
        knownCurrenciesTableViewController.wallet = wallet
        knownCurrenciesTableViewController.reloadDelegate = reloadDelegate
        
        provideCurrencyDataViewController = ProvideCurrencyDataViewController(nibName: "ProvideCurrencyDataViewController", bundle: Bundle.main)
        provideCurrencyDataViewController.reloadDelegate = reloadDelegate
    }
    
    private func showKnownCurrencies() {
        if currencyContainer.subviews.count > 0 {
            currencyContainer.subviews[0].removeFromSuperview()
        }

        if let knownCurrenciesTableViewController = knownCurrenciesTableViewController {
            addChildViewController(knownCurrenciesTableViewController)
            currencyContainer.addSubview(knownCurrenciesTableViewController.view)

            knownCurrenciesTableViewController.view.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }

            knownCurrenciesTableViewController.didMove(toParentViewController: self)
        }
    }
    
    private func showProvideCurrencyData() {
        if currencyContainer.subviews.count > 0 {
            currencyContainer.subviews[0].removeFromSuperview()
        }
        
        if let provideCurrencyDataViewController = provideCurrencyDataViewController {
            provideCurrencyDataViewController.wallet = wallet
            addChildViewController(provideCurrencyDataViewController)
            currencyContainer.addSubview(provideCurrencyDataViewController.view)
            
            provideCurrencyDataViewController.view.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            provideCurrencyDataViewController.didMove(toParentViewController: self)
        }
    }
        
    @IBAction func didTapHelp(_ sender: Any) {
    }
    
    private func setupNavigationItem() {        
        navigationItem.titleLabel.text = "Add currency"
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        
        let helpButton = Material.IconButton()
        helpButton.image = R.image.question()?.crop(toWidth: 15, toHeight: 15)?.tint(with: Stylesheet.color(.white))
        helpButton.addTarget(self, action: #selector(didTapHelp(_:)), for: .touchUpInside)
        navigationItem.rightViews = [helpButton]
    }
}
