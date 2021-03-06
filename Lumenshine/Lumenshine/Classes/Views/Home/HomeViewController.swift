//
//  HomeViewController.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material
import DGElasticPullToRefresh
import MessageUI

class HomeViewController: UpdatableViewController {
    
    fileprivate static let CellIdentifier = "CardTableViewCell"
    
    // MARK: - Properties
    
    fileprivate let viewModel: HomeViewModelType
    fileprivate var headerBar: CustomizableFlexibleHeightBar!
    fileprivate var header: HomeHeaderView!
    fileprivate var tableViewContainer: UIView!

    fileprivate let tableView: UITableView
    public var dataSourceItems = [CardView]()
    
    init(viewModel: HomeViewModelType) {
        self.viewModel = viewModel
        tableView = UITableView(frame: .zero, style: .grouped)
        super.init(nibName: nil, bundle: nil)
        hasWallets = true
        viewModel.reloadClosure = { [weak self] in
            DispatchQueue.main.async {
                if let wself = self {
                    wself.dataSourceItems = wself.viewModel.cardViewModels.map {
                        CardView.create(viewModel: $0, viewController: wself)
                    }
                    wself.tableView.reloadData()
                    wself.refreshHeaderType()
                }
            }
        }
        
        viewModel.appendClosure = { [weak self] chartViewModel in
            DispatchQueue.main.async {
                if let wself = self {
                    let cardView = CardView.create(viewModel: chartViewModel, viewController: wself)
                    wself.dataSourceItems.insert(cardView, at: wself.dataSourceItems.count-1)
                    wself.tableView.reloadData()
                }
            }
        }
        
        viewModel.totalNativeFoundsClosure = { [weak self] (nativeFounds) in
           self?.setHeaderType(nativeFounds: nativeFounds)
        }
        
        viewModel.currencyRateUpdateClosure = { [weak self] (rate) in
            if let nativeFunds = Services.shared.userManager.totalNativeFunds {
                if (nativeFunds == 0 || rate == 0) {
                    self?.header?.funds = ""
                } else {
                    self?.header?.funds = nativeFunds.tickerConversionTo(currency: .usd, rate: rate)
                }
            }
        }
        
        viewModel.scrollToItemClosure = { [weak self] (index) in
            DispatchQueue.main.async {
                self?.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("HomeViewController deinit")
        tableView.dg_removePullToRefresh()
    }
    
    override func viewDidLoad() {
        prepareHeader()
        prepareView()
        prepareRefresh()
        viewModel.reloadData()
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.shadowColor = Stylesheet.color(.clear)
        navigationController?.navigationBar.backgroundColor = Stylesheet.color(.clear)
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.titleLabel.textColor = Stylesheet.color(.blue)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 18)
        navigationItem.titleLabel.text = R.string.localizable.homeScreenTitle()
        viewModel.refreshWallets()
        super.viewWillAppear(animated)
    }
    
    override func cleanup() {
        viewModel.cleanup()
        dataSourceItems.removeAll()
        super.cleanup()
    }
    
    override func refreshWallets(notification: NSNotification) {
        print("HomeViewController - refresh wallets \(ObjectIdentifier(self))")
        viewModel.refreshWallets()
        if let updateHeader = notification.object as? Bool, updateHeader {
            viewModel.updateHeaderData()
        }
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeViewController.CellIdentifier, for: indexPath) as! CardTableViewCell

        if dataSourceItems.count < indexPath.row {
            return cell
        }
        
        cell.card = dataSourceItems[indexPath.row]
        cell.selectionStyle = .none

        if let card = dataSourceItems[indexPath.row] as? WalletCard {
            card.reloadCellAction = { [weak self] reload in
                if reload {
                    self?.tableView.reloadData()
                } else {
                    if #available(iOS 11.0, *) {
                        self?.tableView.performBatchUpdates({
                            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                        }, completion: nil)
                    } else {
                        self?.tableView.beginUpdates()
                        self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                        self?.tableView.endUpdates()
                    }
                }
            }
        }
        return cell
    }
    
}

extension HomeViewController: UITableViewDelegate {
    
}

extension HomeViewController: HeaderMenuDelegate {
    func menuSelected(at index: Int) {
        
    }
    
    func headerMenuDidDismiss(_ headerMenu: HeaderMenuViewController) {
        
    }
}

extension HomeViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // fix layout subviews scrollviewDidScroll cycle
        if scrollView.isDragging {
            headerBar.behaviorDefiner?.scrollViewDidScroll(scrollView)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        headerBar.behaviorDefiner?.scrollViewDidEndDecelerating(scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        headerBar.behaviorDefiner?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
}

fileprivate extension HomeViewController {
    func prepareView() {
        tableViewContainer.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = Stylesheet.color(.clear)
        tableView.register(CardTableViewCell.self, forCellReuseIdentifier: HomeViewController.CellIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 250
        tableView.separatorStyle = .none
        
        prepareCopyright()
    }
    
    func prepareHeader() {
        setupHeaderBar()
        view.addSubview(headerBar)

        headerBar.behaviorDefiner = FacebookBarBehaviorDefiner()
        
        let label = UILabel()
        label.text = R.string.localizable.homeScreenTitle()
        label.font = UIFont.systemFont(ofSize: 25.0)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.sizeToFit()
        
        header = HomeHeaderView()
        header.unfundedView.foundAction = { [weak self] (button) in
            self?.viewModel.fundAccount()
        }
        
        headerBar.addSubview(header)
        header.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(0)
            make.bottom.equalTo(0)
        }
        
        headerBar.header = header

        tableViewContainer = UIView()
        view.addSubview(tableViewContainer)
        tableViewContainer.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
        }
        
        tableViewContainer.topAnchor.constraint(equalTo: headerBar.bottomAnchor, constant: -1).isActive = true
        tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: headerBar.maximumBarHeight + 20, right: 0.0)
        
        let initialLayoutAttributes = FlexibleHeightBarSubviewLayoutAttributes()
        initialLayoutAttributes.size = headerBar.frame.size
        initialLayoutAttributes.center = CGPoint(x: headerBar.bounds.midX, y: headerBar.bounds.minY + 10.0)
        
        // This is what we want the bar to look like at its maximum height (progress == 0.0)
        headerBar.addLayoutAttributes(initialLayoutAttributes, forSubview: label, forProgress: 0.0)
        
        // Create a final set of layout attributes based on the same values as the initial layout attributes
        let finalLayoutAttributes = FlexibleHeightBarSubviewLayoutAttributes(layoutAttributes: initialLayoutAttributes)
        finalLayoutAttributes.alpha = 0.0
        
        // This is what we want the bar to look like at its minimum height (progress == 1.0)
        headerBar.addLayoutAttributes(finalLayoutAttributes, forSubview: label, forProgress: 1.0)
    }
    
    
    func prepareRefresh() {
        // Initialize tableView
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = Stylesheet.color(.blue)
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            Services.shared.walletService.removeAllCachedAccountDetails()
            self?.viewModel.reloadData()
            self?.tableView.dg_stopLoading()
            }, loadingView: loadingView)
        tableView.dg_setPullToRefreshFillColor(Stylesheet.color(.purple))
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
    }
    
    private func setupHeaderBar() {
        var topSafeAreaInset = CGFloat(0)
        
        if let window = UIApplication.shared.keyWindow {
            if #available(iOS 11.0, *) {
                topSafeAreaInset = window.safeAreaInsets.top
            }
        }
        
        headerBar = CustomizableFlexibleHeightBar(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 230 + topSafeAreaInset))
        headerBar.minimumBarHeight = topSafeAreaInset
        headerBar.clipsToBounds = true
        let backgroundImage = UIImageView()
        backgroundImage.image = R.image.header_background()
        
        headerBar.insertSubview(backgroundImage, at: 0)
        backgroundImage.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.right.equalTo(1)
            make.top.equalTo(0)
            make.bottom.equalTo(0)
        }
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
            make.left.right.equalToSuperview()
            make.bottom.equalTo(imageView.snp.top)
        }
        
        tableView.backgroundView = backgroundView
    }
    
    func setHeaderType(nativeFounds: CoinUnit) {
        if nativeFounds > 0 {
            self.header?.type = .funded
        } else {
            self.header?.type = .unfunded
        }
    }
    
    func refreshHeaderType() {
        Services.shared.userManager.totalNativeFounds { (result) -> (Void) in
            switch result {
            case .success(let data):
                self.setHeaderType(nativeFounds: data)
            case .failure(_):
                // TODO: handle this
                print("Failed to get wallets")
            }
        }
    }
}

extension HomeViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}

