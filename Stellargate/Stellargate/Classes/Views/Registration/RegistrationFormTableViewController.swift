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
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.0 : 10
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { return nil }
        let separator = UIView(frame: CGRect(x: 15, y: 5, width:tableView.frame.width-30, height: 1))
        separator.backgroundColor = UIColor.white
        let header = UIView()
        header.addSubview(separator)
        return header
    }
    
}

fileprivate extension RegistrationFormTableViewController {
    func prepare() {
        tableView.register(RegistrationTableViewCell.self, forCellReuseIdentifier: RegistrationFormTableViewController.CellIdentifier)
        tableView.rowHeight = 70.0
        tableView.estimatedRowHeight = 70.0
        tableView.separatorStyle = .none
        if let colorImg = UIImage(named: "MenuColor") {
            tableView.backgroundView = UIImageView(image: colorImg)
        } else {
            tableView.backgroundColor = Stylesheet.color(.cyan)
        }
        tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
    }
}
