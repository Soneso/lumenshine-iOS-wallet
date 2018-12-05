//
//  OtherFilterViewController.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 26/11/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class OtherFilterViewController: UIViewController {
    
    // MARK: - Properties
    
    let viewModel: TransactionsViewModelType
    
    // MARK: - UI properties
    fileprivate let scrollView = UIScrollView()
    fileprivate let contentView = UIView()
    
    fileprivate let stackView: UIStackView
    fileprivate let subviews: [SwitchLabel]
    
    fileprivate let clearButton = LSButton()
    
    fileprivate let verticalSpacing: CGFloat = 25.0
    fileprivate let horizontalSpacing: CGFloat = 15.0
    
    init(viewModel: TransactionsViewModelType) {
        self.viewModel = viewModel
        self.subviews = [SwitchLabel(),
                         SwitchLabel(),
                         SwitchLabel(),
                         SwitchLabel(),
                         SwitchLabel()]
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
        saveFilter()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

extension OtherFilterViewController {
    @objc
    func clearAction(sender: UIButton) {
        viewModel.filter.offer.clear()
        updateValues(animated: true)
    }
    
    func saveFilter() {
        if subviews.first(where: {$0.switch.isOn}) != nil {
            viewModel.filter.other.include = false
        }
        viewModel.filter.other.setOptions = subviews[0].switch.isOn
        viewModel.filter.other.manageData = subviews[1].switch.isOn
        viewModel.filter.other.trust = subviews[2].switch.isOn
        viewModel.filter.other.accountMerge = subviews[3].switch.isOn
        viewModel.filter.other.bumpSequence = subviews[4].switch.isOn
    }
    
    func updateValues(animated: Bool = false) {
        subviews[0].switch.setOn(viewModel.filter.other.setOptions ?? false, animated: animated)
        subviews[1].switch.setOn(viewModel.filter.other.manageData ?? false, animated: animated)
        subviews[2].switch.setOn(viewModel.filter.other.trust ?? false, animated: animated)
        subviews[3].switch.setOn(viewModel.filter.other.accountMerge ?? false, animated: animated)
        subviews[4].switch.setOn(viewModel.filter.other.bumpSequence ?? false, animated: animated)
    }
}

fileprivate extension OtherFilterViewController {
    func prepareView() {
        view.backgroundColor = Stylesheet.color(.lightGray)
        prepareCopyright()
        prepareContentView()
        prepareNavigationItem()
        
        prepareStackView()
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
    
    func prepareStackView() {
        stackView.axis = .vertical
        stackView.spacing = 15
        
        subviews[0].label.text = R.string.localizable.set_options()
        subviews[1].label.text = R.string.localizable.manage_data()
        subviews[2].label.text = R.string.localizable.trust()
        subviews[3].label.text = R.string.localizable.merge_account()
        subviews[4].label.text = R.string.localizable.bump_sequence()
        
        updateValues()
        
        var i = stackView.arrangedSubviews.count
        while i > 1 {
            let separator = verticalCreateSeparator(color: Stylesheet.color(.gray))
            stackView.insertArrangedSubview(separator, at: i-1)   // (i-1) for centers only
//            separator.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 1).isActive = true
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


