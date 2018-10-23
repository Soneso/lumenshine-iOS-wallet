//
//  JailbreakChecker.swift
//  Lumenshine
//
//  Created by Soneso on 22/10/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit

class JailbreakChecker {
    var isJailbrokenDevice: Bool {
        return containsSuspectedFiles || canWriteOutsideSandbox
    }
    
    private var containsSuspectedFiles: Bool {
        if FileManager.default.fileExists(atPath: "/Applications/Cydia.app")
            || FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib")
            || FileManager.default.fileExists(atPath: "/bin/bash")
            || FileManager.default.fileExists(atPath: "/usr/sbin/sshd")
            || FileManager.default.fileExists(atPath: "/etc/apt")
            || FileManager.default.fileExists(atPath: "/private/var/lib/apt/")
            || UIApplication.shared.canOpenURL(URL(string:"cydia://package/com.example.package")!)
        {
            return true
        }

        return false
    }
    
    private var canWriteOutsideSandbox: Bool {
        let stringToWrite = "JailbreakTest"
        do {
            try stringToWrite.write(toFile: "/private/JailbreakTest.txt", atomically:true, encoding:String.Encoding.utf8)
            return true
        }catch {
            return false
        }
    }
    
    func checkDeviceForJailbreak() {
        if TARGET_IPHONE_SIMULATOR != 1 && isJailbrokenDevice {
            showAlert()
        }
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: "Warning", message: "This app has detected that it's running on a jailbroken device. Cannot proceed further!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.ok(),
                                      style: .default,
                                      handler: { action in
                                            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                                exit(EXIT_SUCCESS)
                                            })
                                       }))
        
        let mainWindow = UIApplication.shared.keyWindow
        mainWindow?.rootViewController?.present(alert, animated: true)
    }
}
