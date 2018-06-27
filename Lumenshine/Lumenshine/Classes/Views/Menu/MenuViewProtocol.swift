//
//  MenuViewProtocol.swift
//  jupiter
//
//  Created by Istvan Elekes on 3/1/18.
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
