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
    func headerMenuDidDismiss(_ headerMenu: HeaderMenuViewController)
}

class HeaderMenuViewController: UIViewController {
    
    fileprivate static let CellIdentifier = "TableViewCell"
    
    // MARK: - Properties
    
    fileprivate let items: [(String, String?)]
    fileprivate let tableView: UITableView
    fileprivate let tapView = UIView()
    
    weak var delegate: HeaderMenuDelegate?
    
    init(items: [(String, String?)]) {
        self.items = items
        tableView = UITableView(frame: .zero, style: .plain)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        transitioningDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }
}

extension HeaderMenuViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ComposePresentTransitionController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ComposeDismissTransitionController()
    }
}

extension HeaderMenuViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HeaderMenuViewController.CellIdentifier, for: indexPath)
        
        cell.textLabel?.text = items[indexPath.row].0
        if let imageName = items[indexPath.row].1 {
            let image = UIImage(named: imageName)
            cell.imageView?.image =  image?.tint(with: Stylesheet.color(.black))
        }
        cell.selectionStyle = .none
        
        return cell
    }
    
}

extension HeaderMenuViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion:nil)
        self.delegate?.menuSelected(at: indexPath.row)
        self.delegate?.headerMenuDidDismiss(self)
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

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTap(_:)))
        tapView.addGestureRecognizer(tapGesture)
        
        view.addSubview(tapView)
        tapView.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.centerY)
            make.top.left.right.equalToSuperview()
        }
    }
    
    @objc
    func viewTap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
        self.delegate?.headerMenuDidDismiss(self)
    }
}
