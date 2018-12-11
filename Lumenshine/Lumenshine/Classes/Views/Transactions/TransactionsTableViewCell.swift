//
//  TransactionsTableViewCell.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 02/11/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material
import stellarsdk

protocol TransactionsCellProtocol {
    func setDate(_ text: String?)
    func setType(_ text: String?)
    func setFee(_ text: String?)
    func setAmount(_ text: NSAttributedString?)
    func setCurrency(_ text: String?)
    func setOfferId(_ item:TxOperationResponse?, transactionHash: String?)
    func setDetails(_ text: NSAttributedString?)
    var delegate: TransactionsCellDelegate? { get set }
}

protocol TransactionsCellDelegate: class {
    func cellCopiedToPasteboard(_ cell: TransactionsCellProtocol)
    func cell(_ cell: TransactionsCellProtocol, didInteractWith url: URL)
}

class TransactionsTableViewCell: UITableViewCell {
    
    fileprivate let dateLabel = UILabel()
    fileprivate let typeLabel = UILabel()
    fileprivate let amountLabel = UILabel()
    fileprivate let currencyLabel = UILabel()
    fileprivate let offerIdLabel = UILabel()
    fileprivate let feeLabel = UILabel()
    fileprivate let detailsLabel = UILabel()
    
    fileprivate let dateValueLabel = UILabel()
    fileprivate let typeValueLabel = UILabel()
    fileprivate let amountValueLabel = UILabel()
    fileprivate let currencyValueLabel = UILabel()
    fileprivate let offerIdValueLabel = UILabel()
    fileprivate let feeValueLabel = UILabel()
    fileprivate let detailsValueLabel = UITextView()
    
    fileprivate let verticalSpacing = 31.0
    fileprivate let horizontalSpacing: CGFloat = 15.0
    fileprivate let labelWidth: CGFloat = 80.0
    fileprivate let fontSize: CGFloat = 13.0
    
    weak var delegate: TransactionsCellDelegate?
    
    var stellarSDK: StellarSDK {
        get {
            return Services.shared.stellarSdk
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = UIEdgeInsetsInsetRect(contentView.frame, UIEdgeInsetsMake(0, horizontalSpacing, 0, horizontalSpacing))
    }
    
    func commonInit() {
        contentView.backgroundColor = Stylesheet.color(.white)
        backgroundColor = .clear
        selectionStyle = .none
        
        prepareDateLabel()
        prepareTypeLabel()
        prepareAmountLabel()
        prepareCurrencyLabel()
        prepareFeeLabel()
        prepareOfferIdLabel()
        prepareDetailsLabel()
    }
}

extension TransactionsTableViewCell: TransactionsCellProtocol {
    func setDate(_ text: String?) {
        dateValueLabel.text = text
        dateLabel.isHidden = text?.isEmpty ?? true
    }
    
    func setType(_ text: String?) {
        typeValueLabel.text = text
        typeLabel.isHidden = text?.isEmpty ?? true
    }
    
    func setFee(_ text: String?) {
        if let feeText = text {
            feeValueLabel.text = feeText + " XLM"
            feeLabel.isHidden = false
        }
        else {
            feeLabel.isHidden = true
        }
    }
    
    func setAmount(_ text: NSAttributedString?) {
        amountValueLabel.attributedText = text
        amountLabel.isHidden = text?.string.isEmpty ?? true
    }
    
    func setCurrency(_ text: String?) {
        currencyValueLabel.text = text
        currencyLabel.isHidden = text?.isEmpty ?? true
    }
    
    func setOfferId(_ item:TxOperationResponse?, transactionHash: String?) {
        if let manageOfferItem = item as? TxManageOfferOperationResponse, manageOfferItem.offerId != 0 {
            offerIdValueLabel.text = String(manageOfferItem.offerId)
            offerIdLabel.isHidden = false
        } else {

            var isOffer = false
            var amount = "0"
            var price = "0"
            var sellingAssetType = "native"
            var sellingAssetCode: String? = nil
            var sellingIssuer: String? = nil
            var buyingAssetType = "native"
            var buyingAssetCode: String? = nil
            var buyingIssuer: String? = nil
            
            if let manageOfferItem = item as? TxManageOfferOperationResponse {
                isOffer = true
                amount = manageOfferItem.amount
                sellingAssetType = manageOfferItem.sellingAssetType
                sellingAssetCode = manageOfferItem.sellingAssetCode
                sellingIssuer = manageOfferItem.sellingAssetIssuer
                buyingAssetType = manageOfferItem.sellingAssetType
                buyingAssetCode = manageOfferItem.sellingAssetCode
                buyingIssuer = manageOfferItem.sellingAssetIssuer
                price = manageOfferItem.price
                
            } else if let passiveOfferItem = item as? TxCreatePassiveOfferOperationResponse {
                isOffer = true
                amount = passiveOfferItem.amount
                sellingAssetType = passiveOfferItem.sellingAssetType
                sellingAssetCode = passiveOfferItem.sellingAssetCode
                sellingIssuer = passiveOfferItem.sellingAssetIssuer
                buyingAssetType = passiveOfferItem.sellingAssetType
                buyingAssetCode = passiveOfferItem.sellingAssetCode
                buyingIssuer = passiveOfferItem.sellingAssetIssuer
                price = passiveOfferItem.price
            }
            
            if let tHash = transactionHash, isOffer {
                offerIdLabel.isHidden = false
                offerIdValueLabel.text = "loading ..."
                stellarSDK.transactions.getTransactionDetails(transactionHash: tHash) { (response) -> (Void) in
                    DispatchQueue.main.async {
                        switch response {
                        case .success(details: let transaction):
                            // TODO find offer
                            self.offerIdValueLabel.text = transaction.id
                            print("TODO find offer")
                        case .failure(_):
                            print("offer could not be fetched")
                            self.offerIdValueLabel.text = "not found"
                        }
                    }
                }
            } else {
                offerIdLabel.isHidden = true
            }
        }
    }
    
    func setDetails(_ text: NSAttributedString?) {
        detailsValueLabel.attributedText = text
        detailsLabel.isHidden = text?.string.isEmpty ?? true
    }
}

extension TransactionsTableViewCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        delegate?.cell(self, didInteractWith: URL)
        return false
    }
    
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        if let attachment = textAttachment as? LSTextAttachment {
            UIPasteboard.general.string = attachment.additionalInfo            
            delegate?.cellCopiedToPasteboard(self)
        }
        return false
    }
    
}

fileprivate extension TransactionsTableViewCell {
    
    func prepareDateLabel() {
        dateLabel.text = R.string.localizable.date() + ":"
        dateLabel.textColor = Stylesheet.color(.lightBlack)
        dateLabel.font = R.font.encodeSansSemiBold(size: fontSize)
        
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(horizontalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.width.equalTo(labelWidth)
        }
        
        dateValueLabel.textColor = Stylesheet.color(.lightBlack)
        dateValueLabel.font = R.font.encodeSansRegular(size: fontSize)
        
        contentView.addSubview(dateValueLabel)
        dateValueLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel)
            make.left.equalTo(dateLabel.snp.right)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareTypeLabel() {
        typeLabel.text = R.string.localizable.type() + ":"
        typeLabel.textColor = Stylesheet.color(.lightBlack)
        typeLabel.font = R.font.encodeSansSemiBold(size: fontSize)
        
        contentView.addSubview(typeLabel)
        typeLabel.snp.makeConstraints { make in
            make.top.equalTo(dateValueLabel.snp.bottom)
            make.left.equalTo(horizontalSpacing)
            make.width.equalTo(dateLabel)
        }
        
        typeValueLabel.textColor = Stylesheet.color(.lightBlack)
        typeValueLabel.font = R.font.encodeSansSemiBold(size: fontSize)
        
        contentView.addSubview(typeValueLabel)
        typeValueLabel.snp.makeConstraints { make in
            make.top.equalTo(typeLabel)
            make.left.equalTo(typeLabel.snp.right)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareAmountLabel() {
        amountLabel.text = R.string.localizable.amount() + ":"
        amountLabel.textColor = Stylesheet.color(.lightBlack)
        amountLabel.font = R.font.encodeSansSemiBold(size: fontSize)
        
        contentView.addSubview(amountLabel)
        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(typeValueLabel.snp.bottom)
            make.left.equalTo(horizontalSpacing)
            make.width.equalTo(dateLabel)
        }
        
        amountValueLabel.textColor = Stylesheet.color(.green)
        amountValueLabel.font = R.font.encodeSansSemiBold(size: fontSize)
        
        contentView.addSubview(amountValueLabel)
        amountValueLabel.snp.makeConstraints { make in
            make.top.equalTo(amountLabel)
            make.left.equalTo(amountLabel.snp.right)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareCurrencyLabel() {
        currencyLabel.text = R.string.localizable.currency() + ":"
        currencyLabel.textColor = Stylesheet.color(.lightBlack)
        currencyLabel.font = R.font.encodeSansSemiBold(size: fontSize)
        
        contentView.addSubview(currencyLabel)
        currencyLabel.snp.makeConstraints { make in
            make.top.equalTo(amountValueLabel.snp.bottom)
            make.left.equalTo(horizontalSpacing)
            make.width.equalTo(dateLabel)
        }
        
        currencyValueLabel.textColor = Stylesheet.color(.lightBlack)
        currencyValueLabel.font = R.font.encodeSansSemiBold(size: fontSize)
        
        contentView.addSubview(currencyValueLabel)
        currencyValueLabel.snp.makeConstraints { make in
            make.top.equalTo(currencyLabel)
            make.left.equalTo(currencyLabel.snp.right)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareFeeLabel() {
        feeLabel.text = R.string.localizable.fee() + ":"
        feeLabel.textColor = Stylesheet.color(.lightBlack)
        feeLabel.font = R.font.encodeSansSemiBold(size: fontSize)
        
        contentView.addSubview(feeLabel)
        feeLabel.snp.makeConstraints { make in
            make.top.equalTo(currencyValueLabel.snp.bottom)
            make.left.equalTo(horizontalSpacing)
            make.width.equalTo(dateLabel)
        }
        
        feeValueLabel.textColor = Stylesheet.color(.lightBlack)
        feeValueLabel.font = R.font.encodeSansRegular(size: fontSize)
        
        contentView.addSubview(feeValueLabel)
        feeValueLabel.snp.makeConstraints { make in
            make.top.equalTo(feeLabel)
            make.left.equalTo(feeLabel.snp.right)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareOfferIdLabel() {
        offerIdLabel.text = R.string.localizable.offer_id() + ":"
        offerIdLabel.textColor = Stylesheet.color(.lightBlack)
        offerIdLabel.font = R.font.encodeSansSemiBold(size: fontSize)
        
        contentView.addSubview(offerIdLabel)
        offerIdLabel.snp.makeConstraints { make in
            make.top.equalTo(feeValueLabel.snp.bottom)
            make.left.equalTo(horizontalSpacing)
            make.width.equalTo(dateLabel)
        }
        
        offerIdValueLabel.textColor = Stylesheet.color(.lightBlack)
        offerIdValueLabel.font = R.font.encodeSansRegular(size: fontSize)
        
        contentView.addSubview(offerIdValueLabel)
        offerIdValueLabel.snp.makeConstraints { make in
            make.top.equalTo(offerIdLabel)
            make.left.equalTo(offerIdLabel.snp.right)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareDetailsLabel() {
        detailsLabel.text = R.string.localizable.details()
        detailsLabel.textColor = Stylesheet.color(.lightBlack)
        detailsLabel.font = R.font.encodeSansSemiBold(size: fontSize)
        
        contentView.addSubview(detailsLabel)
        detailsLabel.snp.makeConstraints { make in
            make.top.equalTo(offerIdValueLabel.snp.bottom).offset(10.0)
            make.left.equalTo(horizontalSpacing)
            make.width.equalTo(dateLabel)
        }
        
        detailsValueLabel.textColor = Stylesheet.color(.lightBlack)
        detailsValueLabel.font = R.font.encodeSansRegular(size: fontSize)
        detailsValueLabel.isEditable = false
        detailsValueLabel.isScrollEnabled = false
        detailsValueLabel.delegate = self
        detailsValueLabel.textContainerInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        
        contentView.addSubview(detailsValueLabel)
        detailsValueLabel.snp.makeConstraints { make in
            make.top.equalTo(detailsLabel.snp.bottom)
            make.left.equalTo(detailsLabel.snp.left)
            make.right.equalTo(-horizontalSpacing)
            make.bottom.equalTo(-horizontalSpacing)
        }
    }
}


