//
//  TransactionTableViewCell.swift
//  Lumenshine
//
//  Created by Soneso on 20/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit

class TransactionTableViewCell: UITableViewCell {
    @IBOutlet weak var dateValueLabel: UILabel!
    @IBOutlet weak var amountValueLabel: UILabel!
    @IBOutlet weak var memoValueLabel: UILabel!
    @IBOutlet weak var operationTypeValueLabel: UILabel!
    @IBOutlet weak var operationIDValue: UILabel!
    
    private let defaultAmountValueLabel = "amountLabel"
    
    var operationInfo: OperationInfo! {
        didSet {
            amountValueLabel?.text = operationInfo.amount
            let dateformatter = DateFormatter()
            dateformatter.dateStyle = DateFormatter.Style.short
            dateformatter.timeStyle = DateFormatter.Style.short
            let date = dateformatter.string(from: operationInfo.date)
            dateValueLabel?.text = date
            memoValueLabel?.text = operationInfo.memo
            operationIDValue?.text = operationInfo.operationID
            operationTypeValueLabel?.text = operationInfo.operationType
        }
    }
    
    @IBAction func detailsButtonAction(_ sender: UIButton) {
        let transactionDetailsViewController = TransactionHistoryDetailsViewController(nibName: "TransactionHistoryDetailsViewController", bundle: Bundle.main)
        transactionDetailsViewController.operationInfo = operationInfo
        let navigationController = BaseNavigationViewController(rootViewController: transactionDetailsViewController)
        parentContainerViewController()?.present(navigationController, animated: true)
    }
    
    func updateAmountLabel() {
        if let text = amountValueLabel.text, let amount = CoinUnit(text), let asset = operationInfo.assetCode {
            if operationInfo.sign == .plus {
                amountValueLabel.text = "+ \(amount) \(asset)"
                amountValueLabel.textColor = UIColor.green
            } else {
                amountValueLabel.text = "- \(amount) \(asset)"
                amountValueLabel.textColor = UIColor.red
            }
        }
    }
}
