//
//  TransactionHistoryTableViewController.swift
//  Lumenshine
//
//  Created by Soneso on 17/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit

class IntrinsicTableView: UITableView {
    override var contentSize:CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIViewNoIntrinsicMetric, height: contentSize.height)
    }
}

class TransactionHistoryTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    @IBOutlet weak var tableView: UITableView!
    private let CellIdentifier = "TransactionTableViewCell"
    private var itemsSource = [OperationInfo]()
    private var footerViewController: LoadTransactionsHistoryViewController!
    private var headerViewController: LoadTransactionsHistoryViewController!
    private var cursor: String?
    private let transactionHistoryManager = TransactionHistoryManager()
    
    var wallet: Wallet!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: CellIdentifier, bundle: nil), forCellReuseIdentifier: CellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        setTableViewHeader()
        getTransactionsHistory()
    }
    
    private func setTableViewFooter() {
        if footerViewController == nil {
            footerViewController = LoadTransactionsHistoryViewController(nibName: "LoadTransactionsHistoryViewController", bundle: Bundle.main, initialState: .showButton)
            footerViewController.loadTransactionsAction = { [weak self] in
                self?.getTransactionsHistory()
            }
        } else {
            footerViewController?.hideLoadingSign()
            footerViewController?.showButton()
        }
        
        checkIfMoreDataExists { (result) in
            if result {
                self.tableView.tableFooterView = self.footerViewController.view
            } else {
                self.tableView.tableFooterView = nil
            }
        }
    }
    
    private func checkIfMoreDataExists(completion: @escaping (Bool) -> ()) {
        transactionHistoryManager.getTransactionsHistory(forAccount: wallet.publicKey, fromCursor: cursor) { (result) -> (Void) in
            switch result {
            case .success(operations: let operations, cursor: _):
                if operations.count > 0 {
                    completion(true)
                } else {
                    completion(false)
                }
               
            case .failure(error: let error):
                print("Error: \(error)")
                completion(false)
            }
        }
    }
    
    private func setTableViewHeader() {
        headerViewController = LoadTransactionsHistoryViewController(nibName: "LoadTransactionsHistoryViewController", bundle: Bundle.main, initialState: .showLoading)
        tableView.tableHeaderView = headerViewController.view
    }
    
    private func getTransactionsHistory() {
        transactionHistoryManager.getTransactionsHistory(forAccount: wallet.publicKey, fromCursor: cursor) { (result) -> (Void) in
            switch result {
            case .success(operations: let operations, cursor: let cursor):
                if let cursor = cursor {
                    self.cursor = cursor
                }
                
                self.itemsSource.append(contentsOf: operations)
                self.headerViewController.hideLoadingSign()
                self.headerViewController.showTitle()
                self.tableView.reloadData()
                self.setTableViewFooter()
                
                break
            case .failure(error: let error):
                print("Error: \(error)")
                self.headerViewController.hideLoadingSign()
                self.headerViewController.showTitle()
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
        let cell: TransactionTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! TransactionTableViewCell
        cell.operationInfo = itemsSource[indexPath.section]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let currentCell = cell as? TransactionTableViewCell {
            currentCell.updateAmountLabel()
        }
    }
}


