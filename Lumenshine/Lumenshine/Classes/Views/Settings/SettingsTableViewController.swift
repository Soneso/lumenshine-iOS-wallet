//
//  SettingsTableViewController.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.itemDistribution.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemDistribution[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewController.CellIdentifier, for: indexPath) as! SettingsTableViewCell
        
        cell.delegate = self
        cell.setText(viewModel.name(at: indexPath))
        if let switchValue = viewModel.switchValue(at: indexPath) {
            cell.stateSwitch.isOn = switchValue
            cell.hideSwitch(false)
        } else {
            cell.hideSwitch(true)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.itemSelected(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
extension SettingsTableViewController: SettingsCellDelegate {
    func switchStateChanged(cell: SettingsTableViewCell, state: Bool) {
        if let indexPath = tableView.indexPath(for: cell) {
            viewModel.switchChanged(value: state, at: indexPath)
        }
    }
}

fileprivate extension SettingsTableViewController {
    func prepare() {
        navigationItem.titleLabel.text = R.string.localizable.settings()
        navigationItem.titleLabel.textColor = Stylesheet.color(.blue)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        
        navigationController?.navigationBar.setBackgroundImage(R.image.nav_background(), for: .default)
        
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewController.CellIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
    }
}
