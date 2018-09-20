//
//  UIViewController+Utils.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 27/05/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

typealias saveClosure = (_ value: String?) -> Void
typealias deleteActionClosure = () -> Void
typealias okActionClosure = () -> Void

extension UIViewController {
    
    func showActivity() {
        let alert = UIAlertController(title: nil, message: R.string.localizable.loading(), preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        
        alert.view.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
        }
        
        present(alert, animated: true)
    }
    
    func hideActivity(completion: (() -> Void)? = nil) {
        dismiss(animated: true, completion: completion)
    }
    
}


extension UIViewController {
    private struct Constants {
        static let indicatorSize = CGRect(x: 0, y: 0, width: 40, height: 40)
    }
    
    private struct AssociatedKeys {
        static var activityIndicator = "xxx_activityIndicator"
        static var overlay = "xxx_overlay"
    }
    
    fileprivate var xxx_activityIndicator: UIActivityIndicatorView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.activityIndicator) as? UIActivityIndicatorView
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.activityIndicator,
                    newValue as UIActivityIndicatorView?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    fileprivate var xxx_overlay: UIView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.overlay) as? UIView
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.overlay,
                    newValue as UIView?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    func activityIndicatorStartAnimating() {
        let showSpinnerNotificationName = Notification.Name("OnboardingShowSpinnerNotification")
        NotificationCenter.default.post(name: showSpinnerNotificationName, object: nil)
    }
    
    func activityIndicatorStopAnimating() {
        let hideSpinnerNotificationName = Notification.Name("OnboardingHideSpinnerNotification")
        NotificationCenter.default.post(name: hideSpinnerNotificationName, object: nil)
    }
    
    func displayGenericSomethingWentWrong() {
        displaySimpleAlertView(title: "Oops!", message: "Something went wrong, please try again")
    }
    
    
    func displayErrorAlertView(message: String, cancelTitle: String = "OK", completion: ((UIAlertAction) -> Void)? = nil) {
        
        displaySimpleAlertView(title: "Error", message: message, cancelTitle: cancelTitle, completition: completion)
    }
    
    func displayAccountIsInPendingAlert() {
        displaySimpleAlertView(title: "In progress", message: "Your account is in pending mode. Please verify later!")
    }
    
    func displaySimpleAlertView(title: String, message: String, cancelTitle: String = "OK", completition: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: cancelTitle, style: .cancel, handler: completition)
        
        alertController.addAction(action)
        
        alertController.showOnANewWindow()
    }
    
    func displayAlertWithTextField(title: String, message: String, saveActionTitle: String = "Save", valuePlaceholder: String = "Value", saveBlock: saveClosure? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: saveActionTitle, style: .default, handler: {
            alert -> Void in
            
            let firstTextField = alertController.textFields![0] as UITextField
            
            if let block = saveBlock {
                block(firstTextField.text)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = valuePlaceholder
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func displayDeleteAlertView(message: String, deleteTitle: String = "Delete", completion:@escaping deleteActionClosure) {
        let alertController = UIAlertController(title: deleteTitle, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let delete = UIAlertAction(title: deleteTitle, style: .destructive) { (_) in
            completion()
        }
        
        alertController.addAction(action)
        alertController.addAction(delete)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showPermitPendingNotification(completion:@escaping deleteActionClosure) {
        let alertController = UIAlertController(title: "Oops!", message: "Permit pending verification!", preferredStyle: .alert)
        let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let delete = UIAlertAction(title: "Go to Permit Settings", style: .default) { (_) in
            completion()
        }
        
        alertController.addAction(action)
        alertController.addAction(delete)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    func displayRetryCancelAlertView(message: String, completion:@escaping okActionClosure) {
        let alertController = UIAlertController(title: "Delete", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let delete = UIAlertAction(title: "Retry", style: .default) { (_) in
            completion()
        }
        
        alertController.addAction(action)
        alertController.addAction(delete)
        
        present(alertController, animated: true, completion: nil)
    }
}
