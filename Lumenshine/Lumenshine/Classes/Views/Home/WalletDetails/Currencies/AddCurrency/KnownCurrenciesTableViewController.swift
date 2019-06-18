//
//  KnownCurrenciesTableViewController.swift
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

fileprivate extension KnownCurrency {
    static var expandedCurrency: String = ""
    
    private var getID: String {
        get {
            return self.assetCode + self.issuerPublicKey
        }
    }
    
    var isExpanded:Bool {
        get {
            return KnownCurrency.expandedCurrency == self.getID
        }
        set(newValue) {
            if newValue {
            KnownCurrency.expandedCurrency = self.getID
            } else {
                KnownCurrency.expandedCurrency = ""
            }
        }
    }
}

class KnownCurrenciesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    private let CellIdentifier = "KnownCurrenciesTableViewCell"
    private let userManager = UserManager()
    private var headerViewController: LoadTransactionsHistoryViewController!
    private var itemsSource: [KnownCurrency] = []
    private var knownCurrenciesManager = KnownCurrenciesManager()
    private var currentExpandedRowIndexPath: IndexPath?
    private var canWalletSign = true

    var wallet: FundedWallet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: CellIdentifier, bundle: nil), forCellReuseIdentifier: CellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        setTableViewHeader()

        userManager.canSignerSignOperation(accountID: wallet.publicKey, signerPublicKey: wallet.publicKey, neededSecurity: .medium) { (response) -> (Void) in
            switch response {
            case .success(canSign: let canSign):
                self.canWalletSign = canSign
            case .failure(error: let error):
                print(error.localizedDescription)
            }
            
            self.getKnownCurrencies()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        KnownCurrency.expandedCurrency = ""
    }
    
    private func setTableViewHeader() {
        headerViewController = LoadTransactionsHistoryViewController(nibName: "LoadTransactionsHistoryViewController", bundle: Bundle.main, initialState: .showLoading)
        tableView.tableHeaderView = headerViewController.view
    }
    
    private func getKnownCurrencies() {
        knownCurrenciesManager.getKnownCurrencies { (response) -> (Void) in
            switch response {
            case .success(response: let knownCurrencies):
                self.itemsSource = knownCurrencies
                self.tableView.tableHeaderView = nil
                self.tableView.reloadData()
            case .failure(error: let error):
                print("Error: \(error)")
                self.tableView.tableHeaderView = nil
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return itemsSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: KnownCurrenciesTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! KnownCurrenciesTableViewCell
        
        let knownCurrency = itemsSource[indexPath.section]
        
        if let currencyName = knownCurrency.name, let currencyAssetCode = knownCurrency.assetCode {
            cell.assetCodeLabel.text = "\(currencyName) (\(currencyAssetCode))"
        }

        cell.authorizationView.isHidden = knownCurrency.isAuthorized ?? true
        
        if let issuer = knownCurrency.issuerPublicKey {
            cell.issuerPublicKeyLabel.text = "\(issuer)"
        }

        cell.cellIndexPath = indexPath
        cell.selectionStyle = .none
        cell.canWalletSign = canWalletSign
        cell.wallet = wallet
        
        if knownCurrency.isExpanded {
            cell.expand()
        } else {
            cell.collapse()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemsSource[indexPath.section].isExpanded = !itemsSource[indexPath.section].isExpanded
        
        var rowsThatNeedReload = [indexPath]
        
        if currentExpandedRowIndexPath != indexPath, let previousExpandedRow = currentExpandedRowIndexPath {
            rowsThatNeedReload.append(previousExpandedRow)
        }
        
        currentExpandedRowIndexPath = indexPath
        tableView.reloadRows(at: rowsThatNeedReload, with: UITableView.RowAnimation.fade)
    }
}
