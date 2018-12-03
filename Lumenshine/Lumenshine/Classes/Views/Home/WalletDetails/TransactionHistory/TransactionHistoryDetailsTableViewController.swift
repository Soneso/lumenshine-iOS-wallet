//
//  TransactionHistoryDetailsTableViewController.swift
//  Lumenshine
//
//  Created by Elekes Istvan on 31/10/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material
import stellarsdk

class TransactionHistoryDetailsTableViewController: UITableViewController {
    
    // MARK: - Parameters & Constants
    
    fileprivate static let CellIdentifier = "TransactionHistoryCell"
    
    // MARK: - Properties
    
    fileprivate var jsonDict = [String:Any]()
    
    init(details: Data) {
        if let jsonDict = try! JSONSerialization.jsonObject(with: details, options: []) as? [String:Any] {
            self.jsonDict = jsonDict
            self.jsonDict.removeValue(forKey: "_links")
        }
        super.init(nibName: nil, bundle: nil)
        print("Details: " + String(data: details, encoding: .utf8)!)
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
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jsonDict.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionHistoryDetailsTableViewController.CellIdentifier, for: indexPath) as! TableViewCell
        
        let keys = jsonDict.keys.sorted()
        let key = keys[indexPath.row]
        let anyValue = jsonDict[key]
        var value = ""
        
        switch anyValue {
        case let anInt as Int:
            value = String(anInt)
        case let aDouble as Double:
            value = String(aDouble)
        case let aString as String:
            value = aString
        case let anArray as Array<Any>:
            value = anArray.description
        case let aDict as [String: Any]:
            value = aDict.description
        default: break
        }
        
        cell.textLabel?.font = R.font.encodeSansRegular(size: 14)
        cell.textLabel?.text = key.replacingOccurrences(of: "_", with: " ")
        cell.detailTextLabel?.font = R.font.encodeSansSemiBold(size: 14)
        cell.detailTextLabel?.text = value
        cell.detailTextLabel?.numberOfLines = 0
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc
    func didTapHelp(_ sender: Any) {
    }
}

fileprivate extension TransactionHistoryDetailsTableViewController {
    func prepare() {
        prepareTableView()
        prepareNavigationItem()
    }
    
    func prepareTableView() {
        
        tableView.register(TableViewCell.self, forCellReuseIdentifier: TransactionHistoryDetailsTableViewController.CellIdentifier)
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func prepareNavigationItem() {
        navigationItem.titleLabel.text = R.string.localizable.operation_details()
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
        
        /*let helpButton = Material.IconButton()
        helpButton.image = R.image.question()?.crop(toWidth: 25, toHeight: 25)?.tint(with: Stylesheet.color(.white))
        helpButton.addTarget(self, action: #selector(didTapHelp(_:)), for: .touchUpInside)
        navigationItem.rightViews = [helpButton]*/
    }
}
