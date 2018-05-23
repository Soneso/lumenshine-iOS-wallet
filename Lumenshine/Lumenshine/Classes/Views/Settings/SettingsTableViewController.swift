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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewController.CellIdentifier, for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = R.string.localizable.logout()

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        evo_drawerController?.navigationController?.setNavigationBarHidden(false, animated: true)
        evo_drawerController?.navigationController?.popViewController(animated: true)
    }
}

fileprivate extension SettingsTableViewController {
    func prepare() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: SettingsTableViewController.CellIdentifier)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        
        tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 130)))
    }
}
