//
//  TransactionsViewModel.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit.NSTextAttachment

protocol TransactionsViewModelType: Transitionable {
    var itemCount: Int { get }
    var wallets: [String] { get }
    var currencies: [String] { get }
    var reloadClosure: (() -> ())? { get set }
    var showActivityClosure: (() -> ())? { get set }
    var hideActivityClosure: (() -> ())? { get set }
    var filter: TransactionFilter { get set }
    var sorter: TransactionSorter { get set }
    
    func date(at indexPath: IndexPath) -> String?
    func type(at indexPath: IndexPath) -> String?
    func amount(at indexPath: IndexPath) -> NSAttributedString?
    func currency(at indexPath: IndexPath) -> String?
    func feePaid(at indexPath: IndexPath) -> String
    func offer(at indexPath: IndexPath) -> TxOperationResponse?
    func transactionHash(at indexPath: IndexPath) -> String?
    func details(at indexPath: IndexPath) -> NSAttributedString
    
    func itemSelected(at indexPath: IndexPath)
    func filterClick()
    func sortClick()
    
    var walletIndex: Int { get set }
    var currencyIndex: Int { get set }
    var dateFrom: Date { get set }
    var dateTo: Date { get set }
    
    func showPaymentsFilter()
    func showOffersFilter()
    func showOtherFilter()
    func applyFilters()
    func clearFilters()
    
    func applySorter()
    func clearSorter()
    
    func paymentFilterTags() -> [String]
    func offerFilterTags() -> [String]
    func otherFilterTags() -> [String]
    
    func showOperationDetails(operationId: String)
}

enum TransactionType: String, Comparable {
    case paymentReceived
    case paymentSent
    case offerCreated
    case buyOfferCreated
    case offerRemoved
    case offerChanged
    case passiveOfferCreated
    case setOptions
    case changeTrust
    case allowTrust
    case accountMerge
    case manageData
    case bumpSequence
    
    var description: String {
        switch self {
        case .paymentReceived:
            return R.string.localizable.payment_received()
        case .paymentSent:
            return R.string.localizable.payment_sent()
        case .offerCreated:
            return R.string.localizable.offer_created()
        case .buyOfferCreated:
            return R.string.localizable.buy_offer_created()
        case .offerRemoved:
            return R.string.localizable.offer_removed()
        case .offerChanged:
            return R.string.localizable.offer_changed()
        case .passiveOfferCreated:
            return R.string.localizable.passive_offer_created()
        case .setOptions:
            return R.string.localizable.set_options()
        case .changeTrust:
            return R.string.localizable.change_trust()
        case .allowTrust:
            return R.string.localizable.allow_trust()
        case .accountMerge:
            return R.string.localizable.merge_account()
        case .manageData:
            return R.string.localizable.manage_data()
        case .bumpSequence:
            return R.string.localizable.bump_sequence()
        }
    }
    
    static func < (lhs: TransactionType, rhs: TransactionType) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

class TransactionsViewModel : TransactionsViewModelType {
    
    fileprivate let mainFont: UIFont
    
    fileprivate var entries: [TxTransactionResponse] = []
    fileprivate var filteredEntries: [TxTransactionResponse] = []
    fileprivate var currentWalletPK: String
    fileprivate var sortedWallets: [WalletsResponse] = []
    fileprivate var sortedWalletsDetails: [Wallet] = []
    fileprivate var isFiltering: Bool = false
    
    fileprivate var filterBackup: TransactionFilter
    var filter: TransactionFilter
    var sorter: TransactionSorter
    
    weak var navigationCoordinator: CoordinatorType?    
    var reloadClosure: (() -> ())?
    var showActivityClosure: (() -> ())?
    var hideActivityClosure: (() -> ())?
    
    init() {

        self.mainFont = R.font.encodeSansRegular(size: 13) ?? Stylesheet.font(.body)
        
        self.currentWalletPK = PrivateKeyManager.getPublicKey(forIndex: 0)
        
        let startDate = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
        self.filter = TransactionFilter(startDate: startDate, endDate: Date())
        self.filterBackup = TransactionFilter(startDate: Date(), endDate: Date())
        self.sorter = TransactionSorter()
        
        getWallets()
    }
    
    var itemCount: Int {
        if isFiltering {
            return filteredEntries.count
        }
        return entries.count
    }
    
    var wallets: [String] {
        return sortedWallets.map {
            $0.walletName
        }
    }
    
    var walletIndex: Int {
        get {
            return filter.walletIndex
        }
        set(value) {
            filter.walletIndex = value
        }
    }
    
    var currencies: [String] {
        var allCurrencies = [R.string.localizable.all()]
        let wallet = sortedWalletsDetails[walletIndex]
        if wallet.isFunded, let funded = wallet as? FundedWallet {
            allCurrencies += funded.getAvailableCurrencies()
        }
        return allCurrencies
    }
    
    var currencyIndex: Int {
        get {
            return filter.currencyIndex
        }
        set(value) {
            filter.currencyIndex = value
        }
    }
    
    
    var dateFrom: Date {
        get {
            return filter.startDate
        }
        set(value) {
            filter.startDate = value
        }
    }
    
    var dateTo: Date {
        get {
            return filter.endDate
        }
        set(value) {
            filter.endDate = value
        }
    }
    
    func date(at indexPath: IndexPath) -> String? {
        let date = entry(at: indexPath).createdAt
        return DateUtils.format(date, in: .dateAndTime)
    }
    
    func type(at indexPath: IndexPath) -> String? {
        let item = entry(at: indexPath)
        return transactionType(for: item)?.description
    }
    
    func amount(at indexPath: IndexPath) -> NSAttributedString? {
        let item = entry(at: indexPath)
        switch item.operationType {
        case .accountCreated,
             .payment,
             .pathPayment:
            if let amount = formattedAmount(for: item) {
                let color: ColorStyle = transactionType(for: item) == .paymentSent ? .red : .green
                return NSAttributedString(string: amount,
                                          attributes: [.foregroundColor : Stylesheet.color(color)])
            }
        case .manageSellOffer,
             .manageBuyOffer,
             .createPassiveSellOffer:
            if let amount = amount(for: item) {
                return NSAttributedString(string: amount,
                                          attributes: [.foregroundColor : Stylesheet.color(.lightBlack)])
            }
        default: break
        }
        return nil
    }
    
    func currency(at indexPath: IndexPath) -> String? {
        let item = entry(at: indexPath)
        if let currency = self.currency(for: item) {
            if let buying = currency.1 {
                return "\(currency.0) - \(buying)"
            } else {
                return currency.0
            }
        }
        return nil
    }
    
    func offer(at indexPath: IndexPath) -> TxOperationResponse? {
        let item = entry(at: indexPath)
        if let manageOfferItem = item.operationResponse as? TxManageOfferOperationResponse {
            return manageOfferItem
        }
        if let passiveOfferItem = item.operationResponse as? TxCreatePassiveOfferOperationResponse {
            return passiveOfferItem
        }
        return nil
    }
    
    func transactionHash(at indexPath: IndexPath) -> String? {
        let item = entry(at: indexPath)
        return item.transactionHash
    }
    
    func feePaid(at indexPath: IndexPath) -> String {
        let transaction = entry(at: indexPath)
        if currentWalletPK == transaction.sourceAccount {
            let operationFee = (Double(transaction.feePaid)/Double(transaction.operationCount)) * 0.0000001
            return String(format: "%.5f", operationFee)
        }
        return "0.0"
    }
    
    func isHideMemos() -> Bool {
        
        if let hide = UserDefaults.standard.value(forKey: Keys.UserDefs.HideMemos) as? Bool {
            return hide
        }
        return false
    }
    
    func details(at indexPath: IndexPath) -> NSAttributedString {
        let item = entry(at: indexPath)
        var subDetails = NSAttributedString()
        
        switch item.operationType {
        case .accountCreated:
            if let operationItem = item.operationResponse as? TxAccountCreatedOperationResponse {
                subDetails = self.details(accountCreated: operationItem, sourceAccount:item.sourceAccount)
            }
        case .payment:
            if let operationItem = item.operationResponse as? TxPaymentOperationResponse {
                subDetails = self.details(payment: operationItem, sourceAccount:item.sourceAccount)
            }
        case .pathPayment:
            if let operationItem = item.operationResponse as? TxPathPaymentOperationResponse {
                subDetails = self.details(pathPayment: operationItem, sourceAccount:item.sourceAccount)
            }
        case .manageSellOffer:
            if let operationItem = item.operationResponse as? TxManageSellOfferOperationResponse {
                subDetails = self.details(manageOffer: operationItem, sourceAccount:item.sourceAccount)
            }
        case .manageBuyOffer:
            if let operationItem = item.operationResponse as? TxManageBuyOfferOperationResponse {
                subDetails = self.details(manageOffer: operationItem, sourceAccount:item.sourceAccount)
            }
        case .createPassiveSellOffer:
            if let operationItem = item.operationResponse as? TxCreatePassiveSellOfferOperationResponse {
                subDetails = self.details(passiveOffer: operationItem, sourceAccount: item.sourceAccount)
            }
        case .setOptions:
            if let operationItem = item.operationResponse as? TxSetOptionsOperationResponse {
                subDetails = self.details(setOptions: operationItem, sourceAccount:item.sourceAccount)
            }
        case .changeTrust:
            if let operationItem = item.operationResponse as? TxChangeTrustOperationResponse {
                subDetails = self.details(changeTrust: operationItem, sourceAccount:item.sourceAccount)
            }
        case .allowTrust:
            if let operationItem = item.operationResponse as? TxAllowTrustOperationResponse {
                subDetails = self.details(allowTrust: operationItem, sourceAccount: item.sourceAccount)
            }
        case .accountMerge:
            if let operationItem = item.operationResponse as? TxAccountMergeOperationResponse {
                subDetails = self.details(accountMerge: operationItem, sourceAccount: item.sourceAccount)
            }
        case .inflation:
            break
        case .manageData:
            if let operationItem = item.operationResponse as? TxManageDataOperationResponse {
                subDetails = self.details(manageData: operationItem, sourceAccount: item.sourceAccount)
            }
        case .bumpSequence:
            if let operationItem = item.operationResponse as? TxBumpSequenceOperationResponse {
                subDetails = self.details(bumpSequence: operationItem, sourceAccount: item.sourceAccount)
            }
        }
        
        let details = NSMutableAttributedString()
        details.append(subDetails)
        
        if !item.memo.isEmpty && !self.isHideMemos() {
            details.append(NSAttributedString(string: "\(R.string.localizable.memo()): \(item.memo)\n",
                attributes: [.font : mainFont,
                             .foregroundColor : Stylesheet.color(.lightBlack)]))
        }
        let opIdLabel = NSAttributedString(string: R.string.localizable.operation_id() + ": ",
                                           attributes: [.font : mainFont,
                                                        .foregroundColor : Stylesheet.color(.lightBlack)])
        
        let link = Services.shared.transactions.baseURL.appending("/\(item.opId)")
        let operationIdValue = NSAttributedString(string: String(item.opId),
                                                  attributes: [.font : mainFont,
                                                               .foregroundColor : Stylesheet.color(.blue),
                                                               .link :  link])
        
        
        details.append(opIdLabel)
        details.append(operationIdValue)
    
        return details
    }
    
    func itemSelected(at indexPath:IndexPath) {
        
    }
    
    func filterClick() {
        navigationCoordinator?.performTransition(transition: .showTransactionFilter)
    }
    
    func sortClick() {
        navigationCoordinator?.performTransition(transition: .showTransactionSorter)
    }
    
    func showPaymentsFilter() {
        navigationCoordinator?.performTransition(transition: .showPaymentsFilter)
    }
    
    func showOffersFilter() {
        navigationCoordinator?.performTransition(transition: .showOffersFilter)
    }
    
    func showOtherFilter() {
        navigationCoordinator?.performTransition(transition: .showOtherFilter)
    }
    
    func applyFilters() {
        isFiltering = filter.payment.include || filter.offer.include || filter.other.include || !filter.memo.isEmpty ||
            paymentFilterTags().count > 0 || offerFilterTags().count > 0 || otherFilterTags().count > 0
        
        if filter.walletIndex != filterBackup.walletIndex ||
            filter.startDate != filterBackup.startDate ||
            filter.endDate != filterBackup.endDate {
            if let closure = self.showActivityClosure {
                closure()
            }
            updateTransactions()
        } else {
            filteredEntries = entries.filter {
                return filter(item: $0)
            }
            if let closure = self.reloadClosure {
                closure()
            }
        }
        filterBackup = filter
    }
    
    func clearFilters() {
        filter.clear()
        filterBackup.clear()
        isFiltering = false
        self.reloadClosure?()
    }
    
    func paymentFilterTags() -> [String] {
        var tags = [String]()
        if let range = filter.payment.receivedRange {
            if range.upperBound == Double.infinity {
                tags.append("Received")
            } else {
                tags.append("Received:\(range.lowerBound)-\(range.upperBound)")
            }
        }
        if let range = filter.payment.sentRange {
            if range.upperBound == Double.infinity {
                tags.append("Sent")
            } else {
                tags.append("Sent:\(range.lowerBound)-\(range.upperBound)")
            }
        }
        if let currency = filter.payment.currency {
            tags.append(currency)
        }
        return tags
    }
    
    func offerFilterTags() -> [String] {
        var tags = [String]()
        if let currency = filter.offer.sellingCurrency {
            if currency.isEmpty {
                tags.append("Selling")
            } else {
                tags.append("Selling:\(currency)")
            }
        }
        if let currency = filter.offer.buyingCurrency {
            if currency.isEmpty {
                tags.append("Buying")
            } else {
                tags.append("Buying:\(currency)")
            }
        }
        return tags
    }
    
    func otherFilterTags() -> [String] {
        var tags = [String]()
        if filter.other.setOptions ?? false {
            tags.append(R.string.localizable.set_options())
        }
        if filter.other.manageData ?? false {
            tags.append(R.string.localizable.manage_data())
        }
        if filter.other.trust ?? false {
            tags.append(R.string.localizable.trust())
        }
        if filter.other.accountMerge ?? false {
            tags.append(R.string.localizable.merge_account())
        }
        if filter.other.bumpSequence ?? false {
            tags.append(R.string.localizable.bump_sequence())
        }
        return tags
    }
    
    func applySorter() {
        setupEntries(transactions: entries)
        self.reloadClosure?()
    }
    
    func clearSorter() {
        sorter.clear()
        setupEntries(transactions: entries)
        self.reloadClosure?()
    }
    
    func showOperationDetails(operationId: String) {
        
        let requestUrl = Services.shared.horizonURL + "/operations/" + operationId
        Services.shared.walletService.GETRequestFromUrl(url: requestUrl) { (result) -> (Void) in
            DispatchQueue.main.async {
                switch result {
                case .success (let data):
                    self.navigationCoordinator?.performTransition(transition: .showTransactionDetails(data))
                case .failure(_):
                    self.navigationCoordinator?.baseController.displaySimpleAlertView(title: R.string.localizable.error(), message: R.string.localizable.operation_details_load_error())
                }
            }
        }
    }
}

// MARK: remote methods
fileprivate extension TransactionsViewModel {
    
    func updateTransactions() {
        if sortedWallets.count > walletIndex {
            currentWalletPK = sortedWallets[walletIndex].publicKey
        }
        let startDate = DateUtils.format(dateFrom, in: .dateAndTime) ?? Date().description
        let endDate = DateUtils.format(dateTo, in: .dateAndTime) ?? Date().description
        Services.shared.transactions.getTransactions(stellarAccount: currentWalletPK, startTime: startDate, endTime: endDate) { [weak self] result in
            switch result {
            case .success(let transactions):
                self?.setupEntries(transactions: transactions)
                if let closure = self?.reloadClosure {
                    closure()
                }
                break
            case .failure(let error):
                // TODO show error to user
                print("Transactions list failure: \(error)")
                self?.setupEntries(transactions: [])
                if let closure = self?.reloadClosure {
                    closure()
                }
            }
            if let closure = self?.hideActivityClosure {
                closure()
            }
        }
    }
    
    func getWallets() {
        Services.shared.walletService.getWallets(reload:false) { [weak self] (result) -> (Void) in
            switch result {
            case .success(let wallets):
                self?.sortedWallets = wallets.sorted(by: { $0.id < $1.id })
                self?.getWalletDetails(wallets: wallets)
            case .failure(_):
                // TODO show error to user
                print("Failed to get wallets")
            }
        }
    }
    
    func getWalletDetails(wallets: [WalletsResponse]) {
        Services.shared.userManager.walletDetailsFor(wallets: wallets) { result in
            switch result {
            case .success(let wallets):
                self.sortedWalletsDetails = wallets.sorted(by: { $0.id < $1.id })
            case .failure(let error):
                // TODO show error to user
                print("Account details failure: \(error)")
            }
        }
    }
}

fileprivate extension TransactionsViewModel {
    func entry(at indexPath: IndexPath) -> TxTransactionResponse {
        let items = isFiltering ? filteredEntries : entries
        return items[indexPath.row]
    }
    
    func setupEntries(transactions: [TxTransactionResponse]) {
        entries = transactions
        entries.sort(by:) {
            return sorter(lhs: $0, rhs: $1)
        }
        if isFiltering {
            filteredEntries = entries.filter {
                return filter(item: $0)
            }
        }
    }
    
    func formattedAmount(for item: TxTransactionResponse) -> String? {
        if let amountForItem = amount(for: item) {
            return Services.shared.walletService.formatAmount(amount: amountForItem)
        }
        return nil
    }
    
    func amount(for item: TxTransactionResponse) -> String? {
        switch item.operationType {
        case .accountCreated:
            if let amountVal = (item.operationResponse as? TxAccountCreatedOperationResponse)?.startingBalance {
                return amountVal
            }
            break
        case .payment:
            if let amountVal = (item.operationResponse as? TxPaymentOperationResponse)?.amount {
                return amountVal
            }
            break
        case .pathPayment:
            if let subItem = item.operationResponse as? TxPathPaymentOperationResponse {
                let amountVal = transactionType(for: item) == .paymentSent ? subItem.sourceAmount : subItem.amount
                return amountVal
            }
            break
        case .manageSellOffer:
            if let amountVal = (item.operationResponse as? TxManageSellOfferOperationResponse)?.amount {
                return amountVal
            }
            break
        case .manageBuyOffer:
            if let amountVal = (item.operationResponse as? TxManageBuyOfferOperationResponse)?.amount {
                return amountVal
            }
            break
        case .createPassiveSellOffer:
            if let amountVal = (item.operationResponse as? TxCreatePassiveSellOfferOperationResponse)?.amount {
                return amountVal
            }
            break
        default:
            break
        }
        return nil
    }
    
    func currency(for item: TxTransactionResponse) -> (String, String?)? {
        switch item.operationType {
        case .accountCreated:
            return (NativeCurrencyNames.xlm.rawValue, nil)
        case .payment:
            if let item = item.operationResponse as? TxPaymentOperationResponse {
                return (item.assetCode ?? NativeCurrencyNames.xlm.rawValue, nil)
            }
        case .pathPayment:
            if let subitem = item.operationResponse as? TxPathPaymentOperationResponse {
                let currency = transactionType(for: item) == .paymentSent ? subitem.sendAssetCode : subitem.assetCode
                return (currency ?? NativeCurrencyNames.xlm.rawValue, nil)
            }
        case .manageSellOffer:
            if let item = item.operationResponse as? TxManageSellOfferOperationResponse {
                let selling = item.sellingAssetCode ?? NativeCurrencyNames.xlm.rawValue
                let buying = item.buyingAssetCode ?? NativeCurrencyNames.xlm.rawValue
                return (selling, buying)
            }
        case .manageBuyOffer:
            if let item = item.operationResponse as? TxManageBuyOfferOperationResponse {
                let selling = item.sellingAssetCode ?? NativeCurrencyNames.xlm.rawValue
                let buying = item.buyingAssetCode ?? NativeCurrencyNames.xlm.rawValue
                return (selling, buying)
            }
        case .createPassiveSellOffer:
            if let item = item.operationResponse as? TxCreatePassiveSellOfferOperationResponse {
                let selling = item.sellingAssetCode ?? NativeCurrencyNames.xlm.rawValue
                let buying = item.buyingAssetCode ?? NativeCurrencyNames.xlm.rawValue
                return (selling, buying)
            }
        case .changeTrust:
            if let item = item.operationResponse as? TxChangeTrustOperationResponse {
                return (item.assetCode ?? NativeCurrencyNames.xlm.rawValue, nil)
            }
        case .allowTrust:
            if let item = item.operationResponse as? TxAllowTrustOperationResponse {
                return (item.assetCode ?? NativeCurrencyNames.xlm.rawValue, nil)
            }
        default:
            break
        }
        return nil
    }
    
    func transactionType(for item: TxTransactionResponse) -> TransactionType? {
        switch item.operationType {
        case .accountCreated:
            return item.sourceAccount == currentWalletPK ? .paymentSent : .paymentReceived
        case .payment:
            if let item = item.operationResponse as? TxPaymentOperationResponse {
                return item.to == currentWalletPK ? .paymentReceived : .paymentSent
            }
        case .pathPayment:
            if let item = item.operationResponse as? TxPathPaymentOperationResponse {
                return item.to == currentWalletPK ? .paymentReceived : .paymentSent
            }
        case .manageSellOffer,
             .manageBuyOffer:
            if let item = item.operationResponse as? TxManageOfferOperationResponse {
    
                if item.offerId == 0 {
                    if let _ = item as? TxManageBuyOfferOperationResponse {
                        return  .buyOfferCreated
                    }
                    return .offerCreated
                }
                
                let amount = item.amount.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "0", with: "")
                
                if amount.isEmpty {
                    return .offerRemoved
                }
                
                return .offerChanged
            }
        case .createPassiveSellOffer:
            return .passiveOfferCreated
        case .setOptions:
            return .setOptions
        case .changeTrust:
            return .changeTrust
        case .allowTrust:
            return .allowTrust
        case .accountMerge:
            return .accountMerge
        case .manageData:
            return .manageData
        case .bumpSequence:
            return .bumpSequence
        default:
            break
        }
        return nil
    }
    
    func filter(item: TxTransactionResponse) -> Bool {
        let type = transactionType(for: item)
        
        if !filter.memo.isEmpty {
            return item.memo.contains(filter.memo)
        }
        
        var paymentReceivedFlag = false
        if type == .paymentReceived {
            if let range = filter.payment.receivedRange {
                if let amount = self.amount(for: item),
                    let dAmount = Double(amount) {
                    paymentReceivedFlag = range.contains(dAmount)
                } else {
                    paymentReceivedFlag = false
                }
            } else {
               paymentReceivedFlag = filter.payment.include
            }
        }
        
        var paymentSentFlag = false
        if type == .paymentSent {
            if let range = filter.payment.sentRange {
                if let amount = self.amount(for: item),
                    let dAmount = Double(amount) {
                    paymentSentFlag = range.contains(dAmount)
                } else {
                    paymentSentFlag = false
                }
            } else {
                paymentSentFlag = filter.payment.include
            }
        }
        
        var currencyFlag = false
        if type == .paymentSent || type == .paymentReceived {
            if let currency = filter.payment.currency {
                if let curr = self.currency(for: item) {
                    currencyFlag = currency.lowercased() == curr.0.lowercased()
                }
                currencyFlag = currencyIndex == 0 || currencyFlag
            } else {
                currencyFlag = paymentReceivedFlag || paymentSentFlag
            }
        }
        
        // only currency flag is On
        if currencyFlag == true, filter.payment.receivedRange == nil, filter.payment.sentRange == nil {
            paymentReceivedFlag = true
        }
        
        var sellingFlag = false
        if item.operationType == .manageSellOffer || item.operationType == .createPassiveSellOffer {
            if let selling = filter.offer.sellingCurrency {
                if let curr = self.currency(for: item) {
                    sellingFlag = selling.isEmpty ? true : curr.0.contains(selling)
                } else {
                    sellingFlag = false
                }
            } else {
                sellingFlag = filter.offer.include
            }
        }
        
        var buyingFlag = false
        if (item.operationType == .manageBuyOffer) {
            if let buying = filter.offer.buyingCurrency {
                if let curr = self.currency(for: item) {
                    buyingFlag = buying.isEmpty ? true : curr.1?.contains(buying) ?? false
                } else {
                    buyingFlag = false
                }
            } else {
                buyingFlag = sellingFlag
            }
        }
        
        var setOptionsFlag = false
        if item.operationType == .setOptions {
            setOptionsFlag = filter.other.setOptions ?? filter.other.include
        }
        
        var manageDataFlag = false
        if item.operationType == .manageData {
            manageDataFlag = filter.other.manageData ?? filter.other.include
        }
        
        var trustFlag = false
        if item.operationType == .allowTrust || item.operationType == .changeTrust {
            trustFlag = filter.other.trust ?? filter.other.include
        }
        
        var accountMergeFlag = false
        if item.operationType == .accountMerge {
            accountMergeFlag = filter.other.accountMerge ?? filter.other.include
        }
        
        var bumpSequenceFlag = false
        if item.operationType == .bumpSequence {
            bumpSequenceFlag = filter.other.bumpSequence ?? filter.other.include
        }
        
        return
            ((paymentReceivedFlag || paymentSentFlag) && currencyFlag) ||
            (sellingFlag && buyingFlag) ||
            setOptionsFlag ||
            manageDataFlag ||
            trustFlag ||
            accountMergeFlag ||
            bumpSequenceFlag
    }
    
    func sorter(lhs: TxTransactionResponse, rhs: TxTransactionResponse) -> Bool {
        if let typeSorter = sorter.type {
            guard let lhsType = transactionType(for: lhs) else { return typeSorter }
            guard let rhsType = transactionType(for: rhs) else { return !typeSorter }
            if lhsType < rhsType {
                return typeSorter
            }
            if lhsType > rhsType {
                return !typeSorter
            }
        }
        
        if let amountSorter = sorter.amount {
            guard let lhsAmount = amount(for: lhs) else { return amountSorter }
            guard let rhsAmount = amount(for: rhs) else { return !amountSorter }
            if let dlhsAmount = Double(lhsAmount), let drhsAmount = Double(rhsAmount) {
                if dlhsAmount < drhsAmount {
                    return amountSorter
                }
                if dlhsAmount > drhsAmount {
                    return !amountSorter
                }
            } else {
                return !amountSorter
            }
        }
        
        if let currencySorter = sorter.currency {
            guard let lhsCurrency = self.currency(for: lhs) else { return !currencySorter }
            guard let rhsCurrency = self.currency(for: rhs) else { return currencySorter }
            if lhsCurrency.0 < rhsCurrency.0 {
                return currencySorter
            }
            if lhsCurrency.0 > rhsCurrency.0 {
                return !currencySorter
            }
        }
        
        if let dateSorter = sorter.date {
            if lhs.createdAt < rhs.createdAt {
                return dateSorter
            }
            if lhs.createdAt > rhs.createdAt {
                return !dateSorter
            }
        }
        
        return true
    }
}

// MARK: Operation details

fileprivate extension TransactionsViewModel {
    
    func details(accountCreated: TxAccountCreatedOperationResponse, sourceAccount: String) -> NSAttributedString {
    
        let result = NSMutableAttributedString()
        
        if accountCreated.funder == currentWalletPK {
            let recepient = prepareKeyString(prefix: R.string.localizable.recipient(), value: accountCreated.account)
            result.append(recepient)
            if sourceAccount != currentWalletPK {
                let source = prepareKeyString(prefix: R.string.localizable.source_account(), value: sourceAccount)
                result.append(source)
            }
        } else if accountCreated.account == currentWalletPK {
            let sender = prepareKeyString(prefix: R.string.localizable.sender(), value: accountCreated.funder)
            result.append(sender)
            if sourceAccount != accountCreated.funder {
                let source = prepareKeyString(prefix: R.string.localizable.source_account(), value: sourceAccount)
                result.append(source)
            }
        }

        return result
    }
    
    func details(payment: TxPaymentOperationResponse, sourceAccount: String) -> NSAttributedString {
        
        let result = NSMutableAttributedString()
        if (payment.to == currentWalletPK) {
            result.append(prepareKeyString(prefix: R.string.localizable.sender(), value: payment.from))
            if sourceAccount != payment.from {
                let source = prepareKeyString(prefix: R.string.localizable.source_account(), value: sourceAccount)
                result.append(source)
            }
        } else if (payment.from == currentWalletPK) {
            result.append(prepareKeyString(prefix: R.string.localizable.recipient(), value: payment.to))
            if sourceAccount != currentWalletPK {
                let source = prepareKeyString(prefix: R.string.localizable.source_account(), value: sourceAccount)
                result.append(source)
            }
        }
        
        return result
    }
    
    func details(pathPayment: TxPathPaymentOperationResponse, sourceAccount: String) -> NSAttributedString {
        let result = NSMutableAttributedString()
        if (pathPayment.to == currentWalletPK) {
            result.append(prepareKeyString(prefix: R.string.localizable.sender(), value: pathPayment.from))
            if sourceAccount != pathPayment.from {
                let source = prepareKeyString(prefix: R.string.localizable.source_account(), value: sourceAccount)
                result.append(source)
            }
        } else if (pathPayment.from == currentWalletPK) {
            result.append(prepareKeyString(prefix: R.string.localizable.recipient(), value: pathPayment.to))
            if sourceAccount != currentWalletPK {
                let source = prepareKeyString(prefix: R.string.localizable.source_account(), value: sourceAccount)
                result.append(source)
            }
        }
        
        return result
    }
    
    func details(manageOffer: TxManageOfferOperationResponse, sourceAccount: String) -> NSAttributedString {
        
        let amount = Services.shared.walletService.formatAmount(amount: manageOffer.amount)
        
        let buyingCode = manageOffer.buyingAssetCode ?? NativeCurrencyNames.xlm.rawValue
        var buying = NSAttributedString(string: "\(R.string.localizable.buying()): \(buyingCode)\n",
            attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                         .font : mainFont])
        let sellingCode = manageOffer.sellingAssetCode ?? NativeCurrencyNames.xlm.rawValue
        var selling = NSAttributedString(string: "\(R.string.localizable.selling()): \(amount) \(sellingCode)\n",
            attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                         .font : mainFont])
        
        var price = NSAttributedString(string: "\(R.string.localizable.price_for_asset()): \(Services.shared.walletService.formatAmount(amount: manageOffer.price))\n",
            attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                         .font : mainFont])
        
        if let _ = manageOffer as? TxManageBuyOfferOperationResponse {
            buying = NSAttributedString(string: "\(R.string.localizable.buying()): \(amount) \(buyingCode)\n",
                attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                             .font : mainFont])
            selling = NSAttributedString(string: "\(R.string.localizable.selling()): \(sellingCode)\n",
                attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                             .font : mainFont])
            price = NSAttributedString(string: "\(R.string.localizable.price_for_buy_asset()): \(Services.shared.walletService.formatAmount(amount: manageOffer.price))\n",
                attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                             .font : mainFont])
            
        }
        
        let details = NSMutableAttributedString(attributedString: buying)
        details.append(selling)
        details.append(price)
        
        if sourceAccount != currentWalletPK {
            let source = prepareKeyString(prefix: R.string.localizable.source_account(), value: sourceAccount)
            details.append(source)
        }
        
        return details
    }
    
    func details(passiveOffer: TxCreatePassiveOfferOperationResponse, sourceAccount:String) -> NSAttributedString {
        
        let details = NSMutableAttributedString()
        
        let buyingCode = passiveOffer.buyingAssetCode ?? NativeCurrencyNames.xlm.rawValue
        let buying = NSAttributedString(string: "\(R.string.localizable.buying()): \(buyingCode)\n",
            attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                         .font : mainFont])
        
        let sellingAmount = passiveOffer.amount
        let sellingCode = passiveOffer.sellingAssetCode ?? NativeCurrencyNames.xlm.rawValue
        let selling = NSAttributedString(string: "\(R.string.localizable.selling()): \(Services.shared.walletService.formatAmount(amount: sellingAmount)) \(sellingCode)\n",
            attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                         .font : mainFont])
        
        let price = NSAttributedString(string: "\(R.string.localizable.price_for_asset()): \(Services.shared.walletService.formatAmount(amount:passiveOffer.price))\n",
            attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                         .font : mainFont])
        
        details.append(buying)
        details.append(selling)
        details.append(price)
        
        if sourceAccount != currentWalletPK {
            let source = prepareKeyString(prefix: R.string.localizable.source_account(), value: sourceAccount)
            details.append(source)
        }
        
        return details
    }
    
    func details(setOptions: TxSetOptionsOperationResponse, sourceAccount: String) -> NSAttributedString {
        let details = NSMutableAttributedString()
        if let inflationPK = setOptions.inflationDestination {
            let pkStr = prepareKeyString(prefix: R.string.localizable.inflation_dest(), value: inflationPK)
            details.append(pkStr)
        }
        
        if let setFlags = setOptions.setFlagsString{
            if setFlags.count > 0 {
                let flagStr = setFlags.joined(separator: ", ")
                let setFlagStr = NSAttributedString(string: "\(R.string.localizable.set_flags()): \(flagStr)\n",
                    attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                                 .font : mainFont])
                
                details.append(setFlagStr)
            }
        }
        
        if let clearFlags = setOptions.clearFlagsString {
            if clearFlags.count > 0 {
                let flagStr = clearFlags.joined(separator: ", ")
                let setFlagStr = NSAttributedString(string: "\(R.string.localizable.clear_flags()): \(flagStr)\n",
                    attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                                 .font : mainFont])
                
                details.append(setFlagStr)
            }
        }
        
        if let masterWeight = setOptions.masterKeyWeight {
            let weight = NSAttributedString(string: "\(R.string.localizable.master_weight()): \(masterWeight)\n",
                attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                             .font : mainFont])
            
            details.append(weight)
        }
        
        if let lowThreshold = setOptions.lowThreshold {
            let threshold = NSAttributedString(string: "\(R.string.localizable.low_threshold()): \(lowThreshold)\n",
                attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                             .font : mainFont])
            
            details.append(threshold)
        }
        
        if let medThreshold = setOptions.medThreshold {
            let threshold = NSAttributedString(string: "\(R.string.localizable.med_threshold()): \(medThreshold)\n",
                attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                             .font : mainFont])
            
            details.append(threshold)
        }
        
        if let highThreshold = setOptions.highThreshold {
            let threshold = NSAttributedString(string: "\(R.string.localizable.high_threshold()): \(highThreshold)\n",
                attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                             .font : mainFont])
            
            details.append(threshold)
        }
        
        if let signerWeight = setOptions.signerWeight,
            let signerKey = setOptions.signerKey {
            let signer = prepareKeyString(prefix: R.string.localizable.signer_key(), value: signerKey)
            
            var type = ""
            switch signerKey.first {
            case "G":
                type = R.string.localizable.ed_public_key()
            case "X":
                type = R.string.localizable.sha256_hash()
            case "T":
                type = R.string.localizable.pre_auth_hash()
            default:
                break
            }
            
            let signerType = NSAttributedString(string: "\(R.string.localizable.signer_type()): \(type)\n",
                attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                             .font : mainFont])
            
            var weight = String(signerWeight)
            if signerWeight == 0 {
                weight = "0 \(R.string.localizable.signer_remove())"
            }
            
            let signerWeightStr = NSAttributedString(string: "\(R.string.localizable.signer_weight()): \(weight)\n",
                attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                             .font : mainFont])
            
            details.append(signer)
            details.append(signerType)
            details.append(signerWeightStr)
        }
        
        if let homeDomain = setOptions.homeDomain {
            let domain = NSMutableAttributedString(string: R.string.localizable.home_domain() + ": " ,attributes: [.foregroundColor : Stylesheet.color(.lightBlack),.font : mainFont])
            let domainLink = NSAttributedString(string: "\(homeDomain)\n",
                attributes: [.foregroundColor : Stylesheet.color(.lightBlack), // TODO make link
                             .font : mainFont])
            
            domain.append(domainLink)
            details.append(domain)
        }
        
        return details
    }
    
    func details(changeTrust: TxChangeTrustOperationResponse, sourceAccount: String) -> NSAttributedString {
        
        let result = NSMutableAttributedString()
        
        var issuer = NSAttributedString()
        if let issuerr = changeTrust.assetIssuer {
            issuer = prepareKeyString(prefix: R.string.localizable.issuer(), value: issuerr)
        }
        result.append(issuer)
        
        let code = changeTrust.assetCode ?? NativeCurrencyNames.xlm.rawValue
        let asset = NSAttributedString(string: "\(R.string.localizable.asset_code()): \(code)\n",
            attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                         .font : mainFont])
        
        result.append(asset)
        
        var limit = changeTrust.limit ?? R.string.localizable.none()
        
        if limit != R.string.localizable.none() {
            limit = Services.shared.walletService.formatAmount(amount: limit)
        }
        
        let trustLimit = NSAttributedString(string: "\(R.string.localizable.trust_limit()): \(limit)\n",
            attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                         .font : mainFont])
        
        result.append(trustLimit)
        
        let limitString = (changeTrust.limit ?? "0.00").replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "0", with: "")
        
        var type = R.string.localizable.add_trustline()
        if limitString.isEmpty {
            type = R.string.localizable.remove_trustline()
        }
        
        let typeValue = NSAttributedString(string: "\(R.string.localizable.type()): \(type)\n",
                                      attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                                                   .font : mainFont])
        
        result.append(typeValue)
        
        if sourceAccount != currentWalletPK {
            let source = prepareKeyString(prefix: R.string.localizable.source_account(), value: sourceAccount)
            result.append(source)
        }
        
        return result
        
    }
    
    func details(allowTrust: TxAllowTrustOperationResponse, sourceAccount: String) -> NSAttributedString {
        let trustor = prepareKeyString(prefix: R.string.localizable.trustor(), value: allowTrust.trustor)
        
        let code = allowTrust.assetCode ?? NativeCurrencyNames.xlm.rawValue
        let asset = NSAttributedString(string: "\(R.string.localizable.asset_code()): \(code)\n",
                                       attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                                                    .font : mainFont])
        
        let authorize = NSAttributedString(string: "\(R.string.localizable.authorize()): \(allowTrust.authorize.description)\n",
                                           attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                                                        .font : mainFont])
        
        let details = NSMutableAttributedString(attributedString: trustor)
        details.append(asset)
        details.append(authorize)
        
        if sourceAccount != currentWalletPK {
            let source = prepareKeyString(prefix: R.string.localizable.source_account(), value: sourceAccount)
            details.append(source)
        }
        
        return details
    }
    
    func details(accountMerge: TxAccountMergeOperationResponse, sourceAccount: String) -> NSAttributedString {
        
        let details = NSMutableAttributedString()
        
        if accountMerge.into == currentWalletPK {
            details.append(NSMutableAttributedString(attributedString: prepareKeyString(prefix: R.string.localizable.merged_account(), value: accountMerge.account)))
        } else if accountMerge.account == currentWalletPK {
            details.append(NSMutableAttributedString(attributedString: prepareKeyString(prefix: R.string.localizable.into_account(), value: accountMerge.into)))
        }
        
        if sourceAccount != accountMerge.account {
            let source = prepareKeyString(prefix: R.string.localizable.source_account(), value: sourceAccount)
            details.append(source)
        }
        
        
        return details
    }
    
    func details(manageData: TxManageDataOperationResponse, sourceAccount:String) -> NSAttributedString {
        let name = NSAttributedString(string: "\(R.string.localizable.entry_name()): \(manageData.name)\n",
            attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                         .font : mainFont])
        
        let details = NSMutableAttributedString(attributedString: name)
        
        var displayValue = ""
        if let newValue = manageData.value {
            if !newValue.isEmpty {
                if let base64 = Data(base64Encoded: newValue),
                    let text = String(data: base64, encoding: .utf8) {
                    displayValue = text
                } else {
                    displayValue = newValue
                }
            }
        }
        
        if displayValue != "" {
            let value = NSAttributedString(string: "\(R.string.localizable.entry_value()): \(displayValue)\n",
                attributes: [.foregroundColor : Stylesheet.color(.lightBlack), .font : mainFont])
        
            details.append(value)
        }
        else {
            details.append(NSAttributedString(string:"\(R.string.localizable.entry_deleted())\n", attributes: [.foregroundColor : Stylesheet.color(.red),.font : mainFont]))
        }
        
        if sourceAccount != currentWalletPK {
            let source = prepareKeyString(prefix: R.string.localizable.source_account(), value: sourceAccount)
            details.append(source)
        }
        
        return details
    }
    
    func details(bumpSequence: TxBumpSequenceOperationResponse, sourceAccount: String) -> NSAttributedString {
        let bump = NSAttributedString(string: "\(R.string.localizable.bumped_to()): \(bumpSequence.bumpTo)\n",
                                      attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                                                   .font : mainFont])
        
        let details = NSMutableAttributedString(attributedString: bump)
        
        if sourceAccount != currentWalletPK {
            let source = prepareKeyString(prefix: R.string.localizable.source_account(), value: sourceAccount)
            details.append(source)
        }
        
        return details
    }
    
    func prepareKeyString(prefix: String, value: String) -> NSAttributedString {
        var startIndex = 9
        var endIndex = -10
        if (prefix == R.string.localizable.inflation_dest()) {
            startIndex = 6
            endIndex = -7
        }
        let start = value.index(value.startIndex, offsetBy: startIndex)
        let end = value.index(value.endIndex, offsetBy: endIndex)
        let truncatedValue = value.replacingCharacters(in: start...end, with: "...")
        
        let pkStr = NSAttributedString(string: "\(prefix): \(truncatedValue)",
            attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                         .font : mainFont])
        
        let attachment = LSTextAttachment(info: value)
        attachment.image = R.image.copy()?.resize(toHeight: 25)?.tint(with: Stylesheet.color(.darkBlue))
        let copyStr = NSAttributedString(attachment: attachment)
        
        let details = NSMutableAttributedString(attributedString: pkStr)
        details.append(copyStr)
        details.append(NSAttributedString(string: "\n"))
        
        return details
    }
}
