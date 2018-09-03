//
//  AddCurrencyViewController.swift
//  Lumenshine
//
//  Created by Soneso on 24/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit

class AddCurrencyViewController: UIViewController {
    @IBOutlet weak var currencyContainer: UIView!
    
    @IBOutlet weak var knownCurrenciesButton: UIButton!
    @IBOutlet weak var provideCurrencyDataButton: UIButton!
    
    var wallet: FoundedWallet!
    
    private var titleView: TitleView!
    private var provideCurrencyDataViewController: ProvideCurrencyDataViewController!
    private var knownCurrenciesTableViewController: KnownCurrenciesTableViewController!
    
    @IBAction func knownCurrenciesAction(_ sender: UIButton) {
        if sender.isSelected {
            return
        }
        
        showKnownCurrencies()
    }
    
    @IBAction func provideCurrencyDataAction(_ sender: UIButton) {
        if sender.isSelected {
            return
        }
        
        showProvideCurrencyData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        showKnownCurrencies()
    }
    
    private func showKnownCurrencies() {
        knownCurrenciesButton.isSelected = true
        provideCurrencyDataButton.isSelected = false

        if currencyContainer.subviews.count > 0 {
            currencyContainer.subviews[0].removeFromSuperview()
        }

        if knownCurrenciesTableViewController == nil {
            knownCurrenciesTableViewController = KnownCurrenciesTableViewController(nibName: "KnownCurrenciesTableViewController", bundle: Bundle.main)
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
        knownCurrenciesButton.isSelected = false
        provideCurrencyDataButton.isSelected = true
        
        if currencyContainer.subviews.count > 0 {
            currencyContainer.subviews[0].removeFromSuperview()
        }
        
        if provideCurrencyDataViewController == nil {
            provideCurrencyDataViewController = ProvideCurrencyDataViewController(nibName: "ProvideCurrencyDataViewController", bundle: Bundle.main)
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
    
    private func clearView() {
        
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.dismiss(animated: true)
    }
    
    @IBAction func didTapHelp(_ sender: Any) {
    }
    
    private func setupNavigationItem() {
        titleView = Bundle.main.loadNibNamed("TitleView", owner:self, options:nil)![0] as! TitleView
        titleView.label.text = wallet?.name
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
