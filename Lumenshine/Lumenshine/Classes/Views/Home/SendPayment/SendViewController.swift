//
//  SendViewController.swift
//  Lumenshine
//
//  Created by Soneso on 02/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit
import stellarsdk
import Material

enum ValidationErrors: String {
    case Mandatory = "Mandatory"
    case InvalidAddress = "Invalid public key or address"
    case InvalidMemo = "Invalid memo"
    case MemoLength = "Memo is too long"
    case InsufficientLumens = "Insufficient XLM for transaction fee available"
    case RecipientAccount = "Warning: Recipient account does not exist or is not funded"
    case CurrencyNoTrust = "Recipient can not receive selected currency"
    case AddressNotFound = "Address not found"
    case InvalidPassword = "Invalid password"
    case MandatoryPassword = "Password required"
}

enum MemoTypeValues: String {
    case MEMO_TEXT = "MEMO_TEXT"
    case MEMO_ID = "MEMO_ID"
    case MEMO_HASH = "MEMO_HASH"
    case MEMO_RETURN = "MEMO_RETURN"
}

enum MemoTextFieldPlaceholders: String {
    case MemoText = "Up to 28 characters"
    case MemoID = "Enter memo ID number"
    case MemoHash, MemoReturn = "Enter 64 characters encoded string"
}

enum NativeCurrencyNames: String {
    case xlm = "XLM"
    case stellarLumens = "Stellar Lumens (XLM)"
}

enum SendButtonTitles: String {
    case sendAnyway = "Send anyway"
    case validating = "Validating and sending"
}

enum AmountSegmentedControlIndexes: Int {
    case sendAmount = 0
    case sendAll = 1
}

public let MaximumLengthInBytesForMemoText = 28
public let QRCodeSeparationString = " "
public let QRCodeNativeCurrencyIssuer = "native"

class SendViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, WalletActionsProtocol, ScanViewControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var currentCurrencyLabel: UILabel!
    @IBOutlet weak var addressErrorLabel: UILabel!
    @IBOutlet weak var amountErrorLabel: UILabel!
    @IBOutlet weak var memoInputErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var sendErrorLabel: UILabel!
    @IBOutlet weak var availableAmountLabel: UILabel!
    
    @IBOutlet weak var memoTypeTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var memoInputTextField: UITextField!
    @IBOutlet weak var issuerTextField: UITextField!
    @IBOutlet weak var currentCurrencyTextField: UITextField!
    
    @IBOutlet weak var addressErrorView: UIView!
    @IBOutlet weak var amountErrorView: UIView!
    @IBOutlet weak var passwordErrorView: UIView!
    @IBOutlet weak var sendErrorView: UIView!
    @IBOutlet weak var memoInputErrorStackView: UIView!
    @IBOutlet weak var currentCurrencyView: UIView!
    
    @IBOutlet weak var issuerView: UIView!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    
    private var currencyPickerView: UIPickerView!
    private var issuerPickerView: UIPickerView!
    private var memoTypePickerView: UIPickerView!
    
    @IBOutlet weak var sendAllView: UIView!
    @IBOutlet weak var sendAllValue: UILabel!
    @IBOutlet weak var sendAllCurrency: UILabel!
    @IBOutlet weak var sendAmountView: UIView!
    @IBOutlet weak var amountSegmentedControl: UISegmentedControl!

    private var isInputDataValid: Bool = true
    private var isSendAnywayRequired = false
    private var userMnemonic: String!
    
    var wallet: Wallet!
    var closeAction: (() -> ())?
    var sendAction: ((TransactionInput) -> ())?
    
    private var scanViewController: ScanViewController!
    private let inputDataValidator = InputDataValidator()
    
    private var memoTypes: [MemoTypeValues] = [MemoTypeValues.MEMO_TEXT, MemoTypeValues.MEMO_ID, MemoTypeValues.MEMO_HASH, MemoTypeValues.MEMO_RETURN]
    
    @IBAction func amountSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        if amountSegmentedControl.selectedSegmentIndex == AmountSegmentedControlIndexes.sendAmount.rawValue {
            sendAmountView.isHidden = false
            sendAllView.isHidden = true
            availableAmount = nil
        } else if amountSegmentedControl.selectedSegmentIndex == AmountSegmentedControlIndexes.sendAll.rawValue{
            sendAmountView.isHidden = true
            sendAllView.isHidden = false
            amountErrorView.isHidden = true
            setAvailableAmount()
        }
    }
    
    @IBAction func sendButtonAction(_ sender: UIButton) {
        resetValidations()
        sendButton.setTitle(SendButtonTitles.validating.rawValue, for: UIControlState.normal)
        sendButton.isEnabled = false
            if validateInsertedData() {
                if let address = addressTextField.text,
                    let password = passwordTextField.text,
                    let currency = (wallet as! FoundedWallet).balances.first(where: { (currency) -> Bool in
                        if selectedCurrency == NativeCurrencyNames.xlm.rawValue {
                            return currency.displayCode == selectedCurrency
                        }
                        
                        return currency.displayCode == selectedCurrency && currency.assetIssuer == issuerTextField.text}) {
                    
                    inputDataValidator.validatePasswordAndDestinationAddress(address: address, password: password, currency: currency) { (result) -> (Void) in
                        switch result {
                        case .success(passwordResponse: let passwordResponse, addressResponse: let addressResponse):
                            self.validatePasswordResponse(passwordResponse: passwordResponse)
                            self.validateAddressResponse(addressResponse: addressResponse)
                            
                            if self.isInputDataValid {
                                self.sendPayment()
                            } else {
                                self.resetSendButtonToNormal()
                            }
                            
                        case .failure:
                            break
                        }
                    }
                }
            }
            else {
                resetSendButtonToNormal()
        }
    }

    @objc func addressChanged(_ textField: UITextField) {
        if isSendAnywayRequired {
            setSendButtonDefaultTitle()
            isSendAnywayRequired = false
        }
    }
    
    private var selectedMemoType: MemoTypeValues! = MemoTypeValues.MEMO_TEXT {
        didSet {
            memoTypeTextField.text = selectedMemoType.rawValue
            
            switch selectedMemoType.rawValue {
            case MemoTypeValues.MEMO_TEXT.rawValue:
                memoInputTextField.placeholder = MemoTextFieldPlaceholders.MemoText.rawValue
                break
            case MemoTypeValues.MEMO_ID.rawValue:
                memoInputTextField.placeholder = MemoTextFieldPlaceholders.MemoID.rawValue
                break
            case MemoTypeValues.MEMO_HASH.rawValue:
                memoInputTextField.placeholder = MemoTextFieldPlaceholders.MemoHash.rawValue
                break
            case MemoTypeValues.MEMO_RETURN.rawValue:
                memoInputTextField.placeholder = MemoTextFieldPlaceholders.MemoReturn.rawValue
                break
            default:
                break
            }
        }
    }
    
    private var selectedCurrency: String = "" {
        didSet {
            currentCurrencyLabel.text = selectedCurrency
            
            let currencyIssuer = (wallet as! FoundedWallet).balances.first { (currency) -> Bool in
                return currency.assetCode == selectedCurrency
            }?.assetIssuer
            
            if selectedCurrency == NativeCurrencyNames.xlm.rawValue {
                currentCurrencyTextField.text = nil
                currentCurrencyTextField.insertText(NativeCurrencyNames.stellarLumens.rawValue)
            } else {
                currentCurrencyTextField.text = nil
                currentCurrencyTextField.insertText(selectedCurrency)
            }
            
            setSendButtonDefaultTitle()
            
            if (wallet as! FoundedWallet).isCurrencyDuplicate(withAssetCode: selectedCurrency) {
                if issuerPickerView == nil {
                    issuerPickerView = UIPickerView()
                    issuerPickerView.delegate = self
                    issuerPickerView.dataSource = self
                    issuerTextField.inputView = issuerPickerView
                    issuerTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(issuerDoneButtonTap))
                }
                
                issuerView.isHidden = false
            } else {
                issuerView.isHidden = true
            }
            
            if let currencyIssuer = currencyIssuer {
                issuerTextField.text = nil
                issuerTextField.insertText(currencyIssuer)
            }
            
            setAvailableAmount()
        }
    }
    
    private func showQRScanner() {
        scanViewController = ScanViewController()
        scanViewController.delegate = self
        self.addChildViewController(scanViewController)
        self.view.addSubview(scanViewController.view)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupMemoTypePicker()
        addressTextField.addTarget(self, action: #selector(addressChanged), for: UIControlEvents.editingChanged)
        view.backgroundColor = Stylesheet.color(.veryLightGray)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        availableCurrencies = (wallet as! FoundedWallet).getAvailableCurrencies()
        if selectedCurrency.isEmpty {
            selectedCurrency = availableCurrencies.first!
        }
        
        checkForTransactionFeeAvailability()
        resetSendButtonToNormal()
    }
    
    private var availableAmount: CoinUnit?
    
    private func setupMemoTypePicker() {
        memoTypePickerView = UIPickerView()
        memoTypePickerView.delegate = self
        memoTypePickerView.dataSource = self
        memoTypeTextField.text = selectedMemoType.rawValue
        memoTypeTextField.inputView = memoTypePickerView
        memoTypeTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(memoTypeDoneButtonTap))
    }
    
    private func setAvailableLabels(currency: AccountBalanceResponse) {
        if let balance = CoinUnit(currency.balance) {
            availableAmountLabel.text = "You have \(balance.availableAmount) \(selectedCurrency) available"
            
            if amountSegmentedControl.selectedSegmentIndex == AmountSegmentedControlIndexes.sendAll.rawValue {
                setSendAllLabel(amount: balance.availableAmount)
            }
        }
    }
    
    private func setAvailableAmount() {
        for currency in (wallet as! FoundedWallet).uniqueAssetCodeBalances {
            if selectedCurrency == NativeCurrencyNames.xlm.rawValue {
                setAvailableLabels(currency: currency)
            } else if let currencyIssuer = issuerTextField.text,
                currency.assetIssuer == currencyIssuer,
                currency.assetCode == selectedCurrency {
                setAvailableLabels(currency: currency)
            }
        }
    }
    
    private var availableCurrencies: [String] = [""] {
        didSet {
            if availableCurrencies.count > 1 {
                currencyPickerView = UIPickerView()
                currencyPickerView.delegate = self
                currencyPickerView.dataSource = self
                currentCurrencyTextField.inputView = currencyPickerView
                currentCurrencyTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(currencyDoneButtonTap))
            } else {
                currentCurrencyView.isHidden = true
            }
        }
    }
    
    private func setSendAllLabel(amount: CoinUnit) {
        sendAllValue.text = "\(amount)"
        sendAllCurrency.text = selectedCurrency
        availableAmount = amount
    }
    
    @objc func currencyDoneButtonTap(_ sender: Any) {
        selectAsset(pickerView: currencyPickerView, row: currencyPickerView.selectedRow(inComponent: 0))
    }
    
    @objc func memoTypeDoneButtonTap(_ sender: Any) {
        selectAsset(pickerView: memoTypePickerView, row: memoTypePickerView.selectedRow(inComponent: 0))
    }
    
    @objc func issuerDoneButtonTap(_ sender: Any) {
        selectAsset(pickerView: issuerPickerView, row: issuerPickerView.selectedRow(inComponent: 0))
    }
    
    private func sendPayment() {
        let transactionData = TransactionInput(currency: self.selectedCurrency,
                                               issuer: self.issuerTextField.text ?? nil,
                                               address: self.addressTextField.text ?? "",
                                               amount: availableAmount != nil ? String(availableAmount!) : (self.amountTextField.text ?? ""),
                                               memo: self.memoInputTextField.text?.isEmpty == false ? self.memoInputTextField.text! : nil,
                                               memoType: self.memoTypes.first(where: { (memoType) -> Bool in
                                                if let memoTypeTextFieldValue = self.memoTypeTextField.text {
                                                    return memoType.rawValue == memoTypeTextFieldValue
                                                }
                                                
                                                return memoType.rawValue == MemoTypeValues.MEMO_TEXT.rawValue
                                               }),
                                               userMnemonic: self.userMnemonic,
                                               transactionType: !self.isSendAnywayRequired ? TransactionActionType.sendPayment : TransactionActionType.createAndFundAccount )
        
        self.sendAction?(transactionData)
    }
    
    private func validatePasswordResponse(passwordResponse: PasswordEnum) {
        switch passwordResponse {
        case .success(mnemonic: let mnemonic):
            self.userMnemonic = mnemonic
        case .failure(error: let error):
            print("Error: \(error)")
            self.setValidationError(stackView: self.passwordErrorView, label: self.passwordErrorLabel, errorMessage: ValidationErrors.InvalidPassword)
        }
    }
    
    private func validateAddressResponse(addressResponse: AddressStatusEnum) {
        switch addressResponse {
        case .success(isFunded: let isFunded, isTrusted: let isTrusted):
            if !isFunded {
                if self.isSendAnywayRequired && self.selectedCurrency == NativeCurrencyNames.xlm.rawValue{
                    self.checkForRecipientAccount()
                    return
                }
                
                self.setValidationError(stackView: self.sendErrorView, label: self.sendErrorLabel, errorMessage: ValidationErrors.RecipientAccount)
                
                if self.selectedCurrency == NativeCurrencyNames.xlm.rawValue {
                    self.isSendAnywayRequired = true
                }
            } else if let isTrusted = isTrusted, !isTrusted {
                self.setValidationError(stackView: self.addressErrorView, label: self.addressErrorLabel, errorMessage: ValidationErrors.CurrencyNoTrust)
            }
            
        case .failure:
            print("Account not found")
            if self.selectedCurrency == NativeCurrencyNames.xlm.rawValue {
                if self.isSendAnywayRequired {
                    self.checkForRecipientAccount()
                    return
                }
                
                self.setValidationError(stackView: self.sendErrorView, label: self.sendErrorLabel, errorMessage: ValidationErrors.RecipientAccount)
                self.isSendAnywayRequired = true
            } else {
                self.setValidationError(stackView: self.addressErrorView, label: self.addressErrorLabel, errorMessage: ValidationErrors.AddressNotFound)
            }
        }
    }
    
    private func getSendButtonDefaultTitle() -> String {
        return "SEND \(selectedCurrency)"
    }
    
    private func setSendButtonDefaultTitle() {
        let sendButtonTitle: String = getSendButtonDefaultTitle()
        sendButton.setTitle(sendButtonTitle, for: .normal)
    }
    
    private func checkForTransactionFeeAvailability() {
        if (wallet as! FoundedWallet).nativeBalance.availableAmount.isLess(than: CoinUnit.Constants.transactionFee + CoinUnit.Constants.baseReserver) {
            sendErrorView.isHidden = false
            sendErrorLabel.text = ValidationErrors.InsufficientLumens.rawValue
            sendButton.isEnabled = false
        }
    }
    
    private func resetValidations() {
        addressErrorView.isHidden = true
        addressErrorLabel.text = nil
        amountErrorView.isHidden = true
        amountErrorLabel.text = nil
        memoInputErrorStackView.isHidden = true
        memoInputErrorLabel.text = nil
        passwordErrorView.isHidden = true
        passwordErrorLabel.text = nil
        sendErrorView.isHidden = true
        sendErrorLabel.text = nil
        isInputDataValid = true
        setSendButtonDefaultTitle()
    }
    
    private func setValidationError(stackView: UIView, label: UILabel, errorMessage: ValidationErrors) {
        stackView.isHidden = false
        label.text = errorMessage.rawValue
        
        isInputDataValid = false
    }
    
    private func validateAddress() {
        if let address = addressTextField.text {
            if !address.isMandatoryValid() {
                setValidationError(stackView: addressErrorView, label: addressErrorLabel, errorMessage: ValidationErrors.Mandatory)
                return
            }
            
            if address.isFederationAddress() {
                return
            }
            
            if !address.isBase64Valid() {
                setValidationError(stackView: addressErrorView, label: addressErrorLabel, errorMessage: ValidationErrors.InvalidAddress)
            }
        }
    }
    
    private func validateAmount() {
        if let amountToValidate = self.amountTextField.text, availableAmount == nil {
            if !amountToValidate.isMandatoryValid() {
                setValidationError(stackView: amountErrorView, label: amountErrorLabel, errorMessage: ValidationErrors.Mandatory)
                return
            }
            
            validate(amount: amountToValidate)
        } else if let amountToValidate = availableAmount {
            validate(amount: String(amountToValidate))
        }
    }
    
    private func validate(amount: String) {
        if let balance: String = (wallet as! FoundedWallet).balances.first(where: { (balance) -> Bool in
            if selectedCurrency == NativeCurrencyNames.xlm.rawValue {
                return balance.displayCode == selectedCurrency
            }
            
            return balance.displayCode == selectedCurrency && balance.assetIssuer == issuerTextField.text})?.balance {
            if !amount.isAmountValid(forBalance: balance) {
                amountErrorView.isHidden = false
                amountErrorLabel.text = "Insufficient \(selectedCurrency) available"
                isInputDataValid = false
            }
        }
    }
    
    private func validateMemo() {
        if let memoText = self.memoInputTextField.text {
            if memoText.isEmpty == true {
                return
            }
            
            switch selectedMemoType.rawValue {
            case MemoTypeValues.MEMO_TEXT.rawValue:
                let memoTextValidationResult: MemoTextValidationResult = memoText.isMemoTextValid(limitNrOfBytes: MaximumLengthInBytesForMemoText)
                
                if memoTextValidationResult == MemoTextValidationResult.InvalidEncoding {
                    setValidationError(stackView: memoInputErrorStackView, label: memoInputErrorLabel, errorMessage: ValidationErrors.InvalidMemo)
                    return
                }
                
                if memoTextValidationResult == MemoTextValidationResult.InvalidLength {
                    setValidationError(stackView: memoInputErrorStackView, label: memoInputErrorLabel, errorMessage: ValidationErrors.MemoLength)
                    return
                }
                
            case MemoTypeValues.MEMO_ID.rawValue:
                if !memoText.isMemoIDValid() {
                    setValidationError(stackView: memoInputErrorStackView, label: memoInputErrorLabel, errorMessage: ValidationErrors.InvalidMemo)
                }
                
            case MemoTypeValues.MEMO_HASH.rawValue:
                if !memoText.isMemoHashValid() {
                    setValidationError(stackView: memoInputErrorStackView, label: memoInputErrorLabel, errorMessage: ValidationErrors.InvalidMemo)
                }
                
            case MemoTypeValues.MEMO_RETURN.rawValue:
                if !memoText.isMemoReturnValid() {
                    setValidationError(stackView: memoInputErrorStackView, label: memoInputErrorLabel, errorMessage: ValidationErrors.InvalidMemo)
                }
                
            default:
                break
            }
        }
    }
    
    
    
    private func validatePassword() {
        if let currentPassword = passwordTextField.text {
            if !currentPassword.isMandatoryValid() {
                setValidationError(stackView: passwordErrorView, label: passwordErrorLabel, errorMessage: ValidationErrors.Mandatory)
                return
            }
            
            if !isInputDataValid {
                return
            }
        }
    }
    
    private func checkForRecipientAccount() {
        if !isInputDataValid || isSendAnywayRequired {
            if isSendAnywayRequired {
                isInputDataValid = true
            }

            return
        }
    }
    
    private func validateInsertedData() -> Bool {
        validateAddress()
        validateAmount()
        validateMemo()
        validatePassword()
        checkForTransactionFeeAvailability()
        checkForRecipientAccount()
        
        return isInputDataValid
    }
    
    func setQR(value: String) {
        // QR Valid Structure:
        // Currency: XML
        // Issuer: KAJSHDJAS.../native
        // Address: KJSAHDJKASH...
        // Amount: 500
        // MemoType: none/text/id/hash/return
        // Memo: none/value
        // Password: asdfdasjkd
        
        // Example: XML native me@me.me 500 none none 1234
        
        let qrResultArray = value.components(separatedBy: QRCodeSeparationString)
        
        if qrResultArray.count != 7 {
            scanViewController.view.removeFromSuperview()
            scanViewController = nil
            return
        }
        
        currentCurrencyTextField.text = nil
        currentCurrencyTextField.insertText(qrResultArray[0])
        issuerTextField.text = qrResultArray[1] != QRCodeNativeCurrencyIssuer ? qrResultArray[1] : nil
        addressTextField.text = qrResultArray[2]
        amountTextField.text = qrResultArray[3]
        
        switch qrResultArray[4] {
        case MemoTypeAsString.TEXT:
            memoTypeTextField.text = MemoTypeValues.MEMO_TEXT.rawValue
        case MemoTypeAsString.ID:
            memoTypeTextField.text = MemoTypeValues.MEMO_ID.rawValue
        case MemoTypeAsString.HASH:
            memoTypeTextField.text = MemoTypeValues.MEMO_HASH.rawValue
        case MemoTypeAsString.RETURN:
            memoTypeTextField.text = MemoTypeValues.MEMO_RETURN.rawValue
        default:
            break
        }
        
        if qrResultArray[5] != MemoTypeAsString.NONE {
            memoInputTextField.text = qrResultArray[5]
        }
        
        passwordTextField.text = qrResultArray[6]
        scanViewController.view.removeFromSuperview()
        scanViewController = nil
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == currencyPickerView {
            return availableCurrencies.count
        } else if pickerView == memoTypePickerView {
            return memoTypes.count
        } else if pickerView == issuerPickerView {
            return (wallet as! FoundedWallet).issuersFor(assetCode: selectedCurrency).count
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == currencyPickerView {
            if availableCurrencies[row] == NativeCurrencyNames.xlm.rawValue {
                return NativeCurrencyNames.stellarLumens.rawValue
            }
            return availableCurrencies[row]
        } else if pickerView == memoTypePickerView {
            return memoTypes[row].rawValue
        } else if pickerView == issuerPickerView {
            return (wallet as! FoundedWallet).issuersFor(assetCode: selectedCurrency)[row]
        }
        
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectAsset(pickerView: pickerView, row: row)
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        if let scanController = scanViewController {
            scanController.view.removeFromSuperview()
            scanViewController = nil
        } else {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func didTapScan(_ sender: Any) {
        showQRScanner()
    }
    
    private func selectAsset(pickerView: UIPickerView, row: Int) {
        if pickerView == currencyPickerView {
        selectedCurrency = availableCurrencies[row]
        return
        } else if pickerView == memoTypePickerView {
            selectedMemoType = memoTypes[row]
            return
        } else if pickerView == issuerPickerView {
            issuerTextField.text = (wallet as! FoundedWallet).issuersFor(assetCode: selectedCurrency)[row]
        }
    }
    
    private func resetSendButtonToNormal() {
        sendButton.setTitle(isSendAnywayRequired ? SendButtonTitles.sendAnyway.rawValue : getSendButtonDefaultTitle(), for: UIControlState.normal)
        sendButton.isEnabled = true
    }
    
    private func setupNavigationItem() {
        navigationItem.titleLabel.text = "Send"
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        
        let backButton = Material.IconButton()
        backButton.image = R.image.arrowLeft()?.crop(toWidth: 15, toHeight: 15)?.tint(with: Stylesheet.color(.white))
        backButton.addTarget(self, action: #selector(didTapBack(_:)), for: .touchUpInside)
        navigationItem.leftViews = [backButton]
        
        let scanQrButton = Material.IconButton()
        scanQrButton.image = R.image.qr_placeholder()?.crop(toWidth: 15, toHeight: 15)?.tint(with: Stylesheet.color(.white))
        scanQrButton.addTarget(self, action: #selector(didTapScan(_:)), for: .touchUpInside)
        navigationItem.rightViews = [scanQrButton]
    }
}
