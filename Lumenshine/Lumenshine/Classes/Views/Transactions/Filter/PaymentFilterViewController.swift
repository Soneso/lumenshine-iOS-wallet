//
//  PaymentFilterViewController.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 25/11/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class PaymentFilterViewController: UIViewController {
    
    // MARK: - Properties
    
    let viewModel: TransactionsViewModelType
    
    // MARK: - UI properties
    fileprivate let scrollView = UIScrollView()
    fileprivate let contentView = UIView()
    
    fileprivate let receivedField = SwitchRangeField()
    fileprivate let sentField = SwitchRangeField()
    fileprivate let currencyField = SwitchInputField()
    
    fileprivate let clearButton = LSButton()
    
    fileprivate let verticalSpacing: CGFloat = 25.0
    fileprivate let horizontalSpacing: CGFloat = 15.0
    
    init(viewModel: TransactionsViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveFilter()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

extension PaymentFilterViewController {
    @objc
    func clearAction(sender: UIButton) {
        viewModel.filter.payment.clear()
        receivedField.update(range: viewModel.filter.payment.receivedRange, animated: true)
        sentField.update(range: viewModel.filter.payment.sentRange, animated: true)
        currencyField.update(value: viewModel.filter.payment.currency, animated: true)
    }
    
    func saveFilter() {
        if receivedField.switch.isOn {
            var from = 0.0
            if let fromV = receivedField.textField.text, !fromV.isEmpty {
                from = Double(fromV) ?? 0.0
            }
            var to = Double.infinity
            if let toV = receivedField.rangeTextField.text, !toV.isEmpty {
                to = Double(toV) ?? Double.infinity
            }
            viewModel.filter.payment.receivedRange = Range<Double>(uncheckedBounds: (from, to))
        } else {
            viewModel.filter.payment.receivedRange = nil
        }
        
        if sentField.switch.isOn {
            var from = 0.0
            if let fromV = sentField.textField.text, !fromV.isEmpty {
                from = Double(fromV) ?? 0.0
            }
            var to = Double.infinity
            if let toV = sentField.rangeTextField.text, !toV.isEmpty {
                to = Double(toV) ?? Double.infinity
            }
            viewModel.filter.payment.sentRange = from..<to// Range<Double>(uncheckedBounds: (from, to))
        } else {
            viewModel.filter.payment.sentRange = nil
        }
        
        if currencyField.switch.isOn {
            viewModel.filter.payment.currency = currencyField.textField.text
        } else {
            viewModel.filter.payment.currency = nil
        }
    }
}

fileprivate extension PaymentFilterViewController {
    func prepareView() {
        view.backgroundColor = Stylesheet.color(.lightGray)
        prepareCopyright()
        prepareContentView()
        prepareNavigationItem()
        
        prepareReceived()
        prepareSent()
        prepareCurrency()
        prepareButton()
    }
    
    func prepareNavigationItem() {
        navigationItem.titleLabel.text = R.string.localizable.transactions_filters()
        navigationItem.titleLabel.textColor = Stylesheet.color(.blue)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
    }
    
    func prepareContentView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        contentView.cornerRadiusPreset = .cornerRadius4
        contentView.depthPreset = .depth3
        contentView.backgroundColor = Stylesheet.color(.white)
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(-60)
            make.width.equalTo(view).offset(-30)
        }
    }
    
    func prepareCopyright() {
        let imageView = UIImageView(image: R.image.soneso())
        imageView.backgroundColor = Stylesheet.color(.clear)
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.bottom.equalTo(-20)
            make.centerX.equalToSuperview()
        }
        
        let background = UIImageView(image: R.image.soneso_background())
        background.contentMode = .scaleAspectFit
        
        view.addSubview(background)
        background.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview()
            make.left.right.equalToSuperview()
            make.bottom.equalTo(imageView.snp.top)
        }
    }
    
    func prepareReceived() {
        receivedField.label.text = R.string.localizable.received()
        receivedField.textField.placeholder = R.string.localizable.amount_from()
        receivedField.textField.textInset = horizontalSpacing
        receivedField.rangeTextField.placeholder = R.string.localizable.amount_to()
        receivedField.rangeTextField.textInset = horizontalSpacing
        receivedField.update(range: viewModel.filter.payment.receivedRange)
        
        contentView.addSubview(receivedField)
        receivedField.snp.makeConstraints { make in
            make.top.equalTo(verticalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareSent() {
        sentField.label.text = R.string.localizable.sent()
        sentField.textField.placeholder = R.string.localizable.amount_from()
        sentField.textField.textInset = horizontalSpacing
        sentField.rangeTextField.placeholder = R.string.localizable.amount_to()
        sentField.rangeTextField.textInset = horizontalSpacing
        sentField.update(range: viewModel.filter.payment.sentRange)
        
        contentView.addSubview(sentField)
        sentField.snp.makeConstraints { make in
            make.top.equalTo(receivedField.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareCurrency() {
        currencyField.label.text = R.string.localizable.currency()
        currencyField.textField.placeholder = R.string.localizable.currency()
        currencyField.textField.textInset = horizontalSpacing
        currencyField.update(value: viewModel.filter.payment.currency)
        currencyField.textField.setInputViewOptions(options: viewModel.currencies, selectedIndex: viewModel.currencyIndex) { newIndex in
            self.viewModel.currencyIndex = newIndex
        }
        
        contentView.addSubview(currencyField)
        currencyField.snp.makeConstraints { make in
            make.top.equalTo(sentField.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareButton() {
        clearButton.title = R.string.localizable.clear().uppercased()
        clearButton.titleColor = Stylesheet.color(.gray)
        clearButton.borderWidthPreset = .border1
        clearButton.borderColor = Stylesheet.color(.gray)
        clearButton.setGradientLayer(color: Stylesheet.color(.white))
        clearButton.addTarget(self, action: #selector(clearAction(sender:)), for: .touchUpInside)
        
        contentView.addSubview(clearButton)
        clearButton.snp.makeConstraints { make in
            make.top.equalTo(currencyField.snp.bottom).offset(verticalSpacing)
            make.centerX.equalToSuperview()
            make.width.equalTo(140)
            make.height.equalTo(40)
            make.bottom.equalTo(-verticalSpacing)
        }
    }
}
