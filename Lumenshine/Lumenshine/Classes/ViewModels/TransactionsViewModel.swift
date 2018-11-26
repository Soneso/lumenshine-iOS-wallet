//
//  TransactionsViewModel.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 02/11/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit.NSTextAttachment

protocol TransactionsViewModelType: Transitionable {
    var itemCount: Int { get }
    var wallets: [String] { get }
    var reloadClosure: (() -> ())? { get set }
    var filter: TransactionFilter { get set }
    
    func date(at indexPath: IndexPath) -> String?
    func type(at indexPath: IndexPath) -> String?
    func amount(at indexPath: IndexPath) -> NSAttributedString?
    func currency(at indexPath: IndexPath) -> String?
    func feePaid(at indexPath: IndexPath) -> String
    func details(at indexPath: IndexPath) -> NSAttributedString
    
    func itemSelected(at indexPath: IndexPath)
    func filterClick()
    func sortClick()
    
    var walletIndex: Int { get set }
    var dateFrom: Date { get set }
    var dateTo: Date { get set }
    func memoChanged(_ memo: String)
    
    func showPaymentsFilter()
    func showOffersFilter()
    func showOtherFilter()
}

class TransactionsViewModel : TransactionsViewModelType {
    
    fileprivate let services: Services
    fileprivate let user: User?
    fileprivate let mainFont: UIFont
    
    fileprivate var entries: [TxTransactionResponse] = []
    fileprivate var currentWalletPK: String
    fileprivate var startDate: String
    fileprivate var endDate: String
    fileprivate var sortedWallets: [WalletsResponse] = []
    fileprivate var memo: String?
    
    var filter: TransactionFilter
    
    weak var navigationCoordinator: CoordinatorType?    
    var reloadClosure: (() -> ())?
    
    init(service: Services, user: User?) {
        self.services = service
        self.user = user
        self.mainFont = R.font.encodeSansRegular(size: 13) ?? Stylesheet.font(.body)
        
        self.currentWalletPK = PrivateKeyManager.getPublicKey(forIndex: 0)
        self.dateFrom = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        self.dateTo = Date()
        self.startDate = DateUtils.format(dateFrom, in: .dateAndTime) ?? Date().description
        self.endDate = DateUtils.format(dateTo, in: .dateAndTime) ?? Date().description
        self.walletIndex = 0        
        self.filter = TransactionFilter()
        
        updateTransactions()
        
        services.walletService.getWallets { [weak self] (result) -> (Void) in
            switch result {
            case .success(let wallets):
                self?.sortedWallets = wallets.sorted(by: { $0.id < $1.id })
            case .failure(_):
                print("Failed to get wallets")
            }
        }
    }
    
    var itemCount: Int {
        return entries.count
    }
    
    var wallets: [String] {
        return sortedWallets.map {
            $0.walletName
        }
    }
    
    var walletIndex: Int {
        didSet {
            self.currentWalletPK = sortedWallets[walletIndex].publicKey
        }
    }
    
    var dateFrom: Date {
        didSet {
            startDate = DateUtils.format(dateFrom, in: .dateAndTime) ?? startDate
        }
    }
    
    var dateTo: Date {
        didSet {
            endDate = DateUtils.format(dateTo, in: .dateAndTime) ?? endDate
        }
    }
    
    func memoChanged(_ memo: String) {
        self.memo = memo
    }
    
    func updateTransactions() {
        services.transactions.getTransactions(stellarAccount: currentWalletPK, startTime: startDate, endTime: endDate) { [weak self] result in
            switch result {
            case .success(let transactions):
                self?.entries = transactions
                self?.reloadClosure?()
            case .failure(let error):
                print("Transactions list failure: \(error)")
            }
        }
    }
    
    func date(at indexPath: IndexPath) -> String? {
        let date = entry(at: indexPath).createdAt
        return DateUtils.format(date, in: .dateAndTime)
    }
    
    func type(at indexPath: IndexPath) -> String? {
        let item = entry(at: indexPath)
        switch item.operationType {
        case .accountCreated:
            return item.sourceAccount == currentWalletPK ? R.string.localizable.payment_sent() : R.string.localizable.payment_received()
        case .payment:
            if let item = item.operationResponse as? TxPaymentOperationResponse {
                return item.to == currentWalletPK ? R.string.localizable.payment_received() : R.string.localizable.payment_sent()
            }
        case .pathPayment:
            if let item = item.operationResponse as? TxPathPaymentOperationResponse {
                return item.to == currentWalletPK ? R.string.localizable.payment_received() : R.string.localizable.payment_sent()
            }
        case .manageOffer:
            return item.sourceAccount == currentWalletPK ? R.string.localizable.offer_removed() : R.string.localizable.offer_created()
        case .createPassiveOffer:
            return item.sourceAccount == currentWalletPK ? R.string.localizable.passive_offer_removed() : R.string.localizable.passive_offer_created()
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
        default:
            break
        }
        return nil
    }
    
    func amount(at indexPath: IndexPath) -> NSAttributedString? {
        let item = entry(at: indexPath)
        switch item.operationType {
        case .accountCreated:
            let color: ColorStyle = type(at: indexPath) == R.string.localizable.payment_sent() ? .red : .green
            if let amount = (item.operationResponse as? TxAccountCreatedOperationResponse)?.startingBalance {
                return NSAttributedString(string: amount,
                                          attributes: [.foregroundColor : Stylesheet.color(color)])
            }
        case .payment:
            let color: ColorStyle = type(at: indexPath) == R.string.localizable.payment_sent() ? .red : .green
            if let amount = (item.operationResponse as? TxPaymentOperationResponse)?.amount {
                return NSAttributedString(string: amount,
                                          attributes: [.foregroundColor : Stylesheet.color(color)])
            }
        case .pathPayment:
            if let subItem = item.operationResponse as? TxPathPaymentOperationResponse {
                let color: ColorStyle = type(at: indexPath) == R.string.localizable.payment_sent() ? .red : .green
                let amount = type(at: indexPath) == R.string.localizable.payment_sent() ? subItem.sourceAmount : subItem.amount
                return NSAttributedString(string: amount,
                                          attributes: [.foregroundColor : Stylesheet.color(color)])
            }
        case .manageOffer:
            if let amount = (item.operationResponse as? TxManageOfferOperationResponse)?.amount {
                return NSAttributedString(string: amount,
                                          attributes: [.foregroundColor : Stylesheet.color(.lightBlack)])
            }
        case .createPassiveOffer:
            if let amount = (item.operationResponse as? TxCreatePassiveOfferOperationResponse)?.amount {
                return NSAttributedString(string: amount,
                                          attributes: [.foregroundColor : Stylesheet.color(.lightBlack)])
            }
        case .accountMerge:
            // TODO: fix logic, calculate amount
            if let subItem = item.operationResponse as? TxAccountMergeOperationResponse {
                return NSAttributedString(string: subItem.account,
                                          attributes: [.foregroundColor : Stylesheet.color(.green)])
            }
        default: break
        }
        return nil
    }
    
    func currency(at indexPath: IndexPath) -> String? {
        let item = entry(at: indexPath)
        switch item.operationType {
        case .accountCreated:
            return NativeCurrencyNames.xlm.rawValue
        case .payment:
            if let item = item.operationResponse as? TxPaymentOperationResponse {
                return item.assetCode ?? NativeCurrencyNames.xlm.rawValue
            }
        case .pathPayment:
            if let item = item.operationResponse as? TxPathPaymentOperationResponse {
                let currency = type(at: indexPath) == R.string.localizable.payment_sent() ? item.sendAssetCode : item.assetCode
                return currency ?? NativeCurrencyNames.xlm.rawValue
            }
        case .manageOffer:
            if let item = item.operationResponse as? TxManageOfferOperationResponse {
                let selling = item.sellingAssetCode ?? NativeCurrencyNames.xlm.rawValue
                let buying = item.buyingAssetCode ?? NativeCurrencyNames.xlm.rawValue
                return "\(selling) - \(buying)"
            }
        case .createPassiveOffer:
            if let item = item.operationResponse as? TxCreatePassiveOfferOperationResponse {
                let selling = item.sellingAssetCode ?? NativeCurrencyNames.xlm.rawValue
                let buying = item.buyingAssetCode ?? NativeCurrencyNames.xlm.rawValue
                return "\(selling) - \(buying)"
            }
        case .changeTrust:
            if let item = item.operationResponse as? TxChangeTrustOperationResponse {
                return item.assetCode ?? NativeCurrencyNames.xlm.rawValue
            }
        case .allowTrust:
            if let item = item.operationResponse as? TxAllowTrustOperationResponse {
                // TODO: check if authorize is necessary
                if item.authorize {
                    return item.assetCode ?? NativeCurrencyNames.xlm.rawValue
                }
            }
        case .accountMerge:
            // TODO: fix logic, calculate currency
            if let subItem = item.operationResponse as? TxAccountMergeOperationResponse {
                return subItem.account
            }
        default: break
        }
        return nil
    }
    
    func feePaid(at indexPath: IndexPath) -> String {
        let transaction = entry(at: indexPath)
        var operationFee = 0.0
        if currentWalletPK == transaction.sourceAccount {
            operationFee = Double(transaction.feePaid)/Double(transaction.operationCount)
        }
        return String(operationFee)
    }
    
    func details(at indexPath: IndexPath) -> NSAttributedString {
        let item = entry(at: indexPath)
        var subDetails = NSAttributedString()
        
        switch item.operationType {
        case .accountCreated:
            if let item = item.operationResponse as? TxAccountCreatedOperationResponse {
                subDetails = self.details(accountCreated: item)
            }
        case .payment:
            if let item = item.operationResponse as? TxPaymentOperationResponse {
                subDetails = self.details(payment: item)
            }
        case .pathPayment:
            if let item = item.operationResponse as? TxPathPaymentOperationResponse {
                subDetails = self.details(pathPayment: item)
            }
        case .manageOffer:
            if let item = item.operationResponse as? TxManageOfferOperationResponse {
                subDetails = self.details(manageOffer: item)
            }
        case .createPassiveOffer:
            if let subItem = item.operationResponse as? TxCreatePassiveOfferOperationResponse {
                subDetails = self.details(passiveOffer: subItem, transactionHash: item.transactionHash)
            }
        case .setOptions:
            if let item = item.operationResponse as? TxSetOptionsOperationResponse {
                subDetails = self.details(setOptions: item)
            }
        case .changeTrust:
            if let item = item.operationResponse as? TxChangeTrustOperationResponse {
                subDetails = self.details(changeTrust: item)
            }
        case .allowTrust:
            if let item = item.operationResponse as? TxAllowTrustOperationResponse {
                subDetails = self.details(allowTrust: item)
            }
        case .accountMerge:
            if let item = item.operationResponse as? TxAccountMergeOperationResponse {
                subDetails = self.details(accountMerge: item)
            }
        case .inflation:
            break
        case .manageData:
            if let item = item.operationResponse as? TxManageDataOperationResponse {
                subDetails = self.details(manageData: item)
            }
        case .bumpSequence:
            if let item = item.operationResponse as? TxBumpSequenceOperationResponse {
                subDetails = self.details(bumpSequence: item)
            }
        }
        
        let details = NSMutableAttributedString(string: R.string.localizable.operation_id()+": ",
                                                attributes: [.font : mainFont,
                                                             .foregroundColor : Stylesheet.color(.lightBlack)])
        
        let operationIdValue = NSAttributedString(string: String(item.opId)+"\n",
                                                  attributes: [.font : mainFont,
                                                               .foregroundColor : Stylesheet.color(.blue)])
        details.append(operationIdValue)
        
        if !item.memo.isEmpty {
            details.append(NSAttributedString(string: "\(R.string.localizable.memo()): \(item.memo)\n",
                                              attributes: [.font : mainFont,
                                                           .foregroundColor : Stylesheet.color(.lightBlack)]))
        }
        details.append(subDetails)
        
        if item.sourceAccount != currentWalletPK {
            details.append(copyString(prefix: R.string.localizable.source_account(), value: item.sourceAccount))
        }
        
        return details
    }
    
    func itemSelected(at indexPath:IndexPath) {
        
    }
    
    func filterClick() {
        navigationCoordinator?.performTransition(transition: .showTransactionFilter)
    }
    
    func sortClick() {
        
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
}

fileprivate extension TransactionsViewModel {
    func entry(at indexPath: IndexPath) -> TxTransactionResponse {
        return entries[indexPath.row]
    }
    
    
}

// MARK: Operation details
fileprivate extension TransactionsViewModel {
    func details(accountCreated: TxAccountCreatedOperationResponse) -> NSAttributedString {
        // TODO: check logic
        let publicKey = accountCreated.funder == currentWalletPK ? accountCreated.funder : accountCreated.account
        let prefix = accountCreated.funder == currentWalletPK ? R.string.localizable.sender() : R.string.localizable.recipient()
        return copyString(prefix: prefix, value: publicKey)
    }
    
    func details(payment: TxPaymentOperationResponse) -> NSAttributedString {
        let publicKey = payment.to == currentWalletPK ? payment.to : payment.from
        let prefix = payment.to == currentWalletPK ? R.string.localizable.recipient() : R.string.localizable.sender()
        return copyString(prefix: prefix, value: publicKey)
    }
    
    func details(pathPayment: TxPathPaymentOperationResponse) -> NSAttributedString {
        let publicKey = pathPayment.to == currentWalletPK ? pathPayment.to : pathPayment.from
        let prefix = pathPayment.to == currentWalletPK ? R.string.localizable.recipient() : R.string.localizable.sender()
        return copyString(prefix: prefix, value: publicKey)
    }
    
    func details(manageOffer: TxManageOfferOperationResponse) -> NSAttributedString {
        let offerID = NSAttributedString(string: "\(R.string.localizable.offer_id()): \(manageOffer.offerId)\n",
            attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                         .font : mainFont])
        
        let buyingCode = manageOffer.buyingAssetCode ?? NativeCurrencyNames.xlm.rawValue
        let buying = NSAttributedString(string: "\(R.string.localizable.buying()): \(buyingCode)\n",
            attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                         .font : mainFont])
        
        let sellingAmount = manageOffer.amount
        let sellingCode = manageOffer.sellingAssetCode ?? NativeCurrencyNames.xlm.rawValue
        let selling = NSAttributedString(string: "\(R.string.localizable.selling()): \(sellingAmount) \(sellingCode)\n",
            attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                         .font : mainFont])
        
        let price = NSAttributedString(string: "\(R.string.localizable.price_for_asset()): \(manageOffer.price)\n",
            attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                         .font : mainFont])
        
        let details = NSMutableAttributedString(attributedString: offerID)
        details.append(buying)
        details.append(selling)
        details.append(price)
        details.append(NSAttributedString(string: "\n"))
        
        return details
    }
    
    func details(passiveOffer: TxCreatePassiveOfferOperationResponse, transactionHash: String) -> NSAttributedString {
        
        let details = NSMutableAttributedString()
        
        offerIDForTransaction(fromHash: transactionHash) { offerID in
            if let offerID = offerID {
                let offerIDStr = NSAttributedString(string: "\(R.string.localizable.offer_id()): \(offerID)\n",
                    attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                                 .font : self.mainFont])
                details.insert(offerIDStr, at: 0)
                
                // TODO: update UI label main thread
            }
        }
        
        let buyingCode = passiveOffer.buyingAssetCode ?? NativeCurrencyNames.xlm.rawValue
        let buying = NSAttributedString(string: "\(R.string.localizable.buying()): \(buyingCode)\n",
            attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                         .font : mainFont])
        
        let sellingAmount = passiveOffer.amount
        let sellingCode = passiveOffer.sellingAssetCode ?? NativeCurrencyNames.xlm.rawValue
        let selling = NSAttributedString(string: "\(R.string.localizable.selling()): \(sellingAmount) \(sellingCode)\n",
            attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                         .font : mainFont])
        
        let price = NSAttributedString(string: "\(R.string.localizable.price_for_asset()): \(passiveOffer.price)\n",
            attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                         .font : mainFont])
        
        details.append(buying)
        details.append(selling)
        details.append(price)
        details.append(NSAttributedString(string: "\n"))
        
        return details
    }
    
    func details(setOptions: TxSetOptionsOperationResponse) -> NSAttributedString {
        let details = NSMutableAttributedString()
        if let inflationPK = setOptions.inflationDestination {
            let pkStr = copyString(prefix: R.string.localizable.inflation_destination(), value: inflationPK)
            details.append(pkStr)
        }
        
        if let setFlags = setOptions.setFlags {
            var flags: [String] = []
            if setFlags.authRequired { flags.append(R.string.localizable.authorization_required()) }
            if setFlags.authImmutable { flags.append(R.string.localizable.authorization_immutable()) }
            if setFlags.authRevocable { flags.append(R.string.localizable.authorization_revocable()) }
            
            if flags.count > 0 {
                let flagStr = flags.joined(separator: ",")
                let setFlagStr = NSAttributedString(string: "\(R.string.localizable.set_flags()): \(flagStr)\n",
                    attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                                 .font : mainFont])
                
                details.append(setFlagStr)
            }
        }
        
        if let clearFlags = setOptions.clearFlags {
            var flags: [String] = []
            if clearFlags.authRequired { flags.append(R.string.localizable.authorization_required()) }
            if clearFlags.authImmutable { flags.append(R.string.localizable.authorization_immutable()) }
            if clearFlags.authRevocable { flags.append(R.string.localizable.authorization_revocable()) }
            
            if flags.count > 0 {
                let flagStr = flags.joined(separator: ",")
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
            let label = signerWeight == 0 ? R.string.localizable.signer_removed() : R.string.localizable.signer_added()
            let signer = copyString(prefix: label, value: signerKey)
            
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
            
            let signerWeightStr = NSAttributedString(string: "\(R.string.localizable.signer_weight()): \(signerWeight)\n",
                attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                             .font : mainFont])
            
            details.append(signer)
            details.append(signerType)
            details.append(signerWeightStr)
        }
        
        if let homeDomain = setOptions.homeDomain {
            let domain = NSMutableAttributedString(string: R.string.localizable.home_domain())
            let domainLink = NSAttributedString(string: "\(homeDomain)\n",
                attributes: [.link : homeDomain,
                             .font : mainFont])
            
            domain.append(domainLink)
            details.append(domain)
        }
        
        return details
    }
    
    func details(changeTrust: TxChangeTrustOperationResponse) -> NSAttributedString {
        // TODO: check type calculation logic
        let typee = (changeTrust.limit ?? "0") == "0" ? R.string.localizable.remove() : R.string.localizable.add()
        let type = NSAttributedString(string: "\(R.string.localizable.type()): \(typee)\n",
                                      attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                                                   .font : mainFont])
        
        let code = changeTrust.assetCode ?? NativeCurrencyNames.xlm.rawValue
        let asset = NSAttributedString(string: "\(R.string.localizable.asset()): \(code)\n",
                                       attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                                                    .font : mainFont])
        
        var issuer = NSAttributedString()
        if let issuerr = changeTrust.assetIssuer {
            issuer = copyString(prefix: R.string.localizable.issuer(), value: issuerr)
        }
        
        let limit = changeTrust.limit ?? R.string.localizable.none()
        let trustLimit = NSAttributedString(string: "\(R.string.localizable.trust_limit()): \(limit)\n",
                                            attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                                                         .font : mainFont])
        
        let details = NSMutableAttributedString(attributedString: type)
        details.append(asset)
        details.append(issuer)
        details.append(trustLimit)
        details.append(NSAttributedString(string: "\n"))
        
        return details
    }
    
    func details(allowTrust: TxAllowTrustOperationResponse) -> NSAttributedString {
        let trustor = copyString(prefix: R.string.localizable.trustor(), value: allowTrust.trustor)
        
        let code = allowTrust.assetCode ?? NativeCurrencyNames.xlm.rawValue
        let asset = NSAttributedString(string: "\(R.string.localizable.asset()): \(code)\n",
                                       attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                                                    .font : mainFont])
        
        let authorize = NSAttributedString(string: "\(R.string.localizable.authorize()): \(allowTrust.authorize.description)\n",
                                           attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                                                        .font : mainFont])
        
        let details = NSMutableAttributedString(attributedString: trustor)
        details.append(asset)
        details.append(authorize)
        details.append(NSAttributedString(string: "\n"))
        
        return details
    }
    
    func details(accountMerge: TxAccountMergeOperationResponse) -> NSAttributedString {
        return copyString(prefix: R.string.localizable.merged_account(), value: accountMerge.account)
    }
    
    func details(manageData: TxManageDataOperationResponse) -> NSAttributedString {
        let name = NSAttributedString(string: "\(R.string.localizable.entry_name()): \(manageData.name)\n",
            attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                         .font : mainFont])
        
        var valuee = R.string.localizable.deleted()
        if !manageData.value.isEmpty {
            if let base64 = Data(base64Encoded: manageData.value),
                let text = String(data: base64, encoding: .utf8) {
                valuee = text
            } else {
                valuee = manageData.value
            }
        }
        
        let value = NSAttributedString(string: "\(R.string.localizable.entry_value()): \(valuee)\n",
            attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                         .font : mainFont])
        
        let details = NSMutableAttributedString(attributedString: name)
        details.append(value)
        details.append(NSAttributedString(string: "\n"))
        
        return details
    }
    
    func details(bumpSequence: TxBumpSequenceOperationResponse) -> NSAttributedString {
        let bump = NSAttributedString(string: "\(R.string.localizable.bumped_from()): \(bumpSequence.bumpTo)\n",
                                      attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                                                   .font : mainFont])
        return bump
    }
    
    func copyString(prefix: String, value: String) -> NSAttributedString {
        let pkStr = NSAttributedString(string: "\(prefix): \(value)",
            attributes: [.foregroundColor : Stylesheet.color(.lightBlack),
                         .font : mainFont])
        
        let attachment = LSTextAttachment(info: value)
        attachment.image = R.image.copy()?.resize(toHeight: 30)
        let copyStr = NSAttributedString(attachment: attachment)
        
        let details = NSMutableAttributedString(attributedString: pkStr)
        details.append(copyStr)
        details.append(NSAttributedString(string: "\n"))
        
        return details
    }
    
    func offerIDForTransaction(fromHash transactionHash:String, completion: @escaping ((String?) -> (Void))) {
        services.stellarSdk.transactions.getTransactionDetails(transactionHash: transactionHash, response: { (response) -> (Void) in
            switch response {
            case .success(details: let transaction):
                switch transaction.transactionResult.resultBody {
                case .success(let operations)?:
                    for operation in operations {
                        switch operation {
                        case .manageOffer( _, let result): fallthrough
                        case .createPassiveOffer( _, let result):
                            switch result {
                            case .success( _, let subResult):
                                switch subResult.offer {
                                case .created(let offer)?:
                                    completion(String(offer.offerID))
                                default: continue
                                }
                            default: continue
                            }
                        default: continue
                        }
                    }
                default:
                    completion(nil)
                }
            case .failure(error: let error):
                print("Error: \(error)")
                completion(nil)
            }
        })
    }
}
