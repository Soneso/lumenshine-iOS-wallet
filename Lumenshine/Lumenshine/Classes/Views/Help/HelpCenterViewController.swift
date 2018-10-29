//
//  HelpCenterViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 9/26/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class HelpCenterViewController: UITableViewController {
    
    // MARK: - Parameters & Constants
    
    fileprivate static let CellIdentifier = "HelpCell"
    
    // MARK: - Properties
    
    fileprivate let verticalSpacing = 31.0
    fileprivate let horizontalSpacing = 15.0
    fileprivate let viewModel: HelpCenterViewModelType
    
    init(viewModel: HelpCenterViewModelType) {
        self.viewModel = viewModel
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepare()
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
        return viewModel.itemDistribution.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemDistribution[section]
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = HelpCenterViewController.CellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        if let helpCell = cell as? HelpCellProtocol {
            helpCell.setText(viewModel.name(at: indexPath))
            helpCell.setDetail(viewModel.detail(at: indexPath))
            helpCell.setImage(UIImage(named: viewModel.iconName(at: indexPath)))
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {return 20}
        if indexPath.section == 1 {return 50}
        return 60
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.headerTitle(at: section) == nil ? 25 : 50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let separator = UIView()
        separator.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 12)
        separator.backgroundColor = .white
        
        let label = UILabel()
        label.text = viewModel.headerTitle(at: section)
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
        viewModel.itemSelected(at: indexPath)
    }
    
}

fileprivate extension HelpCenterViewController {
    func prepare() {
        prepareTableView()
        prepareCopyright()
        prepareNavigationItem()
    }
    
    func prepareTableView() {
        tableView.register(HelpTableViewCell.self, forCellReuseIdentifier: HelpCenterViewController.CellIdentifier)
        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.separatorInset = UIEdgeInsets(top: 0, left: CGFloat(2*horizontalSpacing), bottom: 0, right: CGFloat(2*horizontalSpacing))
//        tableView.separatorColor = Stylesheet.color(.lightGray)
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        tableView.tableFooterView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
    }
    
    func prepareNavigationItem() {
        
        navigationItem.titleLabel.text = R.string.localizable.help_center()
        navigationItem.titleLabel.textColor = Stylesheet.color(.blue)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        
        navigationController?.navigationBar.setBackgroundImage(R.image.nav_background(), for: .default)
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
