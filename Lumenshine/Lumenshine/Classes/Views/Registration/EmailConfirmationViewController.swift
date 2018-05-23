//
//  EmailConfirmationViewController.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 5/22/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import stellarsdk
import Material

class EmailConfirmationViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate let viewModel: EmailConfirmationViewModelType
    
    // MARK: - UI properties
    fileprivate let resendButton = RaisedButton()
    fileprivate let confirmedButton = RaisedButton()
    
    init(viewModel: EmailConfirmationViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareView()
    }
    
    @objc
    func resendAction(sender: UIButton) {
        viewModel.resendMailConfirmation { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    break
                case .failure(let error):
                    let alert = AlertFactory.createAlert(error: error)
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    @objc
    func checkConfirmationAction(sender: UIButton) {
        viewModel.checkMailConfirmation { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tfaResponse):
                    if tfaResponse.mailConfirmed == false {
                        self.showEmailConfirmationAlert()
                    } else if tfaResponse.mnemonicConfirmed == false {
                        self.viewModel.showMnemonicConfirmation()
                    }
                case .failure(let error):
                    let alert = AlertFactory.createAlert(error: error)
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    func showEmailConfirmationAlert() {
        let alertView = UIAlertController(title: nil,
                                          message: R.string.localizable.lbl_email_confirmation(),
                                          preferredStyle: .alert)
        let okAction = UIAlertAction(title: R.string.localizable.ok(),
                                          style: .cancel,
                                          handler:nil)
        alertView.addAction(okAction)
        present(alertView, animated: true)
    }
}

fileprivate extension EmailConfirmationViewController {
    func prepareView() {
        view.backgroundColor = Stylesheet.color(.white)
        prepareResendButton()
        prepareConfirmedButton()
    }
    
    func prepareResendButton() {
        resendButton.title = R.string.localizable.email_resend_confirmation()
        resendButton.backgroundColor = Stylesheet.color(.cyan)
        resendButton.titleColor = Stylesheet.color(.white)
        resendButton.addTarget(self, action: #selector(resendAction(sender:)), for: .touchUpInside)
        
        view.addSubview(resendButton)
        resendButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.centerY).offset(-10)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(45)
        }
    }
    
    func prepareConfirmedButton() {
        confirmedButton.title = R.string.localizable.email_already_confirmed()
        confirmedButton.backgroundColor = Stylesheet.color(.cyan)
        confirmedButton.titleColor = Stylesheet.color(.white)
        confirmedButton.addTarget(self, action: #selector(checkConfirmationAction(sender:)), for: .touchUpInside)
        
        view.addSubview(confirmedButton)
        confirmedButton.snp.makeConstraints { make in
            make.top.equalTo(view.snp.centerY).offset(10)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(45)
        }
    }
}
