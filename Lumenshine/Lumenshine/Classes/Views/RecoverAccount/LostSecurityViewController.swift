//
//  LostSecurityViewController.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 27/05/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import Material

class LostSecurityViewController: UIViewController {
    @IBOutlet weak var emailTextField: TextField!
    @IBOutlet weak var nextButton: RaisedButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var viewModel: LostSecurityViewModelType!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareTitleLabel()
        prepareEmailTextField()
        prepareResetButton()
    }
    
    func prepareTitleLabel() {
        titleLabel.text = viewModel.title
    }

    func prepareEmailTextField() {
        emailTextField.placeholder = R.string.localizable.email()
        emailTextField.dividerActiveColor = Stylesheet.color(.cyan)
        emailTextField.placeholderActiveColor = Stylesheet.color(.cyan)
        emailTextField.detailColor = Stylesheet.color(.red)
    }
    
    func prepareResetButton() {
        nextButton.title = R.string.localizable.next()
        nextButton.backgroundColor = Stylesheet.color(.cyan)
        nextButton.titleColor = Stylesheet.color(.white)
    }
    
    @IBAction func didTapResetButton(_ sender: Any) {
        emailTextField.detail = nil
        showActivity()
        viewModel.lostSecurity(email: emailTextField.text) { [weak self] result in
            self?.hideActivity(completion: {
                switch result {
                case .success:
                    self?.viewModel.showSuccess()
                case .failure(let error):
                    self?.present(error: error)
                }
            })
        }
    }
    
    func present(error: ServiceError) {
        if let parameter = error.parameterName, parameter == "email" {
            viewModel.showEmailConfirmation()
        } else {
            emailTextField.detail = error.errorDescription
        }
    }
}
