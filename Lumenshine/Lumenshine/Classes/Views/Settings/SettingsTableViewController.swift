//
//  SettingsTableViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 3/23/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    // MARK: - Parameters & Constants
    
    fileprivate static let CellIdentifier = "SettingsCell"
    
    // MARK: - Properties
    
    fileprivate let viewModel: SettingsViewModelType
    
    init(viewModel: SettingsViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
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

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.items.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items[section].count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewController.CellIdentifier, for: indexPath) as! SettingsTableViewCell
        
        cell.textLabel?.text = viewModel.items[indexPath.section][indexPath.row]
        cell.detailTextLabel?.text = viewModel.detailText(forCell: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelect(cellAt: indexPath)
        let cell = tableView.cellForRow(at: indexPath)
        cell?.detailTextLabel?.text = viewModel.detailText(forCell: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

fileprivate extension SettingsTableViewController {
    func prepare() {
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewController.CellIdentifier)
        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.separatorStyle = .none
        
//        tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 130)))
    }
}
