//
//  HomeViewController.swift
//  jupiter
//
//  Created by Istvan Elekes on 3/5/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material
import MaterialComponents.MaterialFlexibleHeader
import DGElasticPullToRefresh

class HomeViewController: CardCollectionViewController {
    
    // MARK: - Properties
    
    fileprivate let viewModel: HomeViewModelType
    
    fileprivate let headerViewController = MDCFlexibleHeaderViewController()
    
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
        prepareHeader()
        prepareView()
        prepareRefresh()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: animated)
//    }
//
//    override func viewWillLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        headerViewController.updateTopLayoutGuide()
//    }
    
    override var childViewControllerForStatusBarHidden: UIViewController? {
        return headerViewController
    }
}

extension HomeViewController {
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! CardCollectionViewCell
        
        return cell
    }
    
}

extension HomeViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == headerViewController.headerView.trackingScrollView {
            headerViewController.headerView.trackingScrollDidScroll()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == headerViewController.headerView.trackingScrollView {
            headerViewController.headerView.trackingScrollDidEndDecelerating()
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let headerView = headerViewController.headerView
        if scrollView == headerView.trackingScrollView {
            headerView.trackingScrollDidEndDraggingWillDecelerate(decelerate)
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let headerView = headerViewController.headerView
        if scrollView == headerView.trackingScrollView {
            headerView.trackingScrollWillEndDragging(withVelocity: velocity, targetContentOffset: targetContentOffset)
        }
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
    }
    
    func prepareHeader() {

        addChildViewController(headerViewController)
        headerViewController.view.frame = view.bounds
        view.addSubview(headerViewController.view)
        headerViewController.didMove(toParentViewController: self)

        collectionView.delegate = self
        headerViewController.layoutDelegate = self
        headerViewController.headerView.trackingScrollView = collectionView

        headerViewController.headerView.backgroundColor = Stylesheet.color(.cyan)
        headerViewController.headerView.shiftBehavior = .enabled
        headerViewController.headerView.canOverExtend = false
        headerViewController.headerView.minimumHeight = 0
        headerViewController.headerView.maximumHeight = 100
        headerViewController.headerView.minMaxHeightIncludesSafeArea = false
        headerViewController.headerView.statusBarHintCanOverlapHeader = false
        
//        headerViewController.headerView.changeContentInsets {
//            self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        }
        
        prepareNavigation()
    }
    
    func prepareNavigation() {
        // Use a standard UINavigationBar in the flexible header.
        let navBarFrame = CGRect(origin: .zero, size: CGSize(width: headerViewController.headerView.frame.width, height: 60))
        let navBar = UINavigationBar(frame: navBarFrame)
        navBar.autoresizingMask = .flexibleWidth
        navBar.tintColor = Color.white
        
        headerViewController.headerView.addSubview(navBar)
        

        navBar.setItems([navigationItem], animated: true)
    }
    
    func prepareRefresh() {
        
        // Initialize tableView
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
        collectionView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            // Add your logic here
            // Do not forget to call dg_stopLoading() at the end
            self?.collectionView.dg_stopLoading()
            }, loadingView: loadingView)
        collectionView.dg_setPullToRefreshFillColor(Stylesheet.color(.cyan))
        collectionView.dg_setPullToRefreshBackgroundColor(collectionView.backgroundColor!)
    }
}

extension HomeViewController: MDCFlexibleHeaderViewLayoutDelegate {
    
    // MARK: MDCFlexibleHeaderViewLayoutDelegate
    func flexibleHeaderViewController(_: MDCFlexibleHeaderViewController,
                                      flexibleHeaderViewFrameDidChange flexibleHeaderView: MDCFlexibleHeaderView) {
        // Called whenever the frame changes.
        print("frame: \(flexibleHeaderView.frame)")
        
//        if flexibleHeaderView.frame.height > 90 {
//            let image = UIImage.image(with: Stylesheet.color(.clear), size: CGSize(width: 100, height: 100))
//            navigationController?.navigationBar.setBackgroundImage(image, for: .default)
//            navigationController?.navigationBar.backgroundColor = Stylesheet.color(.clear)
//
//        } else {
//            let image = UIImage.image(with: Stylesheet.color(.blue), size: CGSize(width: 100, height: 100))
//            navigationController?.navigationBar.setBackgroundImage(image, for: .default)
//        }
    }
}
