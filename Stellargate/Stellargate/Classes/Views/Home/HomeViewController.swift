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

class HomeViewController: CardCollectionViewController {
    
    // MARK: - Properties
    
    fileprivate let viewModel: HomeViewModelType
    fileprivate var headerBar: FlexibleHeightBar!
    fileprivate var titleLabel = UILabel()
    
    init(viewModel: HomeViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        collectionView.dg_removePullToRefresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        prepareRefresh()
        prepareHeader()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: animated)
//    }
}

extension HomeViewController {
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! CardCollectionViewCell
        
        return cell
    }
    
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
    func imageCard() -> ImageCard {
        let card = ImageCard()
        
        let favoriteButton = IconButton(image: Icon.favorite, tintColor: Color.red.base)
        let shareButton = IconButton(image: Icon.cm.share, tintColor: Color.blueGrey.base)
        
        let dateLabel = UILabel()
        dateLabel.font = RobotoFont.regular(with: 12)
        dateLabel.textColor = Color.blueGrey.base
        dateLabel.textAlignment = .center
        dateLabel.text = "2018.03.05"
        
        let contentView = UILabel()
        contentView.numberOfLines = 0
        contentView.text = "Material is an animation and graphics framework that is used to create beautiful applications."
        contentView.font = RobotoFont.regular(with: 14)
        
        let imageView = UIImageView()
        imageView.image = UIImage.image(with: Color.blue.lighten3, size: CGSize(width: 100, height: 100))
        card.imageView = imageView
        
        card.contentView = contentView
        card.contentViewEdgeInsetsPreset = .square3
        
        card.bottomBar = Bar(leftViews: [favoriteButton], rightViews: [shareButton], centerViews: [dateLabel])
        card.bottomBarEdgeInsetsPreset = .wideRectangle2
        
        card.cornerRadiusPreset = .cornerRadius2
        card.depthPreset = .depth3
        
        return card
    }
    
    func prepareView() {
        let width = CGFloat(0)
        let height = CGFloat(300)
        
        dataSourceItems = [
            DataSourceItem(data: imageCard(), width: width, height: height),
            DataSourceItem(data: imageCard(), width: width, height: height),
            DataSourceItem(data: imageCard(), width: width, height: height),
            DataSourceItem(data: imageCard(), width: width, height: height)
        ]
        
        collectionView.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        
        navigationController?.navigationBar.shadowColor = Stylesheet.color(.clear)
        
        titleLabel.textColor = Stylesheet.color(.white)
        titleLabel.textAlignment = .center
        navigationItem.centerViews = [titleLabel]
    }
    
    func prepareHeader() {
        headerBar = FlexibleHeightBar(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 100.0))
        headerBar.minimumBarHeight = 0.0

        headerBar.backgroundColor = Stylesheet.color(.cyan)
        view.addSubview(headerBar)

        collectionView.contentInset = UIEdgeInsetsMake(100.0, 0.0, 0.0, 0.0)

        headerBar.behaviorDefiner = FacebookBarBehaviorDefiner()
        
        //        navigationController?.navigationBar.isTranslucent = true
        
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
        collectionView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            // Add your logic here
            // Do not forget to call dg_stopLoading() at the end
            self?.collectionView.dg_stopLoading()
            }, loadingView: loadingView)
        collectionView.dg_setPullToRefreshFillColor(Stylesheet.color(.cyan))
        collectionView.dg_setPullToRefreshBackgroundColor(collectionView.backgroundColor!)
    }
}
