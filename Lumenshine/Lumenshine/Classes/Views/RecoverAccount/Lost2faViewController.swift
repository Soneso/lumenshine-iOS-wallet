//
//  Lost2faViewController.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 29/05/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class Lost2faViewController: UIViewController {
    @IBOutlet weak var emailTextField: TextField!
    @IBOutlet weak var resetButton: RaisedButton!
    
    var viewModel: Lost2faViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareEmailTextField()
        prepareResetButton()
    }

    func prepareEmailTextField() {
        emailTextField.placeholder = R.string.localizable.email()
        emailTextField.dividerActiveColor = Stylesheet.color(.cyan)
        emailTextField.placeholderActiveColor = Stylesheet.color(.cyan)
    }
    
    func prepareResetButton() {
        resetButton.title = R.string.localizable.reset_2fa()
        resetButton.backgroundColor = Stylesheet.color(.cyan)
        resetButton.titleColor = Stylesheet.color(.white)
    }
    
    @IBAction func didTapResetButton(_ sender: Any) {
        showActivity()
        viewModel.reset2fa(email: emailTextField.text) { (result) -> (Void) in
            self.hideActivity(completion: {
                switch result {
                case .success:
                    let alert = AlertFactory.createAlert(title: "2fa reset", message:"2fa successfully reset. Please check your email.")
                    self.present(alert, animated: true)
                case .failure(let error):
                    let alert = AlertFactory.createAlert(error: error)
                    self.present(alert, animated: true)
                }
            })
        }
    }
    
}
