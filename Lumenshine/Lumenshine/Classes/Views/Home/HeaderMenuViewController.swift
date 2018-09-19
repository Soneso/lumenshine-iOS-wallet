//
//  HeaderMenuViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 3/16/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

protocol HeaderMenuDelegate: NSObjectProtocol {
    func menuSelected(at index: Int)
}

class HeaderMenuViewController: UIViewController {
    
    fileprivate static let CellIdentifier = "TableViewCell"
    
    // MARK: - Properties
    
    fileprivate let items: [(String, String)]
    fileprivate let tableView: UITableView
    
    weak var delegate: HeaderMenuDelegate?
    
    init(items: [(String, String)]) {
        self.items = items
        tableView = UITableView(frame: .zero, style: .plain)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.05, animations: {
            self.view.backgroundColor = Stylesheet.color(.darkGray).withAlphaComponent(0.5)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animate(withDuration: 0.05, animations: {
            self.view.backgroundColor = Stylesheet.color(.clear)
        })
    }
}

extension HeaderMenuViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HeaderMenuViewController.CellIdentifier, for: indexPath)
        
        cell.textLabel?.text = items[indexPath.row].0
        let image = UIImage(named: items[indexPath.row].1)
        cell.imageView?.image =  image?.tint(with: Stylesheet.color(.black))
        cell.selectionStyle = .none
        
        return cell
    }
    
}

extension HeaderMenuViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.menuSelected(at: indexPath.row)
        dismiss(animated: true, completion:nil)
    }
}

fileprivate extension HeaderMenuViewController {
    func prepareView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.centerY)
            make.bottom.left.right.equalToSuperview()
        }
        
        tableView.cornerRadiusPreset = .cornerRadius3
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = Stylesheet.color(.white)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: HeaderMenuViewController.CellIdentifier)
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none

//        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTap(_:))))
    }
    
    @IBAction
    func viewTap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
}
