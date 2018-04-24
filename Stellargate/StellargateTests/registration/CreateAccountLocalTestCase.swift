//
//  CreateAccountLocalTestCase.swift
//  StellargateTests
//
//  Created by Istvan Elekes on 4/23/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import XCTest
import Stellargate
import stellarsdk

class CreateAccountLocalTestCase: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testAccountGeneration() {
        
        let service = Services()
        service.auth.generateAccount(email: "test@mail.com", password: "t3stPassword") { response in
            if let account = response {
                XCTAssertNotNil(account.passwordSalt.toBase64())
                XCTAssertEqual(account.passwordSalt.toBase64()?.count, "exA5syEa9wRBEU8ty/IA9HBFqzo/0qtzIAlNLIYS8xY=".count)
                
                XCTAssertNotNil(account.encryptedMasterKey.toBase64())
                XCTAssertEqual(account.encryptedMasterKey.toBase64()?.count, "fTDQxc9Q6DE9jVLEV8SeQwr5NHHsD+INa6UBd1Xqlv8=".count)
                
                XCTAssertNotNil(account.masterKeyIV.toBase64())
                XCTAssertEqual(account.masterKeyIV.toBase64()?.count, "77rrl7raJoFjaeb0X9GCfw==".count)
                
                XCTAssertNotNil(account.encryptedMnemonic.toBase64())
                XCTAssertEqual(account.encryptedMnemonic.toBase64()?.count, "n2oK6yk9bSExT70VD7hQhTNMFd5Zqa91UpE5+vSrgofTb3G4CpvgFgAPIpy11mwc8Yi9NlH3Og+xDyrHRwPEWpMDnF4c0/D4KEKmNw76BmOnHyfUzRz+VFZnasiVOn3/Z77B5BQSCXJ3BUB7/pbR096n3VXz2MUp437lXam/cACvdelNbcFIfJg0JQj9G5LRvs70BZbTQeFf98nqbYPecg==".count)
                
                XCTAssertNotNil(account.mnemonicIV.toBase64())
                XCTAssertEqual(account.mnemonicIV.toBase64()?.count, "A1nyzM5aoukgq/g2jiJj4A==".count)
            } else {
                XCTAssert(false)
            }
        }
        
//        params["kdf_salt"] = account.passwordSalt.toBase64()
//        params["master_key"] = account.encryptedMasterKey.toBase64()
//        params["master_iv"] = account.masterKeyIV.toBase64()
//        params["mnemonic"] = account.encryptedMnemonic.toBase64()
//        params["mnemonic_iv"] = account.mnemonicIV.toBase64()
//        params["public_key_0"] = account.publicKeyIndex0
//        params["public_key_188"] = account.publicKeyIndex188
        
        
        
    }
}
