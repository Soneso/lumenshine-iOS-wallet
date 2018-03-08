//
//  MenuViewController.swift
//  jupiter
//
//  Created by Istvan Elekes on 3/1/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material
import DrawerController

class MenuViewController: UITableViewController {
    
    // MARK: - Parameters & Constants
    
    fileprivate static let CellIdentifier = "MenuCell"
    
    // MARK: - Properties
    
    fileprivate var items: [[String?]] = [
        [nil, "name@email.com"],
        ["Home", "Wallets", "Transactions", "Promotions"],
        ["Settings", "Help Center"]
    ]
    
    fileprivate var icons: [[UIImage?]] = [
        [MaterialIcon.account.size48pt, nil],
        [MaterialIcon.home.size24pt, MaterialIcon.wallets.size24pt, MaterialIcon.transactions.size24pt, MaterialIcon.promotions.size24pt],
        [MaterialIcon.settings.size24pt, MaterialIcon.help.size24pt]
    ]
    
    fileprivate let menuButton = HamburgerButton(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuViewController.CellIdentifier, for: indexPath)

        cell.textLabel?.text = items[indexPath.section][indexPath.row]
        cell.imageView?.image = icons[indexPath.section][indexPath.row]

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
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section != 0
    }

}

fileprivate extension MenuViewController {
    func prepare() {
        tableView.register(MenuTableViewCell.self, forCellReuseIdentifier: MenuViewController.CellIdentifier)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        if let colorImg = UIImage(named: "MenuColor") {
            tableView.backgroundView = UIImageView(image: colorImg)
        } else {
            tableView.backgroundColor = Stylesheet.color(.cyan)
        }
        tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
    }
}

extension MenuViewController: MenuViewProtocol {
    func present(_ viewController: UIViewController) {
        linkMenuButton(to: viewController)
    }
}

extension MenuViewController {
    @IBAction
    func onMenuButtonTap(_ sender: UIButton, event: UIEvent) {
        evo_drawerController?.toggleLeftDrawerSide(animated: true, completion: nil)
        menuButton.showsMenu = evo_drawerController?.openSide != DrawerSide.none
    }
}

fileprivate extension MenuViewController {
    
    func linkMenuButton(to controller: UIViewController) {
        menuButton.transform = menuButton.transform.scaledBy(x: 1.35, y: 1.35)
        menuButton.addTarget(self, action: #selector(onMenuButtonTap(_:event:)), for: .touchUpInside)
        controller.navigationItem.leftViews = [menuButton]
        evo_drawerController?.gestureCompletionBlock = { (drawer, gesture) in
            let action = drawer.openSide == DrawerSide.none
            if action != self.menuButton.showsMenu {
                self.menuButton.showsMenu = action
            }
        }
    }
}
