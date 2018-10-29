//
//  OccupationsViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 10/18/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class ListViewController: UITableViewController {
    
    // MARK: - Parameters & Constants
    
    fileprivate static let CellIdentifier = "ListCell"
    
    // MARK: - Properties
    
    fileprivate let verticalSpacing = 31.0
    fileprivate let horizontalSpacing = 15.0
    fileprivate let viewModel: PersonalDataViewModelType
    
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    
    init(viewModel: PersonalDataViewModelType) {
        self.viewModel = viewModel
        super.init(style: .plain)
        
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.subItems.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListViewController.CellIdentifier, for: indexPath)
        
        cell.textLabel?.text = viewModel.subItems[indexPath.row]
        cell.textLabel?.font = R.font.encodeSansRegular(size: 15)
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.subItemSelected(at: indexPath)
        closeAction(sender: nil)
    }
    
    @objc
    func closeAction(sender: UIButton?) {
        if searchController.isActive {
            searchController.dismiss(animated: false)
        }
        dismiss(animated: true)
    }
}

// MARK: - UISearchResultsUpdating Delegate
extension ListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

// MARK: - UISearchControllerDelegate
extension ListViewController: UISearchControllerDelegate {
    func presentSearchController(_ searchController: UISearchController) {
        viewModel.isFiltering = isFiltering()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        viewModel.isFiltering = isFiltering()
    }
}

// MARK: - Search methods
fileprivate extension ListViewController {
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String) {
        viewModel.isFiltering = isFiltering()
        viewModel.filterSubItems(searchText: searchText)
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}


fileprivate extension ListViewController {
    func prepare() {
        prepareTableView()
        prepareNavigationItem()
        prepareSearchController()
    }
    
    func prepareTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ListViewController.CellIdentifier)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = Stylesheet.color(.lightGray)
        tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        tableView.tableFooterView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
    }
    
    func prepareSearchController() {
        definesPresentationContext = false
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        
        if let backgroundImage = R.image.nav_background() {
            searchController.searchBar.backgroundColor = UIColor(patternImage: backgroundImage)
            searchController.searchBar.setBackgroundImage(backgroundImage, for: .any, barMetrics: .defaultPrompt)
        }
        searchController.searchBar.tintColor = Stylesheet.color(.blue)
        searchController.searchBar.barTintColor = Stylesheet.color(.blue)
    }
    
    func prepareNavigationItem() {
        
        let backButton = Material.IconButton()
        backButton.image = Icon.close?.tint(with: Stylesheet.color(.blue))
        backButton.addTarget(self, action: #selector(closeAction(sender:)), for: .touchUpInside)
        navigationItem.leftViews = [backButton]
        
        navigationItem.titleLabel.text = viewModel.subListTitle()
        navigationItem.titleLabel.textColor = Stylesheet.color(.blue)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        
        navigationController?.navigationBar.setBackgroundImage(R.image.nav_background(), for: .default)
    }
}


