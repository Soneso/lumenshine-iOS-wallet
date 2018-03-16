//
//  ViewController.swift
//  jupiter
//
//  Created by Razvan Chelemen on 25/01/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import stellarsdk
import SnapKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let view = UIView()
        view.backgroundColor = UIColor.blue
        
        self.view.addSubview(view)
        view.snp.makeConstraints { make in
            make.top.equalTo(self.view.snp.centerY)
            make.bottom.left.right.equalToSuperview()
        }
        
        self.view.backgroundColor = Stylesheet.color(.darkGray).withAlphaComponent(0.5)
        
        let sdk = StellarSDK()
        let keyPair = try! KeyPair.generateRandomKeyPair()
        
        sdk.accounts.createTestAccount(accountId: keyPair.accountId) { (response) -> (Void) in
            switch response {
            case .success(let data):
                print("Details: \(data)")
                
            case .failure(let error):
                print("Error: \(error)")
            }
        }
        
        sdk.accounts.getAccountDetails(accountId: "GD4FLXKATOO2Z4DME5BHLJDYF6UHUJS624CGA2FWTEVGUM4UZMXC7GVX") { (response) -> (Void) in
            switch response {
            case .success(let accountDetails):
                print("Details: \(accountDetails)")
                
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

