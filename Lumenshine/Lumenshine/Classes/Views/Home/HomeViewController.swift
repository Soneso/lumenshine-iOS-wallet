//
//  HomeViewController.swift
//  jupiter
//
//  Created by Istvan Elekes on 3/5/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material
import DGElasticPullToRefresh

class HomeViewController: UIViewController {
    
    fileprivate static let CellIdentifier = "CardTableViewCell"
    
    // MARK: - Properties
    
    fileprivate let viewModel: HomeViewModelType
    fileprivate var headerBar: CustomizableFlexibleHeightBar!
    fileprivate var header: HomeHeaderView!
    fileprivate var tableViewContainer: UIView!
    
    fileprivate var userManager: UserManager {
        get {
            return Services.shared.userManager
        }
    }
    
    fileprivate let tableView: UITableView
    public var dataSourceItems = [CardView]()
    
    init(viewModel: HomeViewModelType) {
        self.viewModel = viewModel
        tableView = UITableView(frame: .zero, style: .grouped)
        super.init(nibName: nil, bundle: nil)
        viewModel.reloadClosure = {
            DispatchQueue.main.async {
                self.dataSourceItems = self.viewModel.cardViewModels.map {
                    CardView.create(viewModel: $0, viewController: self)
                }
                self.tableView.reloadData()
                self.refreshHeaderType()
            }
        }
        
        viewModel.appendClosure = { chartViewModel in
            DispatchQueue.main.async {
                let cardView = CardView.create(viewModel: chartViewModel, viewController: self)
                self.dataSourceItems.insert(cardView, at: self.dataSourceItems.count-1)
                self.tableView.reloadData()
            }
        }
        
        viewModel.totalNativeFoundsClosure = { (nativeFounds) in
           self.setHeaderType(nativeFounds: nativeFounds)
        }
        
        viewModel.currencyRateUpdateClosure = { (rate) in
            if let nativeFunds = Services.shared.userManager.totalNativeFunds {
                self.header?.funds = nativeFunds.stringConversionTo(currency: .usd, rate: rate)
            }
        }
        
        viewModel.scrollToItemClosure = { (index) in
            DispatchQueue.main.async {
                self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        tableView.dg_removePullToRefresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareHeader()
        prepareView()
        prepareRefresh()
        
        viewModel.reloadCards()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.shadowColor = Stylesheet.color(.clear)
        navigationController?.navigationBar.backgroundColor = Stylesheet.color(.clear)
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.titleLabel.textColor = Stylesheet.color(.blue)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 18)
        navigationItem.titleLabel.text = R.string.localizable.homeScreenTitle()
        viewModel.refreshWallets()
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeViewController.CellIdentifier, for: indexPath) as! CardTableViewCell

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
                
                self?.viewModel.updateCurrencies()
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
        tableView.rowHeight = UITableViewAutomaticDimension
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
        //header.type = .unfunded
        header.unfundedView.foundAction = {(button) in
            self.viewModel.foundAccount()
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
        tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, headerBar.maximumBarHeight + 20, 0.0)
        
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
            // Add your logic here
           self?.viewModel.reloadCards()
            
            // Do not forget to call dg_stopLoading() at the end
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
        userManager.totalNativeFounds { (result) -> (Void) in
            switch result {
            case .success(let data):
                self.setHeaderType(nativeFounds: data)
            case .failure(_):
                print("Failed to get wallets")
            }
        }
    }
}
