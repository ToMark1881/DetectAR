//
//  AlertController.swift
//  SuperDealNew
//
//  Created by Pokupon & SuperDeal Mobile Team on 12/30/16.
//  Copyright © 2016 SuperDeal Limited Liability Company. All rights reserved.
//

import Foundation
import UIKit


class AlertController {

    static let instance = AlertController()

    @discardableResult
    open class func alert(_ title: String) -> UIAlertController {
        return alert(title, message: "")
    }

    @discardableResult
    open class func alert(_ title: String, message: String) -> UIAlertController {
        return alert(title, message: message, acceptMessage: "OK", acceptBlock: {
            // Do nothing
        })
    }

    @discardableResult
    open class func showSpinner(_ title: String = "", presentingView: UIViewController? = instance.topMostController()) -> UIAlertController {
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alertController.view.constraints[safe: 2]?.isActive = false
        alertController.view.constraints[safe: 3]?.isActive = false
        alertController.view.constraints[safe: 4]?.isActive = false
        
        let height: NSLayoutConstraint = NSLayoutConstraint(item: alertController.view as Any,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute, multiplier: 1, constant: 120)

        let width: NSLayoutConstraint = NSLayoutConstraint(item: alertController.view as Any,
                attribute: .width,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute, multiplier: 1, constant: 120)
        alertController.view.addConstraints([height, width])

        let spinnerIndicator = UIActivityIndicatorView(style: .whiteLarge)

        spinnerIndicator.center = CGPoint(x: 60, y: 60)
        if #available(iOS 13.0, *) {
            spinnerIndicator.color = UIColor.label
        } else {
            spinnerIndicator.color = UIColor.black
        }
        spinnerIndicator.startAnimating()
        
        alertController.view.layer.cornerRadius = 8.0
        alertController.view.clipsToBounds = true
        alertController.view.frame = CGRect(x: 0, y: 0, width: 120, height: 120)

        alertController.view.addSubview(spinnerIndicator)

        presentingView?.present(alertController, animated: true, completion: {
            alertController.view.layoutSubviews()
        })
        
        return alertController
    }
    
    @discardableResult
    func spinner(_ title: String = "") -> UIAlertController {
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alertController.view.constraints[safe: 2]?.isActive = false
        alertController.view.constraints[safe: 3]?.isActive = false
        alertController.view.constraints[safe: 4]?.isActive = false
        
        let height: NSLayoutConstraint = NSLayoutConstraint(item: alertController.view as Any,
                                                            attribute: .height,
                                                            relatedBy: .equal,
                                                            toItem: nil,
                                                            attribute: .notAnAttribute, multiplier: 1, constant: 120)
        
        let width: NSLayoutConstraint = NSLayoutConstraint(item: alertController.view as Any,
                                                           attribute: .width,
                                                           relatedBy: .equal,
                                                           toItem: nil,
                                                           attribute: .notAnAttribute, multiplier: 1, constant: 120)
        alertController.view.addConstraints([height, width])
        
        let spinnerIndicator = UIActivityIndicatorView(style: .whiteLarge)
        
        spinnerIndicator.center = CGPoint(x: 60, y: 60)
        if #available(iOS 13.0, *) {
            spinnerIndicator.color = UIColor.label
        } else {
            spinnerIndicator.color = UIColor.black
        }
        spinnerIndicator.startAnimating()
        
        alertController.view.layer.cornerRadius = 8.0
        alertController.view.clipsToBounds = true
        alertController.view.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
        
        alertController.view.addSubview(spinnerIndicator)

        return alertController
    }

    @discardableResult
    open class func alert(_ title: String, message: String, acceptMessage: String, acceptBlock: @escaping () -> ()) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let acceptButton = UIAlertAction(title: acceptMessage, style: .default, handler: { (action: UIAlertAction) in
            acceptBlock()
        })
        alert.addAction(acceptButton)
        DispatchQueue.main.async {
            instance.topMostController()?.present(alert, animated: true, completion: nil)
        }
        return alert
    }

    open class func alert(_ title: String, message: String, buttons: [String], tapBlock: ((UIAlertAction, Int) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert, buttons: buttons, tapBlock: tapBlock)
        instance.topMostController()?.present(alert, animated: true, completion: nil)
    }
    
    @discardableResult
    open class func alertWithTextField(_ title: String, message: String, acceptMessage: String, declineMessage: String, textFieldPlaceholder: String, acceptBlock: @escaping (_ textField: UITextField) -> (), declineBlock: (() -> ())? = nil, textFieldMaxLength: Int? = nil, keyboardType: UIKeyboardType = UIKeyboardType.default) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let acceptButton = UIAlertAction(title: acceptMessage, style: .default, handler: { (action: UIAlertAction) in
            if let textField = alert.textFields?.first {
                acceptBlock(textField)
            }
        })
        
        let cancelButton = UIAlertAction(title: declineMessage, style: .default) { (action: UIAlertAction) in
            declineBlock?()
        }
        
        alert.addTextField()
        alert.textFields?.first?.keyboardType = keyboardType
        alert.textFields?.first?.placeholder = textFieldPlaceholder
        
        if let maxLength = textFieldMaxLength {
            alert.textFields?.first?.maxLength = maxLength
        }
        
        alert.addAction(cancelButton)
        alert.addAction(acceptButton)
        
        instance.topMostController()?.present(alert, animated: true, completion: nil)
        
        return alert
    }
    
    open class func alert(_ error: NSError?) {
        Logger.shared.log(error)
        AlertController.alert("Error".localized, message: error?.localizedDescription ?? "Error".localized, acceptMessage: "OK", acceptBlock: {})
    }

    @discardableResult
    open class func actionSheet(_ title: String?, message: String?, sourceView: UIView, actions: [UIAlertAction]) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.actionSheet)
        for action in actions {
            alert.addAction(action)
        }
        
        alert.popoverPresentationController?.sourceView = sourceView
        alert.popoverPresentationController?.sourceRect = sourceView.bounds
        
        instance.topMostController()?.present(alert, animated: true, completion: nil)
        
        return alert
    }

    @discardableResult
    open class func actionSheet(_ title: String, message: String, sourceView: UIView, buttons: [String], tapBlock: ((UIAlertAction, Int) -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet, buttons: buttons, tapBlock: tapBlock)
        alert.popoverPresentationController?.sourceView = sourceView
        alert.popoverPresentationController?.sourceRect = sourceView.bounds
        instance.topMostController()?.present(alert, animated: true, completion: nil)
        
        return alert
    }

    fileprivate func topMostController() -> UIViewController? {
        var presentedVC = UIApplication.shared.keyWindow?.rootViewController
        while let pVC = presentedVC?.presentedViewController {
            presentedVC = pVC
        }

        if presentedVC == nil {
            Logger.shared.log("AlertController Error: You don't have any views set. You may be calling in viewdidload. Try viewdidappear.")
        }

        return presentedVC
    }
}


private extension UIAlertController{
    convenience init(title: String?, message: String?, preferredStyle: UIAlertController.Style, buttons: [String], tapBlock: ((UIAlertAction, Int) -> Void)?) {
        self.init(title: title, message: message, preferredStyle: preferredStyle)
        var buttonIndex = 0
        for buttonTitle in buttons{
            let action = UIAlertAction(title: buttonTitle, preferredStyle: .default, buttonIndex: buttonIndex, tapBlock: tapBlock)
            buttonIndex += 1
            self.addAction(action)
        }
    }
}

private extension UIAlertAction {

    convenience init(title: String?, preferredStyle: UIAlertAction.Style, buttonIndex: Int, tapBlock: ((UIAlertAction, Int) -> Void)?) {
        self.init(title: title, style: preferredStyle) {
            (action: UIAlertAction) in
            if let block = tapBlock {
                block(action, buttonIndex)
            }
        }
    }
}
