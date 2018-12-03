//
//  WalletsViewController.swift
//  Lumenshine
//
//  Created by Soneso on 24/10/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import DGElasticPullToRefresh
import Material

class WalletsViewController: UpdatableViewController, UITableViewDataSource {
    private let cellIdentifier = "CardTableViewCell"
    private let viewModel: HomeViewModelType!
    private let tableView: UITableView!
    private var walletService: WalletsService {
        get {
            return Services.shared.walletService
        }
    }
    
    private var userManager: UserManager {
        get {
            return Services.shared.userManager
        }
    }
    
    public var dataSourceItems = [CardView]()
    
    init(viewModel: HomeViewModelType) {
        self.viewModel = viewModel
        tableView = UITableView(frame: .zero, style: .grouped)
        super.init(nibName: nil, bundle: nil)
        hasWallets = true
        
        viewModel.reloadClosure = {
            DispatchQueue.main.async {
                self.dataSourceItems = self.viewModel.cardViewModels.map {
                    CardView.create(viewModel: $0, viewController: self)
                }
                
                self.tableView.reloadData()
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
        prepareView()
        prepareRefresh()
        setupNavigationItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadCards()
        NotificationCenter.default.post(name: Notification.Name(Keys.Notifications.MenuItemChanged), object: MenuEntry.wallets)
    }
    
    private func prepareView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        tableView.dataSource = self
        tableView.backgroundColor = Stylesheet.color(.clear)
        tableView.register(CardTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 250
        tableView.separatorStyle = .none
        
        prepareCopyright()
    }
    
    private func prepareRefresh() {
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = Stylesheet.color(.blue)
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self?.reloadCards()
            self?.tableView.dg_stopLoading()
            }, loadingView: loadingView)
        tableView.dg_setPullToRefreshFillColor(Stylesheet.color(.purple))
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
    }
    
    private func prepareCopyright() {
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
    
    private func setupNavigationItem() {
        navigationItem.titleLabel.text = R.string.localizable.wallets()
        navigationItem.titleLabel.textColor = Stylesheet.color(.blue)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 18)
        
        let addWallet = Material.IconButton()
        addWallet.image = R.image.plusIcon()?.crop(toWidth: 20, toHeight: 20)?.tint(with: Stylesheet.color(.blue))
        addWallet.addTarget(self, action: #selector(didTapAddWallet(_:)), for: .touchUpInside)
        navigationItem.rightViews = [addWallet]

    }
    
    @IBAction func didTapAddWallet(_ sender: Any) {
        let addWalletVC = AddWalletViewController()
        addWalletVC.walletCount = dataSourceItems.count
        navigationController?.pushViewController(addWalletVC, animated: true)
    }
    
    func reloadCards() {
        if let viewmodel = viewModel as? HomeViewModel {
            viewmodel.cardViewModels.removeAll()
            walletService.getWallets { (result) -> (Void) in
                switch result {
                case .success(let wallets):
                    let sortedWallets = wallets.sorted(by: { $0.id < $1.id })
                    for wallet in sortedWallets {
                        let walletCardViewModel = WalletCardViewModel(userManager: self.userManager, walletResponse: wallet)
                        walletCardViewModel.navigationCoordinator = viewmodel.navigationCoordinator
                        viewmodel.cardViewModels.append(walletCardViewModel)
                    }
                    
                WebSocketService.wallets = wallets
                case .failure(_):
                    print("Failed to get wallets")
                }
                
                viewmodel.reloadClosure?()
                
                viewmodel.showWalletIfNeeded()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CardTableViewCell
        
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
    
    override func reloadWallets() {
        reloadCards()
    }
}
