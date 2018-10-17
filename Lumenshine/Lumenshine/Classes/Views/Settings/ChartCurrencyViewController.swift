//
//  ChartCurrencyViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 10/16/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class ChartCurrencyViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate let viewModel: SettingsViewModelType
    
    // MARK: - UI properties
    
    fileprivate let horizontalSpacing: CGFloat = 15.0
    fileprivate let titleLabel = UILabel()
    fileprivate let currencyPicker = UITextField()
    
    init(viewModel: SettingsViewModelType) {
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
        prepareNavigationItem()
        
        viewModel.destinationCurrencies() { result in
            switch result {
            case .success(let response):
                self.setPeriodPicker(response, selectedIndex: 0)
            case .failure(let error):
                print("Failed to get chart currency pairs: \(error)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func setPeriodPicker(_ options: [String], selectedIndex: Int) {
        let enumPicker = EnumPicker()
        enumPicker.setValues(options, currentSelection: selectedIndex) { [weak self] newIndex in
            self?.currencyPicker.text = options[newIndex]
            self?.viewModel.destinationCurrencySelected(options[newIndex])
        }
        currencyPicker.inputView = enumPicker
        currencyPicker.text = options[selectedIndex]
    }
}

fileprivate extension ChartCurrencyViewController {
    func prepareView() {
        view.backgroundColor = Stylesheet.color(.white)
        prepareTitle()
        prepareTextField()
    }
    
    func prepareTitle() {
        titleLabel.text = R.string.localizable.chart_currency_hint()
        titleLabel.textColor = Stylesheet.color(.lightBlack)
        titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(horizontalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func prepareTextField() {
        currencyPicker.textColor = Stylesheet.color(.darkBlue)
        currencyPicker.font = R.font.encodeSansSemiBold(size: 14)
        currencyPicker.adjustsFontSizeToFitWidth = true
        currencyPicker.borderStyle = .roundedRect
        currencyPicker.rightViewMode = .always
        currencyPicker.rightView = UIImageView(image: Icon.cm.arrowDownward?.tint(with: Stylesheet.color(.gray)))
        
        view.addSubview(currencyPicker)
        currencyPicker.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }
    
    func prepareNavigationItem() {
        navigationItem.titleLabel.text = R.string.localizable.chart_currency()
        navigationItem.titleLabel.textColor = Stylesheet.color(.blue)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
    }
}

