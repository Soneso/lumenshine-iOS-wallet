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
    fileprivate var headerBar: FlexibleHeightBar!
    fileprivate var titleLabel = UILabel()
    fileprivate let tableView: UITableView
    
    fileprivate var dataSourceItems = [WebCard]()
    
    init(viewModel: HomeViewModelType) {
        self.viewModel = viewModel
        tableView = UITableView(frame: .zero, style: .grouped)
        super.init(nibName: nil, bundle: nil)
        
        dataSourceItems = [
            card(),
            card(),
            card(),
            card()
        ]
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
        prepareHeader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.shadowColor = Stylesheet.color(.clear)
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

        return cell
    }
    
}

extension HomeViewController:UITableViewDelegate {
}

extension HomeViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerBar.behaviorDefiner?.scrollViewDidScroll(scrollView)
        titleLabel.text = headerBar.progress < 0.65 ? "" : "TrendyStartup.io"
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        headerBar.behaviorDefiner?.scrollViewDidEndDecelerating(scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        headerBar.behaviorDefiner?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
}

fileprivate extension HomeViewController {
    func card() -> WebCard {
        let card = WebCard()
        
        let dateLabel = UILabel()
        dateLabel.font = RobotoFont.regular(with: 12)
        dateLabel.textColor = Color.blueGrey.base
        dateLabel.textAlignment = .center
        dateLabel.text = "2018.03.05"
        
        let contentView = UILabel()
        contentView.numberOfLines = 0
        contentView.text = "Material is an animation and graphics framework that is used to create beautiful applications. Material is an animation and graphics framework that is used to create beautiful applications.Material is an animation and graphics framework that is used to create beautiful applications.Material is an animation and graphics framework that is used to create beautiful applications.Material is an animation and graphics framework that is used to create beautiful applications.Material is an animation and graphics framework that is used to create beautiful applications."
        contentView.font = RobotoFont.regular(with: 14)
        
        let imageView = UIImageView()
        imageView.image = UIImage.image(with: Color.blue.lighten3, size: CGSize(width: 100, height: 100))
        card.setImage(UIImage.image(with: Color.blue.lighten3, size: CGSize(width: 100, height: 100)))
        
        card.setTitle("Test title")
        
        card.setDetail("Material is an animation and graphics framework that is used to create beautiful applications. Material is an animation and graphics framework that is used to create beautiful applications.Material is an animation and graphics framework that is used to create beautiful applications.Material is an animation and graphics framework that is used to create beautiful applications.Material is an animation and graphics framework that is used to create beautiful applications.Material is an animation and graphics framework that is used to create beautiful applications.")
        
        let button1 = FlatButton()
        button1.title = "Read more"
        card.setBottomBar(buttons: [button1])
        
        card.cornerRadiusPreset = .cornerRadius2
        card.depthPreset = .depth3
        return card
    }
    
    func prepareView() {
        view.backgroundColor = Stylesheet.color(.white)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = Stylesheet.color(.white)
        tableView.register(CardTableViewCell.self, forCellReuseIdentifier: HomeViewController.CellIdentifier)
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        
        titleLabel.textColor = Stylesheet.color(.white)
        titleLabel.textAlignment = .center
        navigationItem.centerViews = [titleLabel]
    }
    
    func prepareHeader() {
        headerBar = FlexibleHeightBar(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 100.0))
        headerBar.minimumBarHeight = 0.0

        headerBar.backgroundColor = Stylesheet.color(.cyan)
        view.addSubview(headerBar)

        tableView.contentInset = UIEdgeInsetsMake(100.0, 0.0, 0.0, 0.0)

        headerBar.behaviorDefiner = FacebookBarBehaviorDefiner()
        
        let label = UILabel();
        label.text = "TrendyStartup.io"
        label.font = UIFont.systemFont(ofSize: 25.0)
        label.textColor = UIColor.white
        label.sizeToFit()
        headerBar.addSubview(label)
        
        let initialLayoutAttributes = FlexibleHeightBarSubviewLayoutAttributes()
        initialLayoutAttributes.size = label.frame.size
        initialLayoutAttributes.center = CGPoint(x: headerBar.bounds.midX, y: headerBar.bounds.midY + 10.0)
        
        // This is what we want the bar to look like at its maximum height (progress == 0.0)
        headerBar.addLayoutAttributes(initialLayoutAttributes, forSubview: label, forProgress: 0.0)
        
        // Create a final set of layout attributes based on the same values as the initial layout attributes
        let finalLayoutAttributes = FlexibleHeightBarSubviewLayoutAttributes(layoutAttributes: initialLayoutAttributes)
        finalLayoutAttributes.alpha = 0.0
        let translation = CGAffineTransform(translationX: 0.0, y: -100.0)
        let scale = CGAffineTransform(scaleX: 0.2, y: 0.2)
        finalLayoutAttributes.transform = scale.concatenating(translation)
        
        // This is what we want the bar to look like at its minimum height (progress == 1.0)
        headerBar.addLayoutAttributes(finalLayoutAttributes, forSubview: label, forProgress: 1.0)
    }
    
    
    func prepareRefresh() {
        
        // Initialize tableView
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = Stylesheet.color(.white)
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            // Add your logic here
            // Do not forget to call dg_stopLoading() at the end
            self?.tableView.dg_stopLoading()
            }, loadingView: loadingView)
        tableView.dg_setPullToRefreshFillColor(Stylesheet.color(.cyan))
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
    }
}
