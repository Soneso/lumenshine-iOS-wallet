//
//  ExtrasTableViewController.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 23/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class ExtrasTableViewController: UITableViewController {
    
    // MARK: - Parameters & Constants
    
    fileprivate static let CellIdentifier = "ExtrasCell"
    
    // MARK: - Properties
    
    fileprivate let viewModel: ExtrasViewModelType
    
    init(viewModel: ExtrasViewModelType) {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: ExtrasTableViewController.CellIdentifier, for: indexPath) as! ExtrasTableViewCell
        
        cell.setText(viewModel.name(at: indexPath))
        cell.delegate = self
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

extension ExtrasTableViewController: ExtrasCellDelegate {
    func switchStateChanged(cell: ExtrasTableViewCell, state: Bool) {
        if let indexPath = tableView.indexPath(for: cell) {
            viewModel.switchChanged(value: state, at: indexPath)
        }
    }
}

fileprivate extension ExtrasTableViewController {
    func prepare() {
        navigationItem.titleLabel.text = R.string.localizable.extras()
        navigationItem.titleLabel.textColor = Stylesheet.color(.blue)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        
        navigationController?.navigationBar.setBackgroundImage(R.image.nav_background(), for: .default)
        
        tableView.register(ExtrasTableViewCell.self, forCellReuseIdentifier: ExtrasTableViewController.CellIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
    }
}
