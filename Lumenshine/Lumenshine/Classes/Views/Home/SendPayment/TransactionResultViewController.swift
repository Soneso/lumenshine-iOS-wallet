//
//  TransactionResultViewController.swift
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
import Material

private enum ButtonsTitles: String {
    case print = "PRINT"
    case done = "DONE"
}

private enum StatusLabelText: String {
    case success = "success"
    case error = "error"
}

private var TransactionResultPrintJobName = "Transaction result print data"

class TransactionResultViewController: UIViewController, WalletActionsProtocol, OperationIDValueChangedDelegate {

    @IBOutlet weak var statusValueLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageValueLabel: UILabel!
    @IBOutlet weak var recepientPK: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var currencyValueLabel: UILabel!
    @IBOutlet weak var issuerLabel: UILabel!
    @IBOutlet weak var issuerValueLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var amountValueLabel: UILabel!
    @IBOutlet weak var recepientLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var memoValueLabel: UILabel!
    @IBOutlet weak var memoTypeLabel: UILabel!
    @IBOutlet weak var memoTypeValueLabel: UILabel!
    @IBOutlet weak var transactionFeeLabel: UILabel!
    @IBOutlet weak var transactionFeeValueLabel: UILabel!
    @IBOutlet weak var operationIDLabel: UILabel!
    @IBOutlet weak var operationIDValueLabel: UILabel!
    
    @IBOutlet weak var errorMessageStackView: UIStackView!
    @IBOutlet weak var operationIDStackView: UIStackView!
    @IBOutlet weak var transactionFeeStackView: UIStackView!
    @IBOutlet weak var memoStackView: UIStackView!
    @IBOutlet weak var issuerLabelStackView: UIStackView!
    
    @IBOutlet weak var printButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!

    var walletsList: [Wallet]! {
        didSet {
            wallet = walletsList.first
        }
    }
    
    var wallet: Wallet!
    var result: TransactionResult!
    var closeAction: (() -> ())?
    var closeAllAction: (() -> ())?
    
    private var titleView = TitleView()
    
    @IBAction func printButtonAction(_ sender: UIButton) {
        print()
    }
    
    @IBAction func doneButtonAction(_ sender: UIButton) {
        closeAllAction?()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideActivity()
        switch result.status {
        case .error:
            operationIDStackView.isHidden = true
            if result.transactionFee == nil {
                transactionFeeStackView.isHidden = true
            }
        case .success:
            errorMessageStackView.isHidden = true
        }
        
        if result.currency == NativeCurrencyNames.xlm.rawValue {
            issuerLabelStackView.isHidden = true
            currencyLabel.isHidden = true
            currencyValueLabel.isHidden = true
        }
        
        if result.memo == nil {
            memoStackView.isHidden = true
        }
        
        setLabelsLayout()
        setupButtons()
        setButtonsTitles()
        populateValues()
        setupNavigationItem()
        result.operationIDChangedDelegate = self
    }
    
    func operationIDChanged(newValue: String?) {
        operationIDValueLabel.text = newValue
    }
    
    private func setLabelsLayout() {
        
        let labelColor = Stylesheet.color(.lightBlack)
        let labelFont = R.font.encodeSansSemiBold(size: 15)
        let valueLabelFont = R.font.encodeSansRegular(size: 15)
        
        // Status label & value
        statusValueLabel.font = R.font.encodeSansSemiBold(size: 17)
        
        switch result.status {
        case .error:
            statusValueLabel.text = StatusLabelText.error.rawValue.uppercased()
            statusValueLabel.textColor = Stylesheet.color(.red)
            break
        case .success:
            statusValueLabel.text = StatusLabelText.success.rawValue.uppercased()
            statusValueLabel.textColor = Stylesheet.color(.green)
            break
        }
        
        // Message label
        messageLabel.textColor = labelColor
        messageLabel.font = labelFont
        messageValueLabel.numberOfLines = 0
        messageValueLabel.font = valueLabelFont
        
        // Currency label
        currencyLabel.textColor = labelColor
        currencyLabel.font = labelFont
        currencyValueLabel.font = valueLabelFont
        
        // Issuer label
        issuerLabel.textColor = labelColor
        issuerLabel.font = labelFont
        issuerValueLabel.font = valueLabelFont
        
        // Amount label
        amountLabel.textColor = labelColor
        amountLabel.font = labelFont
        amountValueLabel.textColor = labelColor
        amountValueLabel.font = labelFont
        
        // Recepient label
        recepientLabel.textColor = labelColor
        recepientLabel.font = labelFont
        recepientPK.font = valueLabelFont
        
        // Memo label
        memoLabel.textColor = labelColor
        memoLabel.font = labelFont
        memoValueLabel.font = valueLabelFont
        
        // Memotype label
        memoTypeLabel.textColor = labelColor
        memoTypeLabel.font = labelFont
        memoTypeValueLabel.font = valueLabelFont
        
        // Operation ID label
        operationIDLabel.textColor = labelColor
        operationIDLabel.font = labelFont
        operationIDValueLabel.font = valueLabelFont
        
        // Transaction fee label
        transactionFeeLabel.textColor = labelColor
        transactionFeeLabel.font = labelFont
        transactionFeeValueLabel.font = valueLabelFont
        
    }
    
    private func setupButtons() {
        
        let buttonFont = R.font.encodeSansSemiBold(size: 15)
    
        printButton.backgroundColor = Stylesheet.color(.orange)
        printButton.titleLabel?.font = buttonFont
        
        doneButton.backgroundColor = Stylesheet.color(.blue)
        doneButton.titleLabel?.font = buttonFont
        
    }
    
    private func setButtonsTitles() {
        printButton.setTitle(ButtonsTitles.print.rawValue.uppercased(), for: .normal)
        doneButton.setTitle(ButtonsTitles.done.rawValue.uppercased(), for: .normal)
    }
    
    private func populateValues() {
        messageValueLabel.text = result.message
        currencyValueLabel.text = result.currency
        if let issuer = result.issuer, !issuer.isEmpty, issuer.trimmed != "" {
            issuerValueLabel.text = result.issuer
        } else if result.currency != NativeCurrencyNames.xlm.rawValue {
            issuerValueLabel.text = wallet.publicKey // own asset sent
        }
        
        amountValueLabel.text = "\(result.amount) \(result.currency)"
        recepientPK.text = result.recipentPK
        memoValueLabel.text = result.memo
        memoTypeValueLabel.text = result.memoType.rawValue
        transactionFeeValueLabel.text = "\(result.transactionFee ?? "") \(NativeCurrencyNames.xlm.rawValue)"
        operationIDValueLabel.text = result.operationID
    }
    
    private func getPrintingText() -> String {
        var resultString: String = ""
        
        if let status = statusValueLabel.text {
            resultString.append("Status: \(status)\n")
        }
        
        if let message = messageValueLabel.text {
            resultString.append(message.isEmpty == false ? "Message: \(message)\n" : "")
        }
        
        if let currency = currencyValueLabel.text {
            resultString.append("Currency \(currency)\n")
            
            if currency != NativeCurrencyNames.xlm.rawValue {
                if let issuer = issuerValueLabel.text, !issuer.isEmpty {
                    resultString.append("Issuer: \(issuer)\n")
                } else {
                    resultString.append("Issuer: \(wallet.publicKey)\n") // own asset send
                }
            }
        }
        
        if let amount = amountValueLabel.text {
            resultString.append("Amount: \(amount)\n")
        }
        
        if let recepientPublicKey = recepientPK.text {
            resultString.append("Recipient: \(recepientPublicKey)\n")
        }
        
        if let memo = memoValueLabel.text {
            resultString.append(!memo.isEmpty ? "Memo: \(memo)\n" : "")
            
            if let memoType = memoTypeValueLabel.text {
                resultString.append(!memo.isEmpty && !memoType.isEmpty ? "Memo type: \(memoType)\n" : "")
            }
        }
        
        if let operationID = operationIDValueLabel.text {
            resultString.append(!operationID.isEmpty ? "Operation ID: \(operationID)\n" : "")
        }
        
        if let transactionFee = transactionFeeValueLabel.text {
            resultString.append(!transactionFee.isEmpty ? "Transaction fee: \(transactionFee)" : "")
        }
        
        return resultString
    }
    
    private func print() {
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = UIPrintInfoOutputType.general
        printInfo.jobName = TransactionResultPrintJobName
        
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.printingItem = getPrintingItem()
        printController.present(from: self.view.frame, in: self.view, animated: true, completionHandler: nil)
    }
    
    private func getPrintingItem() -> UIImage? {
        let bounds = UIScreen.main.bounds
        let view = Bundle.main.loadNibNamed("TransactionResultPrintView", owner: nil, options: nil)![0] as! TransactionResultPrintView
        view.frame = CGRect(x: 9999, y: 9999, width: bounds.width, height: bounds.height)
        view.contentsLabel.text = getPrintingText()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.addSubview(view)
        let image = view.toImage()
        view.removeFromSuperview()
        
        return image
    }
    
    private func setupNavigationItem() {
        navigationItem.titleLabel.text = "Transaction result"
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
    }
}
