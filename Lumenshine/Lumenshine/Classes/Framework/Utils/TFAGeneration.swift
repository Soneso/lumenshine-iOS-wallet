//
//  TFAGeneration.swift
//  Lumenshine
//
//  Created by Soneso GmbH on 12/12/2018.
//  Munich, Germany
//  web: https://soneso.com
//  email: hi@soneso.com
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import OneTimePassword

struct TFAGeneration {
    static func isTokenExists(email: String) -> Bool? {
        do {
            let persistentTokens = try Keychain.sharedInstance.allPersistentTokens().filter {
                $0.token.name == email
            }
            return persistentTokens.count > 0
        } catch {
            print("Keychain error: \(error)")
            return nil
        }
    }
    
    static func createToken(tfaSecret: String, email: String) {
        
        guard let secret = tfaSecret.base32DecodedString(),
            let secretData = secret.data(using: .ascii),
            !secretData.isEmpty else {
                print("Invalid secret")
                return
        }
        
        guard let generator = Generator(
            factor: .timer(period: 30),
            secret: secretData,
            algorithm: .sha1,
            digits: 6) else {
                print("Invalid generator parameters")
                return
        }
        
        remove2FASecretTokens()
        
        do {
            let token = Token(name: email, issuer: "Lumenshine", generator: generator)
            _ = try Keychain.sharedInstance.add(token)
        } catch {
            print("Keychain error: \(error)")
        }
    }
    
    static func generate2FACode(email: String) -> String? {
        do {
            let persistentTokens = try Keychain.sharedInstance.allPersistentTokens()
            for token in persistentTokens {
                if token.token.name == email {
                    return token.token.currentPassword
                }
            }
            return nil
        } catch {
            print("Generate password error: \(error)")
            return nil
        }
    }
    
    static func remove2FASecretTokens() {
        do {
            let keychain = Keychain.sharedInstance
            let persistentTokens = try keychain.allPersistentTokens()
            for token in persistentTokens {
                try keychain.delete(token)
            }
        } catch {
            print("Keychain error: \(error)")
        }
    }
}
