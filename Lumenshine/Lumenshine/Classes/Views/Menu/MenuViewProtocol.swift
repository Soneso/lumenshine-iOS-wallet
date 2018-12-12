//
//  MenuViewProtocol.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

protocol MenuViewProtocol {
    func present(_ viewController: UIViewController)
}

protocol MenuCellProtocol {
    func setText(_ text: String?)
    func setImage(_ image: UIImage?)
}
