//
//  TransactionsFilterViewController.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 20/11/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class TransactionsFilterViewController: UIViewController {
    
    // MARK: - Properties
    
    let viewModel: TransactionsViewModelType
    
    // MARK: - UI properties
    fileprivate let scrollView = UIScrollView()
    fileprivate let contentView = UIView()
    
    fileprivate let walletField = LSTextField()
    fileprivate let memoField = LSTextField()
    fileprivate let dateFromField = LSTextField()
    fileprivate let dateToField = LSTextField()
    
    fileprivate let paymentsFilter = FilterSwitch()
    fileprivate let offersFilter = FilterSwitch()
    fileprivate let otherFilter = FilterSwitch()
    
    fileprivate let applyButton = LSButton()
    fileprivate let clearButton = LSButton()
    
    fileprivate let verticalSpacing: CGFloat = 25.0
    fileprivate let horizontalSpacing: CGFloat = 15.0
    fileprivate var walletIndex: Int = 0
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTags()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
}

extension TransactionsFilterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return resignFirstResponder()
    }
}

extension TransactionsFilterViewController {
    @objc
    func clearAction(sender: UIButton) {
        viewModel.filter.clear()
    }
    
    @objc
    func applyAction(sender: UIButton) {
        viewModel.applyFilters()
    }
    
    @objc
    func memoEditingDidChange(_ textField: TextField) {
        guard let text = textField.text else {
            return
        }
        viewModel.memoChanged(text)
    }
    
    @objc
    func walletEditingDidChange(_ textField: TextField) {
        viewModel.walletIndex = walletIndex
    }
    
    @objc
    func dateFromDidChange(sender: UIDatePicker) {
        dateFromField.text = DateUtils.format(sender.date, in: .date)
        viewModel.dateFrom = sender.date
    }
    
    @objc
    func dateToDidChange(sender: UIDatePicker) {
        dateToField.text = DateUtils.format(sender.date, in: .date)
        viewModel.dateTo = sender.date
    }
    
    @objc
    func didTapPayments(sender: UITapGestureRecognizer) {
        viewModel.showPaymentsFilter()
    }
    
    @objc
    func didTapOffers(sender: UITapGestureRecognizer) {
        viewModel.showOffersFilter()
    }
    
    @objc
    func didTapOthers(sender: UITapGestureRecognizer) {
        viewModel.showOtherFilter()
    }
}

extension TransactionsFilterViewController {
    
    func updateTags() {
        paymentsFilter.show(tags: viewModel.paymentFilterTags(), color: Stylesheet.color(.orange))
        offersFilter.show(tags: viewModel.offerFilterTags(), color: Stylesheet.color(.green))
        otherFilter.show(tags: viewModel.otherFilterTags(), color: Stylesheet.color(.blue))
    }
}

fileprivate extension TransactionsFilterViewController {
    func prepareView() {
        view.backgroundColor = Stylesheet.color(.lightGray)
        prepareCopyright()
        prepareContentView()
        prepareNavigationItem()
        
        prepareWalletLabel()
        prepareDateLabels()
        prepareMemoLabel()
        prepareSwitches()
        prepareButtons()
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
    
    func prepareWalletLabel() {
        let walletLabel = UILabel()
        walletLabel.text = R.string.localizable.wallet_name()
        walletLabel.font = R.font.encodeSansRegular(size: 13)
        walletLabel.adjustsFontSizeToFitWidth = true
        walletLabel.textColor = Stylesheet.color(.gray)
        
        contentView.addSubview(walletLabel)
        walletLabel.snp.makeConstraints { make in
            make.top.equalTo(verticalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        walletField.text = viewModel.wallets.first ?? R.string.localizable.primary()
        walletField.borderWidthPreset = .border2
        walletField.borderColor = Stylesheet.color(.gray)
        walletField.dividerNormalHeight = 1
        walletField.dividerActiveHeight = 1
        walletField.dividerNormalColor = Stylesheet.color(.gray)
        walletField.backgroundColor = .white
        walletField.textInset = horizontalSpacing
        setInputViewOptions(textField: walletField, options: viewModel.wallets)
        
        contentView.addSubview(walletField)
        walletField.snp.makeConstraints { make in
            make.top.equalTo(walletLabel.snp.bottom)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
            make.height.equalTo(40)
        }
    }
    
    func prepareDateLabels() {
        let dateFromLabel = UILabel()
        dateFromLabel.text = R.string.localizable.date_from()
        dateFromLabel.font = R.font.encodeSansRegular(size: 13)
        dateFromLabel.adjustsFontSizeToFitWidth = true
        dateFromLabel.textColor = Stylesheet.color(.gray)
        
        contentView.addSubview(dateFromLabel)
        dateFromLabel.snp.makeConstraints { make in
            make.top.equalTo(walletField.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalToSuperview().dividedBy(2)
        }
        
        dateFromField.text = DateUtils.format(viewModel.dateFrom, in: .date)
        dateFromField.textColor = Stylesheet.color(.white)
        dateFromField.borderWidthPreset = .border2
        dateFromField.borderColor = Stylesheet.color(.gray)
        dateFromField.dividerNormalHeight = 1
        dateFromField.dividerActiveHeight = 1
        dateFromField.dividerNormalColor = Stylesheet.color(.gray)
        dateFromField.backgroundColor = Stylesheet.color(.gray)
        dateFromField.textInset = horizontalSpacing
        setDatePickerInputView(textField: dateFromField)
        
        contentView.addSubview(dateFromField)
        dateFromField.snp.makeConstraints { make in
            make.top.equalTo(dateFromLabel.snp.bottom)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(contentView.snp.centerX).offset(-horizontalSpacing/2)
            make.height.equalTo(40)
        }
        
        let dateToLabel = UILabel()
        dateToLabel.text = R.string.localizable.date_to()
        dateToLabel.font = R.font.encodeSansRegular(size: 13)
        dateToLabel.adjustsFontSizeToFitWidth = true
        dateToLabel.textColor = Stylesheet.color(.gray)
        
        contentView.addSubview(dateToLabel)
        dateToLabel.snp.makeConstraints { make in
            make.top.equalTo(walletField.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(dateFromLabel.snp.right).offset(horizontalSpacing)
            make.right.equalToSuperview()
        }
        
        dateToField.text = DateUtils.format(viewModel.dateTo, in: .date)
        dateToField.textColor = Stylesheet.color(.white)
        dateToField.borderWidthPreset = .border2
        dateToField.borderColor = Stylesheet.color(.gray)
        dateToField.dividerNormalHeight = 1
        dateToField.dividerActiveHeight = 1
        dateToField.dividerNormalColor = Stylesheet.color(.gray)
        dateToField.backgroundColor = Stylesheet.color(.gray)
        dateToField.textInset = horizontalSpacing
        setDatePickerInputView(textField: dateToField)
        
        contentView.addSubview(dateToField)
        dateToField.snp.makeConstraints { make in
            make.top.equalTo(dateToLabel.snp.bottom)
            make.left.equalTo(dateToLabel)
            make.right.equalTo(-horizontalSpacing)
            make.height.equalTo(40)
        }
    }
    
    func prepareMemoLabel() {
        let memoLabel = UILabel()
        memoLabel.text = R.string.localizable.memo()
        memoLabel.font = R.font.encodeSansRegular(size: 13)
        memoLabel.adjustsFontSizeToFitWidth = true
        memoLabel.textColor = Stylesheet.color(.gray)
        
        contentView.addSubview(memoLabel)
        memoLabel.snp.makeConstraints { make in
            make.top.equalTo(dateFromField.snp.bottom).offset(verticalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
        
        memoField.placeholder = R.string.localizable.memo()
        memoField.borderWidthPreset = .border2
        memoField.borderColor = Stylesheet.color(.gray)
        memoField.dividerNormalHeight = 1
        memoField.dividerActiveHeight = 1
        memoField.dividerNormalColor = Stylesheet.color(.gray)
        memoField.backgroundColor = .white
        memoField.textInset = horizontalSpacing
        memoField.addTarget(self, action: #selector(memoEditingDidChange(_:)), for: .editingChanged)
        
        contentView.addSubview(memoField)
        memoField.snp.makeConstraints { make in
            make.top.equalTo(memoLabel.snp.bottom)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
            make.height.equalTo(40)
        }
    }
    
    func prepareSwitches() {
        var tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapPayments(sender:)))
        paymentsFilter.addGestureRecognizer(tapGesture)
        paymentsFilter.setTitle(R.string.localizable.payments())
        
        contentView.addSubview(paymentsFilter)
        paymentsFilter.snp.makeConstraints { make in
            make.top.equalTo(memoField.snp.bottom).offset(verticalSpacing)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.greaterThanOrEqualTo(70)
        }
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOffers(sender:)))
        offersFilter.addGestureRecognizer(tapGesture)
        offersFilter.setTitle(R.string.localizable.offers())
        
        contentView.addSubview(offersFilter)
        offersFilter.snp.makeConstraints { make in
            make.top.equalTo(paymentsFilter.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.greaterThanOrEqualTo(70)
        }
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOthers(sender:)))
        otherFilter.addGestureRecognizer(tapGesture)
        otherFilter.setTitle(R.string.localizable.other())
        
        contentView.addSubview(otherFilter)
        otherFilter.snp.makeConstraints { make in
            make.top.equalTo(offersFilter.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.greaterThanOrEqualTo(70)
        }
    }
    
    func prepareButtons() {
        clearButton.title = R.string.localizable.clear_all().uppercased()
        clearButton.titleColor = Stylesheet.color(.gray)
        clearButton.borderWidthPreset = .border1
        clearButton.borderColor = Stylesheet.color(.gray)
        clearButton.setGradientLayer(color: Stylesheet.color(.white))
        clearButton.addTarget(self, action: #selector(clearAction(sender:)), for: .touchUpInside)
        
        contentView.addSubview(clearButton)
        clearButton.snp.makeConstraints { make in
            make.top.equalTo(otherFilter.snp.bottom).offset(2*verticalSpacing)
            make.left.equalTo(2*horizontalSpacing)
            make.width.equalTo(140)
            make.height.equalTo(40)
            make.bottom.equalTo(-verticalSpacing)
        }
        
        applyButton.title = R.string.localizable.apply().uppercased()
        applyButton.titleColor = Stylesheet.color(.blue)
        applyButton.borderWidthPreset = .border1
        applyButton.borderColor = Stylesheet.color(.blue)
        applyButton.setGradientLayer(color: Stylesheet.color(.white))
        applyButton.addTarget(self, action: #selector(applyAction(sender:)), for: .touchUpInside)
        
        contentView.addSubview(applyButton)
        applyButton.snp.makeConstraints { make in
            make.left.equalTo(clearButton.snp.right).offset(horizontalSpacing)
            make.centerY.equalTo(clearButton)
            make.width.equalTo(120)
            make.height.equalTo(40)
        }
    }
    
    func setInputViewOptions(textField: TextField, options: [String], selectedIndex: Int? = nil) {
        let enumPicker = EnumPicker()
        enumPicker.setValues(options, currentSelection: selectedIndex) { (newIndex) in
            if newIndex > options.count {
                textField.text = options[newIndex]
                self.walletEditingDidChange(textField)
                self.walletIndex = newIndex
            }
        }
        textField.text = options.first
        textField.inputView = enumPicker
    }
    
    func setDatePickerInputView(textField: TextField, date: Date = Date()) {
        var minYear = DateComponents()
        minYear.year = 1910
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        datePicker.minimumDate = Calendar.current.date(from: minYear)
        
        if textField == dateFromField {
            datePicker.addTarget(self, action: #selector(dateFromDidChange(sender:)), for: .valueChanged)
        }
        if textField == dateToField {
            datePicker.addTarget(self, action: #selector(dateToDidChange(sender:)), for: .valueChanged)
        }
        
        textField.inputView = datePicker
        
        datePicker.date = date
    }
}


