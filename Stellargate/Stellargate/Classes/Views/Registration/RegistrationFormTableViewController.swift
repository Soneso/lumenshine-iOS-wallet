//
//  RegistrationFormTableViewController.swift
//  Stellargate
//
//  Created by Istvan Elekes on 4/14/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class RegistrationFormTableViewController: UITableViewController {
    
    // MARK: - Parameters & Constants
    
    fileprivate static let CellIdentifier = "RegistrationFormCell"
    
    // MARK: - Properties
    
    fileprivate let viewModel: RegistrationViewModelType

    init(viewModel: RegistrationViewModelType) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: RegistrationFormTableViewController.CellIdentifier, for: indexPath) as! RegistrationTableViewCell
        
        cell.setPlaceholder(viewModel.items[indexPath.section][indexPath.row])
        cell.setText(viewModel.values[indexPath.section][indexPath.row])
        cell.textEditingCallback = { changedText in
            self.viewModel.textChanged(changedText, itemForRowAt: indexPath)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sectionTitles[section]
    }
}

extension RegistrationFormTableViewController {
    

}

fileprivate extension RegistrationFormTableViewController {
    func prepare() {
        tableView.register(RegistrationTableViewCell.self, forCellReuseIdentifier: RegistrationFormTableViewController.CellIdentifier)
        tableView.rowHeight = 70.0
        tableView.estimatedRowHeight = 70.0
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
    }
}
