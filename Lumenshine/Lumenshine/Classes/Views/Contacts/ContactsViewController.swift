//
//  ContactsViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 10/2/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class ContactsViewController: UITableViewController {
    
    // MARK: - Parameters & Constants
    
    fileprivate static let CellIdentifier = "ContactCell"
    
    // MARK: - Properties
    
    fileprivate let verticalSpacing = 31.0
    fileprivate let horizontalSpacing = 15.0
    fileprivate let viewModel: ContactsViewModelType
    
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    
    init(viewModel: ContactsViewModelType) {
        self.viewModel = viewModel
        super.init(style: .grouped)
        
        viewModel.reloadClosure = {
            DispatchQueue.main.async {
                self.tableView.reloadData()
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
        let identifier = ContactsViewController.CellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        if let contactCell = cell as? ContactCellProtocol {
            contactCell.setName(viewModel.name(at: indexPath))
            contactCell.setAddress(viewModel.address(at: indexPath))
            contactCell.setPublicKey(viewModel.publicKey(at: indexPath))
            contactCell.setDelegate(self)
        }
        
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 60
//    }
    
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

extension ContactsViewController: ContactCellDelegate {
    func contactCellDidTapEdit(cell: ContactTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            viewModel.editItemSelected(at: indexPath)
        }
    }
}

// MARK: - UISearchResultsUpdating Delegate
extension ContactsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

// MARK: - UISearchControllerDelegate
extension ContactsViewController: UISearchControllerDelegate {
    func presentSearchController(_ searchController: UISearchController) {
        viewModel.isFiltering = isFiltering()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        viewModel.isFiltering = isFiltering()
    }
}

// MARK: - Search methods
fileprivate extension ContactsViewController {
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String) {
        viewModel.isFiltering = isFiltering()
        viewModel.filterItems(searchText: searchText)
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}

extension ContactsViewController {
    @objc
    func addAction(sender: UIButton) {
        viewModel.showAddContact()
    }
}


fileprivate extension ContactsViewController {
    func prepare() {
        prepareTableView()
        prepareCopyright()
        prepareNavigationItem()
        prepareSearchController()
    }
    
    func prepareTableView() {
        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: ContactsViewController.CellIdentifier)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = Stylesheet.color(.lightGray)
        tableView.separatorInset = UIEdgeInsetsMake(0, 50, 0, 50)
        if #available(iOS 11.0, *) {
            tableView.separatorInsetReference = .fromAutomaticInsets
        }
        tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        tableView.tableFooterView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
    }
    
    func prepareSearchController() {
        definesPresentationContext = false
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = false
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
//        navigationItem.hidesSearchBarWhenScrolling = false
        
        if let backgroundImage = R.image.nav_background() {
            searchController.searchBar.backgroundColor = UIColor(patternImage: backgroundImage)
            searchController.searchBar.setBackgroundImage(backgroundImage, for: .any, barMetrics: .defaultPrompt)
        }
        searchController.searchBar.tintColor = Stylesheet.color(.blue)
        searchController.searchBar.barTintColor = Stylesheet.color(.blue)
    }
    
    func prepareNavigationItem() {
        
        let addButton = Button()
        addButton.image = Icon.add?.tint(with: Stylesheet.color(.blue))
        addButton.addTarget(self, action: #selector(addAction(sender:)), for: .touchUpInside)
        
        navigationItem.rightViews = [addButton]
        
        navigationItem.titleLabel.text = R.string.localizable.contacts()
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

