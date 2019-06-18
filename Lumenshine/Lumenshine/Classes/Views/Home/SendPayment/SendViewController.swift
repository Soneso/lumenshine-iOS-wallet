//
//  SendViewController.swift
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
import stellarsdk
import Material
import M13Checkbox
import TTTAttributedLabel

enum ValidationErrors: String {
    case Mandatory = "Mandatory"
    case InvalidAddress = "Invalid public key or address"
    case InvalidMemo = "Invalid memo"
    case MemoLength = "Memo is too long"
    case InsufficientLumens = "Insufficient XLM for transaction fee available"
    case ResolveRecepientAddress = "An error occured while trying to validate recepient address"
    case CurrencyNoTrust = "Recipient can not receive selected currency"
    case AddressNotFound = "Address not found"
    case InvalidPassword = "Invalid password"
    case SigningError = "An error occured while trying to sign transaction"
    case MandatoryPassword = "Password required"
    case InvalidSignerSeed = "Invalid seed"
    case InvalidAmount = "Invalid amount"
    case InvalidAssetCode = "Invalid asset code"
    case InvalidStellarAddress = "Invalid stellar address"
    case StellarAddressNotFound = "Could not find stellar address"
    case CurrencyNotFound = "Could not find selected currency"
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
    case MemoReturn = "Enter 64 characters encoded string"
}

enum NativeCurrencyNames: String {
    case xlm = "XLM"
    case stellarLumens = "Stellar Lumens (XLM)"
}

enum SendButtonTitles: String {
    case validating = "Validating and sending"
}

enum AmountSegmentedControlIndexes: Int {
    case sendAmount = 0
    case sendAll = 1
}

public let MaximumLengthInBytesForMemoText = 28
public let OtherCurrencyText = "Own asset"

class SendViewController: UpdatableViewController, UIPickerViewDelegate, UIPickerViewDataSource, WalletActionsProtocol, ScanViewControllerDelegate, UITextFieldDelegate, TTTAttributedLabelDelegate {
    @IBOutlet weak var currentCurrencyLabel: UILabel!
    @IBOutlet weak var addressErrorLabel: UILabel!
    @IBOutlet weak var amountErrorLabel: UILabel!
    @IBOutlet weak var sendErrorLabel: UILabel!
    @IBOutlet weak var availableAmountLabel: UILabel!
    @IBOutlet weak var sendAllCurrency: UILabel!
    @IBOutlet weak var sendAllValue: UILabel!
    @IBOutlet weak var otherCurrencyErrorLabel: UILabel!
    @IBOutlet weak var transactionFeeLabel: UILabel!
    @IBOutlet weak var otherCurrencyAgreementLabel: TTTAttributedLabel!
    
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var issuerTextField: UITextField!
    @IBOutlet weak var currentCurrencyTextField: UITextField!
    @IBOutlet weak var otherCurrencyTextField: UITextField!
    
    @IBOutlet weak var addressErrorView: UIView!
    @IBOutlet weak var amountErrorView: UIView!
    @IBOutlet weak var sendErrorView: UIView!
    @IBOutlet weak var issuerView: UIView!
    @IBOutlet weak var contentView: UIScrollView!
    @IBOutlet weak var sendAllView: UIView!
    @IBOutlet weak var sendAmountView: UIView!
    @IBOutlet weak var availableAmountView: UIView!
    @IBOutlet weak var otherCurrencyView: UIView!
    @IBOutlet weak var otherCurrencyErrorView: UIView!
    @IBOutlet weak var passwordViewContainer: UIView!
    @IBOutlet weak var memoViewContainer: UIView!
    @IBOutlet weak var walletsViewContainer: UIView!
    @IBOutlet weak var checkBoxView: UIView!
    @IBOutlet weak var otherCurrencyAgreementView: UIView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var amountSegmentedControl: UISegmentedControl!
    
    private var currencyPickerView: UIPickerView!
    private var issuerPickerView: UIPickerView!
    
    private var isInputDataValid: Bool = true
    private var createRecepientAccount = false
    private var masterKeyPair: KeyPair!
    private var availableAmount: CoinUnit?
    private var otherCurrencyAsset: AccountBalanceResponse?
    private var destinationPublicKey: String = ""
    private var destinationStellarAddress: String?
    
    private var scanViewController: ScanViewController!
    private let userManager = UserManager()
    private let passwordManager = PasswordManager()
    private let walletManager = WalletManager()
    
    var walletsList: [Wallet]!
    var contactDestination: String?
    var wallet: Wallet!
    var closeAction: (() -> ())?
    var sendAction: ((TransactionInput) -> ())?
    
    private var passwordView: PasswordView!
    private var memoView: MemoView!
    private var walletsView: WalletsView!
    private var agreementCheckBox: M13Checkbox!
    
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
        sendActionPreparation()
    }
    
    private func sendActionPreparation(biometricAuth: Bool = false) {
        resetValidations()
        showActivity(message: R.string.localizable.validateing())
        sendButton.setTitle(SendButtonTitles.validating.rawValue, for: UIControl.State.normal)
        sendButton.isEnabled = false
        
        self.destinationPublicKey = ""
        self.destinationStellarAddress = nil
        self.createRecepientAccount = false
        self.masterKeyPair = nil
        
        if validateInsertedData(biometricAuth: biometricAuth) {
            if passwordView.passwordStackView.isHidden {
                setDestinationPKAndContinuePaymentIfValid(forMasterKey: false, biometricAuth: false)
            } else {
                setDestinationPKAndContinuePaymentIfValid(forMasterKey: true, biometricAuth: biometricAuth)
            }
        }
        else {
            resetSendButtonToNormal()
        }
    }
    
    /**
    // finds and sets the destination public key before continuing with the payment process
    // if the inserted address is a stellar address it makes a federation call to find the destination public key
    // after finding and setting the destination public key it continues with the payment process
     **/
    private func setDestinationPKAndContinuePaymentIfValid(forMasterKey: Bool, biometricAuth: Bool) {
        if let address = addressTextField.text {
            self.destinationPublicKey = address
            
            // resolve federation if needed
            if address.isFederationAddress() {
                Federation.resolve(stellarAddress: address, completion: { (response) -> (Void) in
                    switch response {
                    case .success(let federationResponse):
                        if let pk = federationResponse.accountId {
                            self.destinationPublicKey = pk
                            self.destinationStellarAddress = address
                            DispatchQueue.main.async {
                                if let federationMemoType = federationResponse.memoType, let federationMemo = federationResponse.memo {
                                    
                                    switch federationMemoType.trimmed.lowercased() {
                                    case "text":
                                        self.memoView.selectedMemoType = MemoTypeValues.MEMO_TEXT
                                    case "id":
                                        self.memoView.selectedMemoType = MemoTypeValues.MEMO_ID
                                    case "hash":
                                        self.memoView.selectedMemoType = MemoTypeValues.MEMO_HASH
                                    case "return":
                                        self.memoView.selectedMemoType = MemoTypeValues.MEMO_RETURN
                                    default:
                                        self.memoView.selectedMemoType = MemoTypeValues.MEMO_TEXT
                                    }
                                    self.memoView.memo = federationMemo
                                }
                                // continue payment process
                                self.validateDestinationAndContinuePaymentIfValid(forMasterKey:forMasterKey, biometricAuth:biometricAuth)
                            }
                            return
                        } else {
                            DispatchQueue.main.async {
                                self.setValidationError(view: self.addressErrorView, label: self.addressErrorLabel, errorMessage: .StellarAddressNotFound)
                            }
                        }
                    case .failure(error: let error):
                        switch error {
                        case FederationError.invalidAddress:
                            DispatchQueue.main.async {
                                self.setValidationError(view: self.addressErrorView, label: self.addressErrorLabel, errorMessage: .InvalidStellarAddress)
                            }
                        default:
                            DispatchQueue.main.async {
                                self.setValidationError(view: self.addressErrorView, label: self.addressErrorLabel, errorMessage: .StellarAddressNotFound)
                            }
                        }
                    }
                })
            } else {
                // input is public key, no federation request needed
                // continue payment process
                self.validateDestinationAndContinuePaymentIfValid(forMasterKey:forMasterKey, biometricAuth:biometricAuth)
            }
        } else {
            // could not read user input
            self.setValidationError(view: self.addressErrorView, label: self.addressErrorLabel, errorMessage: .AddressNotFound)
        }
    }
    
    /**
    // validates the destination account and continues with the payment process if valid.
    // if the user wants to send an aritrary token, this function validates if if the receiving account has a trutsline to the token
    // if the destination account does not exist, and native token is sent, this function prepares the payment for the create account operation
    // after validating the destination account it continues with the payment process
    **/
    private func validateDestinationAndContinuePaymentIfValid(forMasterKey: Bool, biometricAuth: Bool) {
        
        let password = !biometricAuth ? passwordView.passwordTextField.text : nil
        
        if otherCurrencyView.isHidden { // currency is native or selected from dropdown
            if let currency = getSelectedCurrency() {
                self.userManager.checkAddressStatus(forAccountID: destinationPublicKey, asset: currency, completion: { (addressResult) -> (Void) in
                    switch addressResult {
                    case .success(isFunded: let isFunded, isTrusted: let isTrusted, limit: let limit):
                        if !isFunded {
                            self.createRecepientAccount = true
                        } else if let isTrusted = isTrusted {
                            if !isTrusted {
                                self.setValidationError(view: self.addressErrorView, label: self.addressErrorLabel, errorMessage: .CurrencyNoTrust)
                            } else if let limit = limit {
                                if let amount = self.amountTextField.text {
                                    let correctedAmount = amount.replacingOccurrences(of: ",", with: ".")
                                    if let amountToSend = CoinUnit(correctedAmount), !amountToSend.isLessThanOrEqualTo(limit) {
                                        let individualMessage = "Recepient can not receive more than \(limit)"
                                        self.setValidationError(view: self.amountErrorView, label: self.amountErrorLabel, errorMessage: .InvalidAmount, individualMessage: individualMessage)
                                    }
                                }
                            }
                        }
                        // continue payment process if valid
                        if (self.isInputDataValid && forMasterKey) {
                            self.validatePasswordAndSendPaymentIfValid(password: password)
                        } else if (self.isInputDataValid) {
                            self.sendPaymentIfValid()
                        }
                    case .failure: // TODO: handle: address found but horizon error
                        self.setValidationError(view: self.addressErrorView, label: self.addressErrorLabel, errorMessage: .ResolveRecepientAddress)
                    }
                })
            } else {
                self.setValidationError(view: self.sendErrorView, label: self.sendErrorLabel, errorMessage: .CurrencyNotFound)
            }
        } else { // currency asset code is provided by user, current account is issuer
            userManager.hasAccountTrustline(forAccount: destinationPublicKey, forAssetCode: selectedCurrency, forAssetIssuer: wallet.publicKey) { (response) -> (Void) in
                switch (response) {
                case .success(hasTrustline: let hasTrustline, currency: let currencyResponse):
                    let currency = currencyResponse
                    if (hasTrustline) {
                        self.otherCurrencyAsset = currency
                        
                        // check limit
                        if let ownCurrency = currency, let cbalance = CoinUnit(ownCurrency.balance), let climit = CoinUnit(ownCurrency.limit), let minus = CoinUnit("-1.0") {
                            let limit = climit.addingProduct(minus, cbalance)
                            //print("Limit: " + limit.stringWithUnit)
                            if let amount = self.amountTextField.text {
                                let correctedAmount = amount.replacingOccurrences(of: ",", with: ".")
                                if let amountToSend = CoinUnit(correctedAmount), !amountToSend.isLessThanOrEqualTo(limit) {
                                    let individualMessage = "Recepient can not receive more than \(limit)"
                                    self.setValidationError(view: self.amountErrorView, label: self.amountErrorLabel, errorMessage: .InvalidAmount, individualMessage: individualMessage)
                                    return
                                }
                            }
                        }
                        
                        // continue payment process
                        if (forMasterKey) {
                            self.validatePasswordAndSendPaymentIfValid(password: password)
                        } else {
                            self.sendPaymentIfValid()
                        }
                    } else {
                        self.setValidationError(view: self.otherCurrencyErrorView, label: self.otherCurrencyErrorLabel, errorMessage: .CurrencyNoTrust)
                    }
                case .failure(error: let error):
                    print("error looking up for trustline of recepient account: \(error)")
                    self.setValidationError(view: self.sendErrorView, label: self.sendErrorLabel, errorMessage: .ResolveRecepientAddress)
                }
            }
        }
    }
    
    /**
    // validates the password of the user and creates the master key pair containing the seed to be used for payment
    // continues with the payment process if the password is valid
     **/
    private func validatePasswordAndSendPaymentIfValid(password: String?) {
        passwordManager.getMnemonic(password: password) { (passwordResult) -> (Void) in
            switch passwordResult {
            case .success(mnemonic: let mnemonic):
                PrivateKeyManager.getKeyPair(forAccountID: self.wallet.publicKey, fromMnemonic: mnemonic) { (response) -> (Void) in
                    switch response {
                    case .success(keyPair: let keyPair):
                        if let sourceKeyPair = keyPair {
                            self.masterKeyPair = sourceKeyPair
                            self.sendPaymentIfValid()
                        }
                    case .failure(error: let error):
                        print(error)
                        self.setValidationError(view: self.sendErrorView, label: self.sendErrorLabel, errorMessage: .SigningError)
                    }
                }
            case .failure(error: let error):
                print("Error: \(error)")
                self.passwordView.showInvalidPasswordError()
                self.setSendButtonDefaultTitle()
            }
        }
    }
    
    private func getSelectedCurrency() -> AccountBalanceResponse? {
        return (wallet as! FundedWallet).balances.first(where: { (currency) -> Bool in
            if selectedCurrency == NativeCurrencyNames.xlm.rawValue {
                return currency.displayCode == selectedCurrency
            }
            
            return currency.displayCode == selectedCurrency && currency.assetIssuer == issuerTextField.text})
    }
    
    /**
    // sends the payment if no input vas invalid
    **/
    private func sendPaymentIfValid() {
        if isInputDataValid {
            sendPayment()
        } else {
            resetSendButtonToNormal()
        }
    }
    
    @objc func addressChanged(_ textField: UITextField) {
        if createRecepientAccount {
            setSendButtonDefaultTitle()
            createRecepientAccount = false
        }
    }
    
    @objc func otherCurrencyChanged(_ textField: UITextField) {
        selectedCurrency = otherCurrencyTextField.text ?? ""
        currentCurrencyLabel.text = selectedCurrency
        sendButton.setTitle(getSendButtonDefaultTitle(), for: .normal)
        validateOtherAssetCode()
    }
    
    private var selectedCurrency: String = "" {
        didSet {
            if !otherCurrencyView.isHidden {
                return
            }
            
            currentCurrencyLabel.text = selectedCurrency
            
            let currencyIssuer = (wallet as! FundedWallet).balances.first { (currency) -> Bool in
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
            
            if (wallet as! FundedWallet).isCurrencyDuplicate(withAssetCode: selectedCurrency) {
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
        navigationController?.pushViewController(scanViewController, animated: true)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        wallet = walletsList.first
        setupWalletsView()
        setupNavigationItem()
        addressTextField.addTarget(self, action: #selector(addressChanged), for: .editingChanged)
        view.backgroundColor = Stylesheet.color(.veryLightGray)
        sendButton.backgroundColor = Stylesheet.color(.blue)
        transactionFeeLabel.text = "Stellar transaction fee: \(String(format: "%.5f", CoinUnit.Constants.transactionFee)) XLM"
        setupPasswordView()
        setupMemoView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        availableCurrencies = (wallet as! FundedWallet).getAvailableCurrencies()
        if selectedCurrency.isEmpty {
            selectedCurrency = availableCurrencies.first!
        }
        
        if let contactDestination = contactDestination {
            addressTextField.text = contactDestination
        }
        
        checkForTransactionFeeAvailability()
        resetSendButtonToNormal()
    }
    
    private func refreshAvailableCurrencies() {
        setupForSelectedCurrency()
        availableCurrencies = (wallet as! FundedWallet).getAvailableCurrencies()
        selectedCurrency = availableCurrencies.first!
    }
    
    private func refreshAfterWalletChanged() {
        refreshAvailableCurrencies()
        setAvailableAmount()
        checkForTransactionFeeAvailability()
    }
    
    private func setupPasswordView() {
        if let wallet = wallet as? FundedWallet {
            passwordView = Bundle.main.loadNibNamed("PasswordView", owner: self, options: nil)![0] as? PasswordView
            passwordView.neededSigningSecurity = .medium
            passwordView.wallet = wallet
            passwordView.contentView = contentView
            
            passwordView.biometricAuthAction = { [weak self] in
                self?.sendActionPreparation(biometricAuth: true)
            }
            
            passwordViewContainer.addSubview(passwordView)
            
            passwordView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    private func setupMemoView() {
        memoView = Bundle.main.loadNibNamed("MemoView", owner: self, options: nil)![0] as? MemoView
        memoView.contentView = contentView
        
        memoViewContainer.addSubview(memoView)
        
        memoView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupWalletsView() {
        if walletsList.count == 1 {
            return
        }
        
        walletsView = Bundle.main.loadNibNamed("WalletsPickerView", owner: self, options: nil)![0] as? WalletsView
        walletsView.walletsList = walletsList
        walletsViewContainer.addSubview(walletsView)
        
        walletsView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        walletsView.walletChanged = { (wallet) in
            self.wallet = wallet
            self.refreshAfterWalletChanged()
        }
    }
    
    private func setupOtherCurrencyAgreement() {
        otherCurrencyAgreementView.isHidden = false
        
        if agreementCheckBox != nil {
            agreementCheckBox.checkState = .unchecked
            sendButton.isEnabled = false
            return
        }
        
        agreementCheckBox = M13Checkbox(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        checkBoxView.addSubview(agreementCheckBox)
        agreementCheckBox.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        agreementCheckBox.boxType = .square
        agreementCheckBox.tintColor = Stylesheet.color(.lightBlack)
        agreementCheckBox.addTarget(self, action: #selector(agreementCheckBoxChecked), for: .valueChanged)
        
        let text = "I understand what own assets are and I take full responsibility for my own assets. Lumenshine is not responsible for any asset on the Stellar Network"
        
        setupOtherCurrencyAgreementLabel(forText: text)
    }
    
    private func setupOtherCurrencyAgreementLabel(forText text: String) {
        otherCurrencyAgreementLabel.delegate = self
        otherCurrencyAgreementLabel.font = R.font.encodeSansRegular(size: 16)
        otherCurrencyAgreementLabel.textColor = Stylesheet.color(.lightBlack)
        let linkAttributes = [ NSAttributedString.Key.foregroundColor: Stylesheet.color(.blue) ] as [NSAttributedString.Key : Any]
        otherCurrencyAgreementLabel.activeLinkAttributes = linkAttributes
        otherCurrencyAgreementLabel.linkAttributes = linkAttributes

        otherCurrencyAgreementLabel.setText(text)
        
        if let range = text.range(of: "own assets") {
            let objcRange = NSMakeRange(range.lowerBound.encodedOffset, range.upperBound.encodedOffset - range.lowerBound.encodedOffset)
            otherCurrencyAgreementLabel.addLink(to: URL(string: "goto://ownAssets"), with: objcRange)
        }
    }
    
    @objc func agreementCheckBoxChecked() {
        if agreementCheckBox.checkState == .checked {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
        }
    }
    
    private func setupForOtherCurrency() {
        currentCurrencyTextField.text = nil
        currentCurrencyTextField.insertText(OtherCurrencyText)
        availableAmountView.isHidden = true
        otherCurrencyView.isHidden = false
        issuerView.isHidden = true
        amountSegmentedControl.selectedSegmentIndex = AmountSegmentedControlIndexes.sendAmount.rawValue
        sendAmountView.isHidden = false
        sendAllView.isHidden = true
        availableAmount = nil
        amountSegmentedControl.isEnabled = false
        
        selectedCurrency = ""
        currentCurrencyLabel.text = selectedCurrency
        setSendButtonDefaultTitle()
        setupOtherCurrencyAgreement()
        
        otherCurrencyTextField.addTarget(self, action: #selector(otherCurrencyChanged), for: .editingChanged)
    }
    
    private func setupForSelectedCurrency() {
        if !otherCurrencyView.isHidden {
            otherCurrencyAsset = nil
            availableAmountView.isHidden = false
            otherCurrencyView.isHidden = true
            amountSegmentedControl.isEnabled = true
            otherCurrencyAgreementView.isHidden = true
            resetOtherCurrencyValidationError()
            otherCurrencyTextField.text = nil
            sendButton.isEnabled = true
            checkForTransactionFeeAvailability()
            otherCurrencyTextField.removeTarget(self, action: #selector(otherCurrencyChanged), for: .editingChanged)
        }
    }
    
    private func setAvailableLabels(currency: AccountBalanceResponse) {
        if let balance = CoinUnit(currency.balance) {
            let availableAmount = balance.availableAmount(forWallet: wallet, forCurrency: currency)
            availableAmountLabel.text = "You have \(availableAmount.stringWithUnit) \(selectedCurrency) available"
            
            if amountSegmentedControl.selectedSegmentIndex == AmountSegmentedControlIndexes.sendAll.rawValue {
                setSendAllLabel(amount: availableAmount)
            }
        }
    }
    
    private func setAvailableAmount() {
        for currency in (wallet as! FundedWallet).uniqueAssetCodeBalances {
            if selectedCurrency == NativeCurrencyNames.xlm.rawValue && (currency.assetCode == nil || currency.assetCode == selectedCurrency) {
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
            currencyPickerView = UIPickerView()
            currencyPickerView.delegate = self
            currencyPickerView.dataSource = self
            currentCurrencyTextField.inputView = currencyPickerView
            currentCurrencyTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(currencyDoneButtonTap))
            availableCurrencies.append(OtherCurrencyText)
        }
    }
    
    private func setSendAllLabel(amount: CoinUnit) {
        let maximumSendableValue = selectedCurrency == NativeCurrencyNames.xlm.rawValue ? amount - CoinUnit.Constants.transactionFee : amount
        availableAmount = maximumSendableValue > CoinUnit(0) ? maximumSendableValue : 0.00
        if let availableAmount = availableAmount {
            sendAllValue.text = "\(availableAmount)"
            sendAllCurrency.text = selectedCurrency
        }
    }
    
    @objc func currencyDoneButtonTap(_ sender: Any) {
        selectAsset(pickerView: currencyPickerView, row: currencyPickerView.selectedRow(inComponent: 0))
    }
    
    @objc func issuerDoneButtonTap(_ sender: Any) {
        selectAsset(pickerView: issuerPickerView, row: issuerPickerView.selectedRow(inComponent: 0))
    }
    
    private func sendPayment() {
        
        updateActivityMessage(message: R.string.localizable.sending())
        
        let transactionData = TransactionInput(currency: self.selectedCurrency,
                                               issuer: self.issuerTextField.text ?? nil,
                                               destinationPublicKey: self.destinationPublicKey,
                                               destinationStellarAddress: self.destinationStellarAddress,
                                               amount: self.availableAmount != nil ? String(self.availableAmount!) : (self.amountTextField.text?.replacingOccurrences(of: ",", with: ".") ?? ""),
                                               memo: self.memoView.hasMemo ? self.memoView.memo : nil,
                                               memoType: self.memoView.getMemoType,
                                               masterKeyPair: self.masterKeyPair,
                                               transactionType: self.createRecepientAccount ? TransactionActionType.createAndFundAccount : TransactionActionType.sendPayment,
                                               signer: self.passwordView.useExternalSigning ? self.passwordView.signersTextField.text : nil,
                                               signerSeed: self.passwordView.useExternalSigning ? self.passwordView.seedTextField.text : nil,
                                               otherCurrencyAsset: self.otherCurrencyAsset ?? nil)
        self.passwordView.clearSeedAndPasswordFields()
        self.sendAction?(transactionData)
    }
    
    private func getSendButtonDefaultTitle() -> String {
        return "SEND \(selectedCurrency)"
    }
    
    private func setSendButtonDefaultTitle() {
        hideActivity()
        let sendButtonTitle: String = getSendButtonDefaultTitle()
        sendButton.setTitle(sendButtonTitle, for: .normal)
        
        if !sendButton.isEnabled {
            sendButton.isEnabled = true
        }
    }
    
    private func checkForTransactionFeeAvailability() {
        if (wallet as! FundedWallet).nativeBalance.availableAmount(forWallet: wallet, forCurrency: (wallet as? FundedWallet)?.nativeAsset).isLess(than: CoinUnit.minimumAccountBalance(forWallet: wallet)) {
            sendErrorView.isHidden = false
            sendErrorLabel.text = ValidationErrors.InsufficientLumens.rawValue
            sendButton.isEnabled = false
        } else if !sendErrorView.isHidden {
            sendErrorView.isHidden = true
            sendErrorLabel.text = nil
            sendButton.isEnabled = true
        }
    }
    
    private func resetValidations() {
        addressErrorView.isHidden = true
        addressErrorLabel.text = nil
        amountErrorView.isHidden = true
        amountErrorLabel.text = nil
        memoView.resetValidationErrors()
        sendErrorView.isHidden = true
        sendErrorLabel.text = nil
        otherCurrencyErrorView.isHidden = true
        otherCurrencyErrorLabel.text = nil
        isInputDataValid = true
        passwordView.resetValidationErrors()
        setSendButtonDefaultTitle()
    }
    
    private func setValidationError(view: UIView, label: UILabel, errorMessage: ValidationErrors, individualMessage: String? = nil) {
        view.isHidden = false
        if let individualMessage = individualMessage {
            label.text = individualMessage
        }
        else {
            label.text = errorMessage.rawValue
        }
        self.isInputDataValid = false
        
        self.contentView.setContentOffset(CGPoint(x: 0, y: view.frame.center.y), animated: false)
        self.setSendButtonDefaultTitle()
        
    }
    
    private func resetOtherCurrencyValidationError() {
        otherCurrencyAsset = nil
        otherCurrencyErrorLabel.text = nil
        otherCurrencyErrorView.isHidden = true
        isInputDataValid = true
    }
    
    private func validateOtherAssetCodeIsFilled() {
        if !otherCurrencyView.isHidden, let assetCode = otherCurrencyTextField.text, !assetCode.isMandatoryValid() {
            setValidationError(view: otherCurrencyErrorView, label: otherCurrencyErrorLabel, errorMessage: .Mandatory)
        }
    }
    
    private func validateOtherAssetCode() {
        if let assetCode = otherCurrencyTextField.text {
            if !assetCode.isAssetCodeValid() {
                setValidationError(view: otherCurrencyErrorView, label: otherCurrencyErrorLabel, errorMessage: .InvalidAssetCode)
            } else {
                resetOtherCurrencyValidationError()
            }
        }
    }
    
    private func validateAddress() {
        if let address = addressTextField.text {
            if !address.isMandatoryValid() {
                setValidationError(view: addressErrorView, label: addressErrorLabel, errorMessage: .Mandatory)
                return
            }
            
            if address.isFederationAddress() {
                return
            }
            
            if !address.isValidEd25519PublicKey() {
                setValidationError(view: addressErrorView, label: addressErrorLabel, errorMessage: .InvalidAddress)
            }
        }
    }
    
    private func validateAmount() {
        if let amountToValidate = self.amountTextField.text, availableAmount == nil {
            if !amountToValidate.isMandatoryValid() {
                setValidationError(view: amountErrorView, label: amountErrorLabel, errorMessage: .Mandatory)
                return
            }
            
            validate(amount: amountToValidate)
        } else if let amountToValidate = availableAmount {
            validate(amount: String(amountToValidate))
        }
    }
    
    private func validate(amount: String) {
        
        let correctedAmount = amount.replacingOccurrences(of: ",", with: ".")
        if !correctedAmount.isNumeric() {
            setValidationError(view: amountErrorView, label: amountErrorLabel, errorMessage: .InvalidAmount)
            return
        }
        
        if let balance: String = (wallet as! FundedWallet).balances.first(where: { (balance) -> Bool in
            if selectedCurrency == NativeCurrencyNames.xlm.rawValue {
                return balance.displayCode == selectedCurrency
            }
            
            return balance.displayCode == selectedCurrency && balance.assetIssuer == issuerTextField.text})?.balance {
            
            var balanceToValidate = balance
            
            if selectedCurrency == NativeCurrencyNames.xlm.rawValue {
                if let balance = CoinUnit(balance) {
                    balanceToValidate = String(balance.availableAmount(forWallet: wallet, forCurrency: (wallet as? FundedWallet)?.nativeAsset))
                }
            }
            
            if !correctedAmount.isAmountSufficient(forBalance: balanceToValidate) {
                let individualMessage = "Insufficient \(selectedCurrency) available"
                setValidationError(view: amountErrorView, label: amountErrorLabel, errorMessage: .InvalidAmount, individualMessage: individualMessage)
                return
            }
        }
    }
    
    private func validateInsertedData(biometricAuth: Bool = false) -> Bool {
        validateAddress()
        validateOtherAssetCodeIsFilled()
        validateAmount()
        
        if !memoView.validateMemo() {
            isInputDataValid = false
        }
        
        if isInputDataValid {
            isInputDataValid = passwordView.validatePassword(biometricAuth: biometricAuth)
        }
        
        checkForTransactionFeeAvailability()
        
        return isInputDataValid
    }
    
    func noQRCameraFound() {
        finishQRScanner()
        self.displaySimpleAlertView(title: "No Camera access", message: "Lumenshine can not access your cammera. Please check your system settings.")
    }
    
    private func finishQRScanner() {
        navigationController?.popViewController(animated: true)
        scanViewController = nil
    }
    
    func setQR(value: String) {
    
        setupForSelectedCurrency()
        
        var destinationSet = false
        
        // Supported qr-code format, see:
        // https://github.com/future-tense/stargazer/blob/master/docs/qr-codes.md
        if let data = value.data(using: String.Encoding.utf8)  {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                let dictionary = json as? [String: Any]
                if let stellarDictionary = dictionary?["stellar"] as? [String: Any] {
                    
                    if let paymentDictionary = stellarDictionary["payment"] as? [String: Any] {
                        
                        if let networkID = paymentDictionary["network"] as? String {
                            var network = Network.public
                            if (!Services.shared.usePublicStellarNetwork) {
                                network = Network.testnet
                            }
                            if (!network.rawValue.sha256().hasPrefix(networkID)) {
                                // not for current network
                                // TODO: add copy button
                                self.displaySimpleAlertView(title: "QR code not supported", message: "The OR-Code refers to an unknown Network and can not be used. Value: " + value)
                                finishQRScanner()
                                return
                            }
                        }
                        
                        if let assetDictionary = paymentDictionary["asset"] as? [String: Any] {
                            if let code = assetDictionary["code"] as? String {
                                if code != "XLM" {
                                    if let issuer = assetDictionary["issuer"] as? String {
                                        // check if wallet has code && issuer
                                        if let requestedCurrency = (wallet as! FundedWallet).balances.first(where: { (currency) -> Bool in
                                            return (currency.assetCode == code && currency.assetIssuer == issuer)
                                        }) {
                                            // select asset code
                                            selectedCurrency = code
                                            
                                            // set issuer if wallet has multiple currencies with this asset code
                                            if (wallet as! FundedWallet).isCurrencyDuplicate(withAssetCode: selectedCurrency) {
                                                    issuerTextField.text = nil
                                                    issuerTextField.insertText(issuer)
                                                    setAvailableAmount()
                                            }
                                        } else { // not available currency
                                            let message = "The QR-Code request a payment with a currency that you do not have in this wallet. Requested currency code is: " + code + " having the issuer public key: " + issuer
                                            self.displaySimpleAlertView(title: "Currency unavailable", message: message)
                                            
                                            finishQRScanner()
                                            return
                                        }
                                    } else
                                    {
                                        // invalid
                                        self.displaySimpleAlertView(title: "Invalid QR-Code", message: "The QR-Code request a payment with non native asset but fails to provide the issuer.")
                                        finishQRScanner()
                                        return
                                    }
                                }
                            }
                        }
                        if let destination = paymentDictionary["destination"] as? String {
                            addressTextField.text = destination
                            destinationSet = true
                        }
                        if let amount = paymentDictionary["amount"] as? Double {
                            amountTextField.text = String(format:"%f", amount)
                        }
                        
                        if let memoDictionary = paymentDictionary["memo"] as? [String: Any] {
                            if let type = memoDictionary["type"] as? String {
                                switch type.trimmed.lowercased() {
                                case "text":
                                    memoView.memoType = MemoTypeValues.MEMO_TEXT.rawValue
                                case "id":
                                    memoView.memoType = MemoTypeValues.MEMO_ID.rawValue
                                case "hash":
                                    memoView.memoType = MemoTypeValues.MEMO_HASH.rawValue
                                case "return":
                                    memoView.memoType = MemoTypeValues.MEMO_RETURN.rawValue
                                default:
                                    break
                                }
                            }
                            if let memo = memoDictionary["value"] as? String {
                                if memo.trimmed != "" {
                                    memoView.memo = memo
                                }
                            }
                        }
                    }
                    else if let accountDictionary  = stellarDictionary["account"] as? [String: Any] {
                        // this is a contact qr-code
                        if let networkID = accountDictionary["network"] as? String {
                            var network = Network.public
                            if (!Services.shared.usePublicStellarNetwork) {
                                network = Network.testnet
                            }
                            if (!network.rawValue.sha256().hasPrefix(networkID)) {
                                // not for current network
                                // TODO: add copy button
                                self.displaySimpleAlertView(title: "QR code not supported", message: "The OR-Code refers to an unknown Network and can not be used. Value: " + value)
                                finishQRScanner()
                                return
                            }
                        }
                        
                        if let accounID = accountDictionary["id"] as? String {
                            addressTextField.text = accounID
                            destinationSet = true
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
        
        if !destinationSet {
            if value.isValidEd25519PublicKey() {
                addressTextField.text = value
                destinationSet = true
            } else {
                // TODO: add copy button
                self.displaySimpleAlertView(title: "QR-Code not supported", message: "The scanned OR-Code is not supported by Lumenshine. Value: " + value)
            }
        }
        
        finishQRScanner()
    }
    
    func clearValuesForNewPayment() {
        wallet = walletsList.first
        if !walletsViewContainer.isHidden {
            walletsView.walletsList = walletsList
        }

        refreshAvailableCurrencies()
        addressTextField.text = nil
        amountTextField.text = nil
        amountSegmentedControl.selectedSegmentIndex = AmountSegmentedControlIndexes.sendAmount.rawValue
        sendAmountView.isHidden = false
        sendAllView.isHidden = true
        availableAmount = nil
        memoView.resetToDefault()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == currencyPickerView {
            return availableCurrencies.count
        } else if pickerView == issuerPickerView {
            return (wallet as! FundedWallet).issuersFor(assetCode: selectedCurrency).count
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == currencyPickerView {
            if availableCurrencies[row] == NativeCurrencyNames.xlm.rawValue {
                return NativeCurrencyNames.stellarLumens.rawValue
            }
            
            return availableCurrencies[row]
        } else if pickerView == issuerPickerView {
            return (wallet as! FundedWallet).issuersFor(assetCode: selectedCurrency)[row]
        }
        
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectAsset(pickerView: pickerView, row: row)
    }
    
    @IBAction func didTapScan(_ sender: Any) {
        showQRScanner()
    }
    
    private func selectAsset(pickerView: UIPickerView, row: Int) {
        if pickerView == currencyPickerView {
            if availableCurrencies[row] == OtherCurrencyText {
                setupForOtherCurrency()
                return
            }
        
            setupForSelectedCurrency()
            selectedCurrency = availableCurrencies[row]
            return
        } else if pickerView == issuerPickerView {
            issuerTextField.text = (wallet as! FundedWallet).issuersFor(assetCode: selectedCurrency)[row]
            return
        }
    }
    
    private func resetSendButtonToNormal() {
        hideActivity()
        sendButton.setTitle(getSendButtonDefaultTitle(), for: UIControl.State.normal)
        sendButton.isEnabled = agreementCheckBox?.isHidden == false ? sendButton.isEnabled : true
    }
    
    private func setupNavigationItem() {
        navigationItem.titleLabel.text = "Send"
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        
        let scanQrButton = Material.IconButton()
        scanQrButton.image = R.image.qr_placeholder()?.crop(toWidth: 25, toHeight: 25)?.tint(with: Stylesheet.color(.white))
        scanQrButton.addTarget(self, action: #selector(didTapScan(_:)), for: .touchUpInside)
        navigationItem.rightViews = [scanQrButton]
    }
    
    override func updateUIAfterWalletRefresh(notification: NSNotification) {
        print ("SendViewController - updateUIAfterWalletRefresh received")
        if let updatedWallet = notification.object as? Wallet, updatedWallet.publicKey == wallet.publicKey {
            wallet = updatedWallet
        }
        DispatchQueue.main.async {
            self.checkForTransactionFeeAvailability()
            self.setAvailableAmount()
        }
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        if url.absoluteString == "goto://ownAssets" {
            let ownAssetsInfoViewController = OwnAssetsInfoViewController()
            let composeVC = ComposeNavigationController(rootViewController: ownAssetsInfoViewController)
            present(composeVC, animated: true)
        }
    }
}
