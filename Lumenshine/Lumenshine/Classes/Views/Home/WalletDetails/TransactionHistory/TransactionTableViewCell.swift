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
        if operationInfo.responseData == nil {
            self.viewContainingController()?.showActivity()
            let requestUrl = Services.shared.horizonURL + "/operations/" + operationInfo.operationID
            Services.shared.walletService.GETRequestFromUrl(url: requestUrl) { (result) -> (Void) in
                DispatchQueue.main.async {
                    self.viewContainingController()?.hideActivity(completion: {
                        switch result {
                        case .success (let data):
                            self.operationInfo.responseData = data
                            self.showDetails()
                        case .failure(_):
                            self.viewContainingController()?.displaySimpleAlertView(title: R.string.localizable.error(), message: R.string.localizable.operation_details_load_error())
                        }
                    })
                }
            }
        } else {
            showDetails()
        }
    }
    
    private func showDetails() {
        let transactionDetailsViewController = TransactionHistoryDetailsTableViewController(operationInfo: operationInfo)
        self.viewContainingController()?.navigationController?.pushViewController(transactionDetailsViewController, animated: true)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = Stylesheet.color(.veryLightGray)
    }
    
    func updateAmountLabel() {
        if let text = amountValueLabel.text, let amount = CoinUnit(text), let asset = operationInfo.assetCode {
            let assetCode = NSMutableAttributedString(string: asset, attributes: [ NSAttributedStringKey.foregroundColor: Stylesheet.color(.gray) ])
            var amountValue = NSMutableAttributedString()
            
            if operationInfo.sign == .plus {
                amountValue = NSMutableAttributedString(string: "\(amount) ", attributes: [ NSAttributedStringKey.foregroundColor: Stylesheet.color(.green) ])
            } else {
                amountValue = NSMutableAttributedString(string: "- \(amount) ", attributes: [ NSAttributedStringKey.foregroundColor: Stylesheet.color(.red) ])
            }
            
            amountValue.append(assetCode)
            amountValueLabel.attributedText = amountValue
        }
    }
}
