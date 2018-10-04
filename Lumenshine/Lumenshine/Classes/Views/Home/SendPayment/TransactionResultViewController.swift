//
//  TransactionResultViewController.swift
//  Lumenshine
//
//  Created by Soneso on 06/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit
import Material

private enum ButtonsTitles: String {
    case sendOther = "SEND OTHER"
    case print = "PRINT"
    case done = "DONE"
    case edit = "EDIT"
}

private enum StatusLabelText: String {
    case success = "success"
    case error = "error"
}

private var TransactionResultPrintJobName = "Transaction result print data"

class TransactionResultViewController: UIViewController, WalletActionsProtocol {
    @IBOutlet weak var statusValueLabel: UILabel!
    @IBOutlet weak var messageValueLabel: UILabel!
    @IBOutlet weak var currencyValueLabel: UILabel!
    @IBOutlet weak var issuerValueLabel: UILabel!
    @IBOutlet weak var amountValueLabel: UILabel!
    @IBOutlet weak var recipientMailValueLabel: UILabel!
    @IBOutlet weak var recipientPKLabel: UILabel!
    @IBOutlet weak var memoValueLabel: UILabel!
    @IBOutlet weak var memoTypeValueLabel: UILabel!
    @IBOutlet weak var transactionFeeValueLabel: UILabel!
    @IBOutlet weak var operationIDValueLabel: UILabel!
    
    @IBOutlet weak var errorMessageStackView: UIStackView!
    @IBOutlet weak var operationIDStackView: UIStackView!
    @IBOutlet weak var transactionFeeStackView: UIStackView!
    @IBOutlet weak var memoStackView: UIStackView!
    @IBOutlet weak var issuerLabelStackView: UIStackView!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var sendOtherSuccessButton: UIButton!
    @IBOutlet weak var sendOtherErrorButton: UIButton!
    @IBOutlet weak var printButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!

    var wallet: Wallet!
    var result: TransactionResult!
    var closeAction: (() -> ())?
    var sendOtherAction: (() -> ())?
    var closeAllAction: (() -> ())?
    
    private var titleView = TitleView()
    
    @IBAction func editButtonAction(_ sender: UIButton) {
        closeAction?()
    }
    
    @IBAction func sendOtherButtonAction(_ sender: UIButton) {
        sendOtherAction?()
    }
    
    @IBAction func printButtonAction(_ sender: UIButton) {
        print()
    }
    
    @IBAction func doneButtonAction(_ sender: UIButton) {
        closeAllAction?()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch result.status {
        case .error:
            operationIDStackView.isHidden = true
            if result.transactionFee == nil {
                transactionFeeStackView.isHidden = true
            }

            sendOtherSuccessButton.isHidden = true
        case .success:
            errorMessageStackView.isHidden = true
            editButton.isHidden = true
            sendOtherErrorButton.isHidden = true
        }
        
        if result.currency == NativeCurrencyNames.xlm.rawValue {
            issuerLabelStackView.isHidden = true
        }
        
        if result.memo == nil {
            memoStackView.isHidden = true
        }
        
        setupButtons()
        setButtonsTitles()
        setStatusLabel()
        populateValues()
        setupNavigationItem()
    }
    
    private func setStatusLabel() {
        switch result.status {
        case .error:
            statusValueLabel.text = StatusLabelText.error.rawValue
            statusValueLabel.textColor = Stylesheet.color(.red)
            break
        case .success:
            statusValueLabel.text = StatusLabelText.success.rawValue
            statusValueLabel.textColor = Stylesheet.color(.green)
            break
        }
    }
    
    private func setupButtons() {
        editButton.backgroundColor = Stylesheet.color(.blue)
        sendOtherSuccessButton.backgroundColor = Stylesheet.color(.green)
        sendOtherErrorButton.backgroundColor = Stylesheet.color(.green)
        printButton.backgroundColor = Stylesheet.color(.orange)
        doneButton.backgroundColor = Stylesheet.color(.blue)
    }
    
    private func setButtonsTitles() {
        editButton.setTitle(ButtonsTitles.edit.rawValue, for: .normal)
        sendOtherErrorButton.setTitle(ButtonsTitles.sendOther.rawValue, for: .normal)
        sendOtherSuccessButton.setTitle(ButtonsTitles.sendOther.rawValue, for: .normal)
        printButton.setTitle(ButtonsTitles.print.rawValue, for: .normal)
        doneButton.setTitle(ButtonsTitles.done.rawValue, for: .normal)
    }
    
    private func populateValues() {
        messageValueLabel.text = result.message
        currencyValueLabel.text = result.currency
        issuerValueLabel.text = result.issuer
        amountValueLabel.text = "\(result.amount) \(result.currency)"
        recipientMailValueLabel.text = result.recipentMail
        recipientPKLabel.text = result.recipentPK
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
            
            if let issuer = issuerValueLabel.text {
                resultString.append(currency != NativeCurrencyNames.xlm.rawValue && !issuer.isEmpty ? "Issuer: \(issuer)\n" : "")
            }
        }
        
        if let amount = amountValueLabel.text {
            resultString.append("Amount: \(amount)\n")
        }
        
        if let recipientMail = recipientMailValueLabel.text {
            resultString.append("Recipient: \(recipientMail)\n")
        }
        
        if let recipientPK = recipientPKLabel.text {
            resultString.append("\(recipientPK)\n")
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
        navigationItem.titleLabel.text = "Send"
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
    }
}
