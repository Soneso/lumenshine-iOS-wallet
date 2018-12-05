//
//  OfferFilterViewController.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 26/11/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class OfferFilterViewController: UIViewController {
    
    // MARK: - Properties
    
    let viewModel: TransactionsViewModelType
    
    // MARK: - UI properties
    fileprivate let scrollView = UIScrollView()
    fileprivate let contentView = UIView()
    
    fileprivate let sellingField = SwitchInputField()
    fileprivate let buyingField = SwitchInputField()
    
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

extension OfferFilterViewController {
    @objc
    func clearAction(sender: UIButton) {
        viewModel.filter.offer.clear()
        sellingField.update(value: viewModel.filter.offer.sellingCurrency, animated: true)
        buyingField.update(value: viewModel.filter.offer.buyingCurrency, animated: true)
    }
    
    func saveFilter() {
        if sellingField.switch.isOn || buyingField.switch.isOn {
            viewModel.filter.offer.include = false
        }
        
        if sellingField.switch.isOn {
            viewModel.filter.offer.sellingCurrency = sellingField.textField.text
        } else {
            viewModel.filter.offer.sellingCurrency = nil
        }
        
        if buyingField.switch.isOn {
            viewModel.filter.offer.buyingCurrency = buyingField.textField.text
        } else {
            viewModel.filter.offer.buyingCurrency = nil
        }
    }
}

fileprivate extension OfferFilterViewController {
    func prepareView() {
        view.backgroundColor = Stylesheet.color(.lightGray)
        prepareCopyright()
        prepareContentView()
        prepareNavigationItem()
        
        prepareSelling()
        prepareBuying()
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
    
    func prepareSelling() {
        sellingField.label.text = "\(R.string.localizable.selling()) \(R.string.localizable.currency())"
        sellingField.textField.placeholder = R.string.localizable.all()
        sellingField.textField.textInset = horizontalSpacing
        sellingField.update(value: viewModel.filter.offer.sellingCurrency)
        
        contentView.addSubview(sellingField)
        sellingField.snp.makeConstraints { make in
            make.top.equalTo(verticalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareBuying() {
        buyingField.label.text = "\(R.string.localizable.buying()) \(R.string.localizable.currency())"
        buyingField.textField.placeholder = R.string.localizable.all()
        buyingField.textField.textInset = horizontalSpacing
        buyingField.update(value: viewModel.filter.offer.buyingCurrency)
        
        contentView.addSubview(buyingField)
        buyingField.snp.makeConstraints { make in
            make.top.equalTo(sellingField.snp.bottom).offset(verticalSpacing)
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
            make.top.equalTo(buyingField.snp.bottom).offset(verticalSpacing)
            make.centerX.equalToSuperview()
            make.width.equalTo(140)
            make.height.equalTo(40)
            make.bottom.equalTo(-verticalSpacing)
        }
    }
}

