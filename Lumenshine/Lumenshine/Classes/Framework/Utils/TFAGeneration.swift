//
//  TFAGeneration.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 5/29/18.
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
        guard let secretData = tfaSecret.data(using: .ascii),
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
        
        removeToken(email: email)
        do {
            let token = Token(name: email, issuer: "Lumenshine", generator: generator)
            _ = try Keychain.sharedInstance.add(token)
        } catch {
            print("Keychain error: \(error)")
        }
    }
    
    static func generatePassword(email: String) -> String? {
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
    
    static func removeToken(email: String) {
        do {
            let keychain = Keychain.sharedInstance
            let persistentTokens = try keychain.allPersistentTokens()
            for token in persistentTokens {
                if token.token.name == email {
                    try keychain.delete(token)
                }
            }
        } catch {
            print("Keychain error: \(error)")
        }
    }
}
