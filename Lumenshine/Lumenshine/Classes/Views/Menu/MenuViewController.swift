//
//  MenuViewController.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material
import KWDrawerController

class MenuViewController: UITableViewController {
    
    // MARK: - Parameters & Constants
    
    fileprivate static let MenuCellIdentifier = "MenuCell"
    fileprivate static let AvatarCellIdentifier = "AvatarCell"
    
    // MARK: - Properties
    
    fileprivate let viewModel: MenuViewModelType
    fileprivate let menuButton = MenuButton(frame: .zero)//HamburgerButton(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
    
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
        return viewModel.itemDistribution.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemDistribution[section]
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = viewModel.isAvatar(at: indexPath) ? MenuViewController.AvatarCellIdentifier : MenuViewController.MenuCellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

        if let menuCell = cell as? MenuCellProtocol {
            menuCell.setText(viewModel.name(at: indexPath))
            menuCell.setImage(UIImage(named: viewModel.iconName(at: indexPath))?.tint(with: Stylesheet.color(.white)))
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.0 : 10
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { return nil }
        let separator = GradientView(frame: CGRect(x: 0, y: 4, width:tableView.frame.width, height: 1))
        separator.gradientLayer.colors = [Stylesheet.color(.white).cgColor, Stylesheet.color(.blue).cgColor]
        separator.gradientLayer.gradient = GradientPoint.leftRight.draw()
        
        let header = UIView()
        header.addSubview(separator)
        return header
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.menuItemSelected(at: indexPath)
    }

}

fileprivate extension MenuViewController {
    func prepare() {
        tableView.register(MenuTableViewCell.self, forCellReuseIdentifier: MenuViewController.MenuCellIdentifier)
        tableView.register(AvatarTableViewCell.self, forCellReuseIdentifier: MenuViewController.AvatarCellIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorStyle = .none
        tableView.backgroundColor = Stylesheet.color(.lightCyan)
        tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        prepareMenuButton()
    }
    
    func prepareMenuButton() {
        //menuButton.color = Stylesheet.color(.blue)
//        menuButton.transform = menuButton.transform.scaledBy(x: 1.35, y: 1.35)
        menuButton.addTarget(self, action: #selector(onMenuButtonTap(_:event:)), for: .touchUpInside)
        drawerController?.delegate = self
    }
}

extension MenuViewController: DrawerControllerDelegate {
    func drawerWillFinishAnimation(drawerController: DrawerController, side: DrawerSide) {
        drawerController.getViewController(for: .none)?.resignFirstResponder()
    }
    
    func drawerWillOpenSide(drawerController: DrawerController, side: DrawerSide) {
        menuButton.showsMenu = side != .left
    }
    
    func drawerWillCloseSide(drawerController: DrawerController, side: DrawerSide) {
        menuButton.showsMenu = side == .left
    }
}

extension MenuViewController: MenuViewProtocol {
    func present(_ viewController: UIViewController) {
        linkMenuButton(to: viewController)
        menuButton.showsMenu = true
    }
}

extension MenuViewController {
    @objc
    func onMenuButtonTap(_ sender: UIButton, event: UIEvent) {
        drawerController?.view.endEditing(true)
        drawerController?.openSide(.left)
        menuButton.showsMenu = false
    }
}

fileprivate extension MenuViewController {
    func linkMenuButton(to controller: UIViewController) {
        controller.navigationItem.leftViews = [menuButton]
    }
}
