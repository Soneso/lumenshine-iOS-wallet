//
//  KnownInflationDestinationsViewController.swift
//  Lumenshine
//
//  Created by Soneso on 05/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit

fileprivate extension KnownInflationDestinationResponse {
    static var expandedCurrency: Int?
    
    private var getID: Int {
        get {
            return self.id
        }
    }
    
    var isExpanded:Bool {
        get {
            return KnownInflationDestinationResponse.expandedCurrency == self.getID
        }
        set(newValue) {
            if newValue {
                KnownInflationDestinationResponse.expandedCurrency = self.getID
            } else {
                KnownInflationDestinationResponse.expandedCurrency = nil
            }
        }
    }
}

class KnownInflationDestinationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    private var headerViewController: LoadTransactionsHistoryViewController!
    private let CellIdentifier = "KnownInflationDestinationsTableViewCell"
    private var itemsSource: [KnownInflationDestinationResponse] = []
    private var currentExpandedRowIndexPath: IndexPath?
    private let inflationManager = InflationManager()
    
    var currentInflationDestination: String?
    var wallet: FundedWallet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: CellIdentifier, bundle: nil), forCellReuseIdentifier: CellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        setTableViewHeader()
        getKnownInflationDestinations()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        KnownInflationDestinationResponse.expandedCurrency = nil
    }
    
    private func setTableViewHeader() {
        headerViewController = LoadTransactionsHistoryViewController(nibName: "LoadTransactionsHistoryViewController", bundle: Bundle.main, initialState: .showLoading)
        tableView.tableHeaderView = headerViewController.view
    }
    
    private func getKnownInflationDestinations() {
        inflationManager.getKnownInflationDestinations { (response) -> (Void) in
            switch response {
            case .success(response: let knownInflationDestinations):
                self.itemsSource = knownInflationDestinations
                self.tableView.tableHeaderView = nil
                self.tableView.reloadData()
            case .failure(error: let error):
                print("Error: \(error)")
                self.tableView.tableHeaderView = nil
            }
        }
    }
    
    private func showKnownInflationDestinationDetails(for inflationDestination: KnownInflationDestinationResponse) {
        let knownInflationDestinationDetailsViewController = KnownInflationDestinationDetailsViewController(nibName: "KnownInflationDestinationDetailsViewController", bundle: Bundle.main)
        knownInflationDestinationDetailsViewController.knownInflationDestination = inflationDestination
        navigationController?.pushViewController(knownInflationDestinationDetailsViewController, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return itemsSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: KnownInflationDestinationsTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! KnownInflationDestinationsTableViewCell
        
        let knownInflationDestination = itemsSource[indexPath.section]
        
        cell.nameLabel.text = knownInflationDestination.name
        cell.shortDescriptionLabel.text = knownInflationDestination.shortDescription
        cell.issuerPublicKeyLabel.text = "\(knownInflationDestination.issuerPublicKey)"
        
        if knownInflationDestination.issuerPublicKey == currentInflationDestination {
            cell.isCurrentlySetSwitch.isOn = true
        } else {
            cell.isCurrentlySetSwitch.isOn = false
        }
        
        cell.detailsAction = {
            self.showKnownInflationDestinationDetails(for: self.itemsSource[indexPath.section])
        }
        
        if knownInflationDestination.isExpanded {
            cell.expand()
        } else {
            cell.collapse()
        }

        if BiometricHelper.isBiometricAuthEnabled {
            cell.passwordTextField.isHidden = true
        }
        
        cell.wallet = wallet
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemsSource[indexPath.section].isExpanded = !itemsSource[indexPath.section].isExpanded
        
        var rowsThatNeedReload = [indexPath]
        
        if currentExpandedRowIndexPath != indexPath, let previousExpandedRow = currentExpandedRowIndexPath {
            rowsThatNeedReload.append(previousExpandedRow)
        }
        
        currentExpandedRowIndexPath = indexPath
        tableView.reloadRows(at: rowsThatNeedReload, with: UITableViewRowAnimation.fade)
    }
}
