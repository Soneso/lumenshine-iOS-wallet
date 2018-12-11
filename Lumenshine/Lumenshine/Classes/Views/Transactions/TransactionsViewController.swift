//
//  TransactionsViewController.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 02/11/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class TransactionsViewController: UITableViewController {
    
    // MARK: - Parameters & Constants
    
    fileprivate static let CellIdentifier = "TransactionsCell"
    
    // MARK: - Properties
    
    fileprivate let walletLabel = UILabel()
    fileprivate let dateFromLabel = UILabel()
    fileprivate let dateToLabel = UILabel()
    fileprivate let filterButton = LSButton()
    fileprivate let sortButton = LSButton()
    
    fileprivate let verticalSpacing = 31.0
    fileprivate let horizontalSpacing = 15.0
    fileprivate let viewModel: TransactionsViewModelType
    
    init(viewModel: TransactionsViewModelType) {
        self.viewModel = viewModel
        super.init(style: .grouped)
        
        viewModel.reloadClosure = {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        viewModel.showActivityClosure = {
            DispatchQueue.main.async {
                self.showActivity(message: R.string.localizable.loading(), animated: false)
            }
        }
        
        viewModel.hideActivityClosure = {
            DispatchQueue.main.async {
                self.hideActivity(animated: false)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepare()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateHeader()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.applyFilters()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemCount
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = TransactionsViewController.CellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        if var tableCell = cell as? TransactionsCellProtocol {
            tableCell.setDate(viewModel.date(at: indexPath))
            tableCell.setType(viewModel.type(at: indexPath))
            tableCell.setAmount(viewModel.amount(at: indexPath))
            tableCell.setCurrency(viewModel.currency(at: indexPath))
            tableCell.setFee(viewModel.feePaid(at: indexPath))
            tableCell.setOfferId(viewModel.offer(at: indexPath), transactionHash:viewModel.transactionHash(at: indexPath))
            tableCell.setDetails(viewModel.details(at: indexPath))
            tableCell.delegate = self
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let separator = UIView()
        separator.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 12)
        separator.backgroundColor = .white
        
        let label = UILabel()
        label.text = R.string.localizable.transactions()
        label.textColor = Stylesheet.color(.blue)
        label.font = R.font.encodeSansSemiBold(size: 15)
        
        if viewModel.itemCount == 0 {
            label.text = R.string.localizable.no_transactions_found()
            label.textColor = Stylesheet.color(.darkGray)
        }

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
        viewModel.itemSelected(at: indexPath)
    }
}

extension TransactionsViewController: TransactionsCellDelegate {
    func cellCopiedToPasteboard(_ cell: TransactionsCellProtocol) {
        let alert = UIAlertController(title: nil, message: R.string.localizable.copied_clipboard(), preferredStyle: .actionSheet)
        self.present(alert, animated: true)
        let when = DispatchTime.now() + 0.75
        DispatchQueue.main.asyncAfter(deadline: when){
            alert.dismiss(animated: true)
        }
    }
    
    func cell(_ cell: TransactionsCellProtocol, didInteractWith url: URL) {
        viewModel.showOperationDetails(operationId: url.lastPathComponent)
    }
}

extension TransactionsViewController {
    @objc
    func filterAction(sender: UIButton) {
        viewModel.filterClick()
    }
    
    @objc
    func sortAction(sender: UIButton) {
        viewModel.sortClick()
    }
    
    func updateHeader() {
        let name = viewModel.wallets.count > 0 ? viewModel.wallets[viewModel.walletIndex] : R.string.localizable.primary()
        walletLabel.text = "\(name) \(R.string.localizable.wallet())"
        let dateFrom = DateUtils.format(viewModel.dateFrom, in: .date) ?? viewModel.dateFrom.description
        dateFromLabel.text = "\(R.string.localizable.date_from()): \(dateFrom)"
        let dateTo = DateUtils.format(viewModel.dateTo, in: .date) ?? viewModel.dateTo.description
        dateToLabel.text = "\(R.string.localizable.date_to()): \(dateTo)"
    }
}


fileprivate extension TransactionsViewController {
    func prepare() {
        prepareTableView()
        prepareCopyright()
        prepareNavigationItem()
    }
    
    func prepareTableView() {
        tableView.register(TransactionsTableViewCell.self, forCellReuseIdentifier: TransactionsViewController.CellIdentifier)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = Stylesheet.color(.lightGray)
        tableView.separatorInset = UIEdgeInsetsMake(0, 50, 0, 50)
        if #available(iOS 11.0, *) {
            tableView.separatorInsetReference = .fromAutomaticInsets
        }
        let headerView = prepareTableHeader()
        headerView.frame = CGRect(origin: .zero, size: CGSize(width: 30, height: 80))
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
    }
    
    func prepareNavigationItem() {
        
        snackbarController?.navigationItem.titleLabel.text = R.string.localizable.transactions()
        snackbarController?.navigationItem.titleLabel.textColor = Stylesheet.color(.blue)
        snackbarController?.navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        
        navigationController?.navigationBar.setBackgroundImage(R.image.nav_background(), for: .default)
    }
    
    func prepareTableHeader() -> UIView {
        let headerView = UIView()
        
        walletLabel.textColor = Stylesheet.color(.black)
        walletLabel.font = R.font.encodeSansSemiBold(size: 13)
        walletLabel.adjustsFontSizeToFitWidth = true
        
        headerView.addSubview(walletLabel)
        walletLabel.snp.makeConstraints { (make) in
            make.top.equalTo(horizontalSpacing)
            make.left.equalTo(horizontalSpacing + 15)
        }
        
        dateFromLabel.textColor = Stylesheet.color(.darkGray)
        dateFromLabel.font = R.font.encodeSansRegular(size: 13)
        dateFromLabel.adjustsFontSizeToFitWidth = true
        
        headerView.addSubview(dateFromLabel)
        dateFromLabel.snp.makeConstraints { (make) in
            make.top.equalTo(walletLabel.snp.bottom)
            make.left.equalTo(walletLabel)
        }
        
        dateToLabel.text = R.string.localizable.unlock_app()
        dateToLabel.textColor = Stylesheet.color(.darkGray)
        dateToLabel.font = R.font.encodeSansRegular(size: 13)
        dateToLabel.adjustsFontSizeToFitWidth = true
        
        headerView.addSubview(dateToLabel)
        dateToLabel.snp.makeConstraints { (make) in
            make.top.equalTo(dateFromLabel.snp.bottom)
            make.left.equalTo(walletLabel)
        }
        
        sortButton.title = R.string.localizable.sort().uppercased()
        sortButton.titleColor = Stylesheet.color(.blue)
        sortButton.borderWidthPreset = .border1
        sortButton.borderColor = Stylesheet.color(.blue)
        sortButton.cornerRadiusPreset = .cornerRadius5
        sortButton.setGradientLayer(color: Stylesheet.color(.white))
        sortButton.addTarget(self, action: #selector(sortAction(sender:)), for: .touchUpInside)
        
        headerView.addSubview(sortButton)
        sortButton.snp.makeConstraints { make in
            make.right.equalTo(-horizontalSpacing)
            make.centerY.equalTo(dateFromLabel)
            make.width.equalTo(80)
            make.height.equalTo(36)
        }
        
        filterButton.title = R.string.localizable.filter().uppercased()
        filterButton.titleColor = Stylesheet.color(.blue)
        filterButton.borderWidthPreset = .border1
        filterButton.borderColor = Stylesheet.color(.blue)
        filterButton.cornerRadiusPreset = .cornerRadius5
        filterButton.setGradientLayer(color: Stylesheet.color(.white))
        filterButton.addTarget(self, action: #selector(filterAction(sender:)), for: .touchUpInside)
        
        headerView.addSubview(filterButton)
        filterButton.snp.makeConstraints { make in
            make.right.equalTo(sortButton.snp.left).offset(-10)
            make.centerY.equalTo(dateFromLabel)
            make.width.equalTo(80)
            make.height.equalTo(36)
        }
        
        return headerView
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
        tableView.backgroundView?.isUserInteractionEnabled = true
    }
}


