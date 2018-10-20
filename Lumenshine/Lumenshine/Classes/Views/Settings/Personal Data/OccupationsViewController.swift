//
//  OccupationsViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 10/18/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class OccupationsViewController: UITableViewController {
    
    // MARK: - Parameters & Constants
    
    fileprivate static let CellIdentifier = "OccupationCell"
    
    // MARK: - Properties
    
    fileprivate let verticalSpacing = 31.0
    fileprivate let horizontalSpacing = 15.0
    fileprivate let viewModel: PersonalDataViewModelType
    
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    
    init(viewModel: PersonalDataViewModelType) {
        self.viewModel = viewModel
        super.init(style: .plain)
        
        viewModel.setupOccupations()
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
        return viewModel.occupationList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OccupationsViewController.CellIdentifier, for: indexPath)
        
        cell.textLabel?.text = viewModel.occupationList[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.occupationSelected(at: indexPath)
    }
    
    @objc
    func closeAction(sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc
    func doneAction(sender: UIButton) {
        
        viewModel.saveSelectedOccupation()
        dismiss(animated: true)
    }
}

// MARK: - UISearchResultsUpdating Delegate
extension OccupationsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

// MARK: - UISearchControllerDelegate
extension OccupationsViewController: UISearchControllerDelegate {
    func presentSearchController(_ searchController: UISearchController) {
        viewModel.isFiltering = isFiltering()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        viewModel.isFiltering = isFiltering()
    }
}

// MARK: - Search methods
fileprivate extension OccupationsViewController {
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


fileprivate extension OccupationsViewController {
    func prepare() {
        prepareTableView()
        prepareNavigationItem()
        prepareSearchController()
    }
    
    func prepareTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: OccupationsViewController.CellIdentifier)
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
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
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
        
        let doneButton = RaisedButton()
        doneButton.backgroundColor = Stylesheet.color(.whiteWith(alpha: 0.2))
        doneButton.title = R.string.localizable.done().uppercased()
        doneButton.titleColor = Stylesheet.color(.blue)
        doneButton.titleLabel?.font = R.font.encodeSansBold(size: 14)
        doneButton.addTarget(self, action: #selector(doneAction(sender:)), for: .touchUpInside)
        navigationItem.rightViews = [doneButton]
        
        navigationItem.titleLabel.text = R.string.localizable.occupation()
        navigationItem.titleLabel.textColor = Stylesheet.color(.blue)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        
        navigationController?.navigationBar.setBackgroundImage(R.image.nav_background(), for: .default)
    }
}


