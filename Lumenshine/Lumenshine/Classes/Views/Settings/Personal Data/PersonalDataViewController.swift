//
//  PersonalDataViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 10/17/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class PersonalDataViewController: UITableViewController {
    
    // MARK: - Parameters & Constants
    
    // MARK: - Properties
    
    fileprivate let verticalSpacing = 31.0
    fileprivate let horizontalSpacing = 15.0
    fileprivate let viewModel: PersonalDataViewModelType
    fileprivate let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    init(viewModel: PersonalDataViewModelType) {
        self.viewModel = viewModel
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepare()
        
        activityIndicator.startAnimating()
        viewModel.getUserData { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.tableView.reloadData()
                case .failure(let error):
                    let alert = AlertFactory.createAlert(error: error)
                    self?.present(alert, animated: true)
                }
                self?.activityIndicator.stopAnimating()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.itemDistribution.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemDistribution[section]
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = viewModel.cellIdentifier(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        if let inputCell = cell as? MultilineInputTableViewCell {
            inputCell.cellSizeChangedCallback = { height in
                self.viewModel.cellHeightChanged(height, at: indexPath)
            }
        }
        
        if let tableCell = cell as? InputTableViewCell {
            tableCell.setText(viewModel.textValue(at: indexPath))
            tableCell.setPlaceholder(viewModel.placeholder(at: indexPath))
            
            let (options, selectedIndex) = viewModel.inputViewOptions(at: indexPath)
            tableCell.setInputViewOptions(options, selectedIndex: selectedIndex)
            tableCell.setDateInputView(viewModel.isDateInputView(at: indexPath))
            tableCell.setKeyboardType(viewModel.keyboardType(at: indexPath))
            tableCell.textEditingCallback = { changedText in
                self.viewModel.textChanged(changedText, itemForRowAt: indexPath)
            }
            tableCell.shouldBeginEditingCallback = {
                return self.viewModel.shouldBeginEditing(at: indexPath)
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight(at: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.sectionTitle(at: section) == nil ? 25 : 50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let separator = UIView()
        separator.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 12)
        separator.backgroundColor = .white
        
        let label = UILabel()
        label.text = viewModel.sectionTitle(at: section)
        label.textColor = Stylesheet.color(.blue)
        label.font = R.font.encodeSansSemiBold(size: 15)
        
        separator.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
            make.bottom.equalTo(-10)
        }
        
        let header = UIView()
        header.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
            make.bottom.equalToSuperview()
        }
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 25
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let separator = UIView()
        separator.roundCorners([.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 12)
        separator.backgroundColor = .white
        //        separator.depthPreset = .depth3
        
        let header = UIView()
        header.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(horizontalSpacing)
            make.right.equalTo(-horizontalSpacing)
            make.bottom.equalTo(-5)
        }
        return header
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

extension PersonalDataViewController {
    @objc
    func saveAction(sender: UIButton) {
        viewModel.submit { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    let alert = AlertFactory.createAlert(error: error)
                    self?.navigationController?.present(alert, animated: true)
                }
            }
        }
    }
    
    @objc
    func backAction(sender: UIButton) {
        if viewModel.isDataChanged {
            let alertView = UIAlertController(title: R.string.localizable.personal_data_changed(),
                                              message: nil,
                                              preferredStyle: .alert)
            let okAction = UIAlertAction(title: R.string.localizable.save(), style: .default, handler: { action in
                self.saveAction(sender: sender)
            })
            alertView.addAction(okAction)
            
            let cancelAction = UIAlertAction(title: R.string.localizable.ignore(), style: .cancel, handler: { action in
                self.navigationController?.popViewController(animated: true)
            })
            alertView.addAction(cancelAction)
            
            navigationController?.present(alertView, animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}

fileprivate extension PersonalDataViewController {
    func prepare() {
        prepareTableView()
        prepareCopyright()
        prepareNavigationItem()
    }
    
    func prepareTableView() {
        tableView.register(MultilineInputTableViewCell.self, forCellReuseIdentifier: MultilineInputTableViewCell.CellIdentifier)
        tableView.register(InputTableViewCell.self, forCellReuseIdentifier: InputTableViewCell.CellIdentifier)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        tableView.tableFooterView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        
        viewModel.cellSizeRefreshCallback = {
            UIView.setAnimationsEnabled(false)
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }
    
    func prepareNavigationItem() {
        let doneButton = LSButton()
        doneButton.backgroundColor = Stylesheet.color(.whiteWith(alpha: 0.2))
        doneButton.title = R.string.localizable.submit()
        doneButton.titleColor = Stylesheet.color(.blue)
        doneButton.cornerRadiusPreset = .cornerRadius5
        doneButton.addTarget(self, action: #selector(saveAction(sender:)), for: .touchUpInside)
        
        viewModel.dataChangedClosure = {
            self.navigationItem.rightViews = [doneButton]
        }
        
        navigationItem.rightViews = [activityIndicator]
        navigationItem.backButton.isHidden = true
        
        let backButton = Material.IconButton()
        backButton.image = Icon.arrowBack?.tint(with: Stylesheet.color(.blue))
        backButton.addTarget(self, action: #selector(backAction(sender:)), for: .touchUpInside)
        navigationItem.leftViews = [backButton]
        
        navigationItem.titleLabel.text = R.string.localizable.personal_data()
        navigationItem.titleLabel.textColor = Stylesheet.color(.blue)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
    }
    
    func prepareCopyright() {
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = Stylesheet.color(.lightGray)
        
        let imageView = UIImageView(image: R.image.soneso())
        imageView.backgroundColor = Stylesheet.color(.clear)
        
        backgroundView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.bottom.equalTo(-20)
            make.centerX.equalToSuperview()
        }
        
        let background = UIImageView(image: R.image.soneso_background())
        background.contentMode = .scaleAspectFit
        
        backgroundView.addSubview(background)
        background.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview()
            make.left.right.equalToSuperview()
            make.bottom.equalTo(imageView.snp.top)
        }
        
        tableView.backgroundView = backgroundView
    }
}

