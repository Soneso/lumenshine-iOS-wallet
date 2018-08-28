//
//  TransactionHistoryTableViewController.swift
//  Lumenshine
//
//  Created by Soneso on 17/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit
import stellarsdk

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
    private var operations: [OperationResponse]!
    private var footerViewController: LoadTransactionsHistoryViewController!
    private var headerViewController: LoadTransactionsHistoryViewController!
    private var cursor: String?
    private var stellarSdk: StellarSDK {
        get {
            return Services.shared.stellarSdk
        }
    }
    
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
        guard self.footerViewController == nil else {
            self.footerViewController.hideLoadingSign()
            self.footerViewController.showButton()
            return
        }
        
        footerViewController = LoadTransactionsHistoryViewController(nibName: "LoadTransactionsHistoryViewController", bundle: Bundle.main, initialState: .showButton)
        footerViewController.loadTransactionsAction = { [weak self] in
            self?.getTransactionsHistory()
        }
        
        tableView.tableFooterView = footerViewController.view
    }
    
    private func setTableViewHeader() {
        headerViewController = LoadTransactionsHistoryViewController(nibName: "LoadTransactionsHistoryViewController", bundle: Bundle.main, initialState: .showLoading)
        tableView.tableHeaderView = headerViewController.view
    }
    
    private func getTransactionsHistory() {
        operations = [OperationResponse]()
        let semaphore = DispatchSemaphore(value: 0)
        
        DispatchQueue.global().async {
            self.stellarSdk.payments.getPayments(forAccount: self.wallet.publicKey, from: self.cursor, order: Order.descending) { (response) -> (Void) in
                switch response {
                case .success(details: let details):
                    self.operations = details.records
                    if let pagingToken = details.records.last?.pagingToken {
                        self.cursor = pagingToken
                    }
                    semaphore.signal()
                    break
                    
                case .failure(error: let error):
                    print("Error: \(error)")
                    semaphore.signal()
                    break
                }
            }
            
            semaphore.wait()
            self.fillTableViewData()
        }
    }
    
    private func fillTableViewData() {
        DispatchQueue.global().async {
            for record in self.operations {
                let operation: OperationInfo = OperationInfo()
                operation.operationID = record.id
                operation.operationType = record.operationTypeString
                operation.date = record.createdAt
                
                switch record.operationType {
                case .accountCreated:
                    // AccountCreatedOperationResponse
                    if let accountCreatedOperation = record as? AccountCreatedOperationResponse {
                        operation.amount = "\(accountCreatedOperation.startingBalance)"
                        operation.assetCode = NativeCurrencyNames.xlm.rawValue
                        operation.sign = accountCreatedOperation.sourceAccount == self.wallet.publicKey ? SignEnum.minus : SignEnum.plus
                    }
                    
                    break
                    
                case .accountMerge:
                    // AccountMergeOperationResponse
                    if let _ = record as? AccountMergeOperationResponse {
                        operation.amount = "0"
                        operation.assetCode = NativeCurrencyNames.xlm.rawValue
                        operation.sign = SignEnum.plus
                    }
                    
                    break
                    
                case .allowTrust:
                    // AllowTrustOperationResponse
                    if let allowTrustOperationResponse = record as? AllowTrustOperationResponse {
                        operation.amount = "0"
                        operation.assetCode = allowTrustOperationResponse.assetCode ?? NativeCurrencyNames.xlm.rawValue
                        operation.sign = SignEnum.plus
                    }
                    
                    break
                    
                case .changeTrust:
                    // ChangeTrustOperationResponse
                    if let changeTrustOperationResponse = record as? ChangeTrustOperationResponse {
                        operation.amount = "0"
                        operation.assetCode = changeTrustOperationResponse.assetCode ?? NativeCurrencyNames.xlm.rawValue
                        operation.sign = SignEnum.plus
                    }
                    
                    break
                    
                case .createPassiveOffer:
                    // CreatePassiveOfferOperationResponse
                    if let createPassiveOfferOperationResponse = record as? CreatePassiveOfferOperationResponse {
                        operation.amount = createPassiveOfferOperationResponse.amount
                        operation.assetCode = createPassiveOfferOperationResponse.sellingAssetCode
                        operation.sign = record.sourceAccount == self.wallet.publicKey ? SignEnum.minus : SignEnum.plus
                    }
                    
                    break
                    
                case .inflation:
                    // InflationOperationResponse
                    if let _ = record as? InflationOperationResponse {
                        operation.amount = "0"
                        operation.assetCode = NativeCurrencyNames.xlm.rawValue
                        operation.sign = SignEnum.plus
                    }
                    
                    break
                    
                case .manageData:
                    // ManageDataOperationResponse
                    if let manageDataOperationResponse = record as? ManageDataOperationResponse {
                        operation.amount = manageDataOperationResponse.value
                        operation.assetCode = NativeCurrencyNames.xlm.rawValue
                        operation.sign = SignEnum.plus
                    }
                    
                    break
                    
                case .manageOffer:
                    // ManageOfferOperationResponse
                    if let manageOffferOperationResponse = record as? ManageOfferOperationResponse {
                        operation.amount = manageOffferOperationResponse.amount
                        operation.assetCode = manageOffferOperationResponse.sellingAssetCode
                        operation.sign = SignEnum.minus
                    }
                    
                    break
                    
                case .pathPayment:
                    // PathPaymentOperationResponse
                    if let pathPaymentOperationResponse = record as? PathPaymentOperationResponse {
                        operation.amount = pathPaymentOperationResponse.amount
                        operation.assetCode = pathPaymentOperationResponse.assetCode ?? NativeCurrencyNames.xlm.rawValue
                        operation.sign = pathPaymentOperationResponse.from == self.wallet.publicKey ? SignEnum.minus : SignEnum.plus
                    }
                    
                    break
                    
                case .payment:
                    // PaymentOperationResponse
                    if let paymentOperation = record as? PaymentOperationResponse {
                        operation.amount = paymentOperation.amount
                        operation.assetCode = paymentOperation.assetCode ?? NativeCurrencyNames.xlm.rawValue
                        operation.sign = paymentOperation.to == self.wallet.publicKey ? SignEnum.plus : SignEnum.minus
                    }
                    
                    break
                case .setOptions:
                    // SetOptionsOperationResponse
                    if let setOptionsOperation = record as? SetOptionsOperationResponse {
                        operation.amount = "\(setOptionsOperation.lowThreshold ?? 0)"
                        operation.assetCode = NativeCurrencyNames.xlm.rawValue
                        operation.sign = SignEnum.minus
                    }
                    
                    break
                }
                
                let memoSemaphore = DispatchSemaphore(value: 0)
                self.stellarSdk.transactions.getTransactionDetails(transactionHash: record.transactionHash, response: { (response) -> (Void) in
                    switch response {
                    case .success(details: let transaction):
                        switch transaction.memo! {
                        case .text(let text):
                            operation.memo = text
                            break
                        case .id(let id):
                            operation.memo = String(id)
                            break
                        case .hash(let data):
                            operation.memo = data.toHexString()
                            break
                        case .returnHash(let data):
                            operation.memo = data.toHexString()
                            break
                        case .none:
                            break
                        }
                        
                        memoSemaphore.signal()
                        break
                        
                    case .failure(error: let error):
                        print("Error: \(error)")
                        memoSemaphore.signal()
                        break
                    }
                })
                
                memoSemaphore.wait()
                self.itemsSource.append(operation)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.headerViewController.hideLoadingSign()
                self.headerViewController.showTitle()
                self.setTableViewFooter()
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


