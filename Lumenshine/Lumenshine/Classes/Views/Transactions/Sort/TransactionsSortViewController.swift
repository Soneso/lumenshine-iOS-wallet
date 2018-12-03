//
//  TransactionsSortViewController.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 01/12/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class TransactionsSortViewController: UIViewController {
    
    // MARK: - Properties
    
    let viewModel: TransactionsViewModelType
    
    // MARK: - UI properties
    fileprivate let scrollView = UIScrollView()
    fileprivate let contentView = UIView()
    
    fileprivate let stackView: UIStackView
    fileprivate let subviews: [SortSwitch]
    
    fileprivate let clearButton = LSButton()
    
    fileprivate let verticalSpacing: CGFloat = 25.0
    fileprivate let horizontalSpacing: CGFloat = 15.0
    
    init(viewModel: TransactionsViewModelType) {
        self.viewModel = viewModel
        self.subviews = [SortSwitch(),
                         SortSwitch(),
                         SortSwitch(),
                         SortSwitch()]
        self.stackView = UIStackView(arrangedSubviews: subviews)
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
        saveSorter()
        viewModel.applySorter()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

extension TransactionsSortViewController {
    @objc
    func clearAction(sender: UIButton) {
        viewModel.clearSorter()
        updateValues(animated: true)
    }
    
    func saveSorter() {
        viewModel.sorter.date = subviews[0].switch.isOn ? subviews[0].button.isSelected : nil
        viewModel.sorter.type = subviews[1].switch.isOn ? subviews[1].button.isSelected : nil
        viewModel.sorter.amount = subviews[2].switch.isOn ? subviews[2].button.isSelected : nil
        viewModel.sorter.currency = subviews[3].switch.isOn ? subviews[3].button.isSelected : nil
    }
    
    func updateValues(animated: Bool = false) {
        subviews[0].switch.setOn(viewModel.sorter.date != nil, animated: animated)
        subviews[1].switch.setOn(viewModel.sorter.type != nil, animated: animated)
        subviews[2].switch.setOn(viewModel.sorter.amount != nil, animated: animated)
        subviews[3].switch.setOn(viewModel.sorter.currency != nil, animated: animated)
        
        if let value = viewModel.sorter.date {
            subviews[0].button.isSelected = value
        } else {
            subviews[0].button.isEnabled = false
        }
        
        if let value = viewModel.sorter.type {
            subviews[1].button.isSelected = value
        } else {
            subviews[1].button.isEnabled = false
        }
        
        if let value = viewModel.sorter.amount {
            subviews[2].button.isSelected = value
        } else {
            subviews[2].button.isEnabled = false
        }
        
        if let value = viewModel.sorter.currency {
            subviews[3].button.isSelected = value
        } else {
            subviews[3].button.isEnabled = false
        }
    }
}

fileprivate extension TransactionsSortViewController {
    func prepareView() {
        view.backgroundColor = Stylesheet.color(.lightGray)
        prepareCopyright()
        prepareContentView()
        prepareNavigationItem()
        
        prepareStackView()
        prepareButton()
    }
    
    func prepareNavigationItem() {
        navigationItem.titleLabel.text = R.string.localizable.transactions_sorting()
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
    
    func prepareStackView() {
        stackView.axis = .vertical
        stackView.spacing = 15
        
        subviews[0].label.text = R.string.localizable.date()
        subviews[1].label.text = R.string.localizable.type()
        subviews[2].label.text = R.string.localizable.amount()
        subviews[3].label.text = R.string.localizable.currency()
        
        let normalColor = Stylesheet.color(.cyan)
        let disabledColor = Stylesheet.color(.gray)
        
        subviews[0].button.setImage(R.image.sorter_91()?.tint(with: normalColor), for: .normal)
        subviews[0].button.setImage(R.image.sorter_19()?.tint(with: normalColor), for: .selected)
        subviews[0].button.setImage(R.image.sorter_91()?.tint(with: disabledColor), for: .disabled)
        
        subviews[1].button.setImage(R.image.sorter_AZ()?.tint(with: normalColor), for: .normal)
        subviews[1].button.setImage(R.image.sorter_ZA()?.tint(with: normalColor), for: .selected)
        subviews[1].button.setImage(R.image.sorter_AZ()?.tint(with: disabledColor), for: .disabled)
        
        subviews[2].button.setImage(R.image.sorter_91()?.tint(with: normalColor), for: .normal)
        subviews[2].button.setImage(R.image.sorter_19()?.tint(with: normalColor), for: .selected)
        subviews[2].button.setImage(R.image.sorter_91()?.tint(with: disabledColor), for: .disabled)
        
        subviews[3].button.setImage(R.image.sorter_AZ()?.tint(with: normalColor), for: .normal)
        subviews[3].button.setImage(R.image.sorter_ZA()?.tint(with: normalColor), for: .selected)
        subviews[3].button.setImage(R.image.sorter_AZ()?.tint(with: disabledColor), for: .disabled)
        
        updateValues()
        
        var i = stackView.arrangedSubviews.count
        while i > 1 {
            let separator = verticalCreateSeparator(color: Stylesheet.color(.gray))
            stackView.insertArrangedSubview(separator, at: i-1)
            i -= 1
        }
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(verticalSpacing)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
        }
    }
    
    func verticalCreateSeparator(color : UIColor) -> UIView {
        let separator = UIView()
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        separator.backgroundColor = color
        return separator
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
            make.top.equalTo(stackView.snp.bottom).offset(verticalSpacing)
            make.centerX.equalToSuperview()
            make.width.equalTo(140)
            make.height.equalTo(40)
            make.bottom.equalTo(-verticalSpacing)
        }
    }
}



