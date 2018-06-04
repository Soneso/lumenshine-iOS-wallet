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
    
    fileprivate let viewModel: MenuViewModelType
    fileprivate let menuButton = HamburgerButton(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
    
    init(viewModel: MenuViewModelType) {
        self.viewModel = viewModel
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepare()
    
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground(notification:)), name: .UIApplicationWillEnterForeground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground(notification:)), name: .UIApplicationDidEnterBackground, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @objc
    func appWillEnterForeground(notification: Notification) {
        viewModel.showRelogin()
    }
    
    @objc
    func appDidEnterBackground(notification: Notification) {
        viewModel.countBackgroundTime()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.items.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuViewController.CellIdentifier, for: indexPath)

        cell.textLabel?.text = viewModel.items[indexPath.section][indexPath.row]
        cell.imageView?.image = viewModel.icons[indexPath.section][indexPath.row]

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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.menuItemSelected(at: indexPath)
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
        prepareMenuButton()
    }
    
    func prepareMenuButton() {
        menuButton.transform = menuButton.transform.scaledBy(x: 1.35, y: 1.35)
        menuButton.addTarget(self, action: #selector(onMenuButtonTap(_:event:)), for: .touchUpInside)
        evo_drawerController?.gestureCompletionBlock = { (drawer, gesture) in
            let action = drawer.openSide == DrawerSide.none
            if action != self.menuButton.showsMenu {
                self.menuButton.showsMenu = action
            }
        }
    }
}

extension MenuViewController: MenuViewProtocol {
    func present(_ viewController: UIViewController, updateMenu: Bool = true) {
        linkMenuButton(to: viewController)
        if updateMenu {
            menuButton.showsMenu = evo_drawerController?.openSide != DrawerSide.none
        }
    }
}

extension MenuViewController {
    @objc
    func onMenuButtonTap(_ sender: UIButton, event: UIEvent) {
        evo_drawerController?.toggleLeftDrawerSide(animated: true, completion: nil)
        menuButton.showsMenu = evo_drawerController?.openSide != DrawerSide.none
    }
}

fileprivate extension MenuViewController {
    
    func linkMenuButton(to controller: UIViewController) {
        controller.navigationItem.leftViews = [menuButton]
    }
}
