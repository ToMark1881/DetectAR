//
//  UITextField+Extensions.swift
//  SuperDealNew
//
//  Created by Pokupon & SuperDeal Mobile Team on 2/6/17.
//  Copyright © 2017 SuperDeal Limited Liability Company. All rights reserved.
//

import Foundation
import UIKit

private var __maxLengths = [UITextField: Int]()

@IBDesignable
class FormTextField: UITextField {

    @IBInspectable var inset: CGFloat = 0

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset, dy: inset)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

}

extension UITextField {

    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }


    @IBInspectable var bottomBorderColor: UIColor? {
        get {
            return self.bottomBorderColor
        }
        set {
            self.borderStyle = UITextField.BorderStyle.none;
            let border = CALayer()
            let width = CGFloat(0.5)
            border.borderColor = newValue?.cgColor
            border.frame = CGRect(x: 0, y: self.frame.size.height - width,   width:  self.frame.size.width, height: self.frame.size.height)

            border.borderWidth = width
            self.layer.addSublayer(border)
            self.layer.masksToBounds = true

        }
    }
}

@IBDesignable
class TextFieldWithUserSettings: UITextField {

    @IBInspectable var isPasteEnabled: Bool = true

    @IBInspectable var isSelectEnabled: Bool = true

    @IBInspectable var isSelectAllEnabled: Bool = true

    @IBInspectable var isCopyEnabled: Bool = true

    @IBInspectable var isCutEnabled: Bool = true

    @IBInspectable var isDeleteEnabled: Bool = true

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        switch action {
        case #selector(UIResponderStandardEditActions.paste(_:)) where !isPasteEnabled,
             #selector(UIResponderStandardEditActions.select(_:)) where !isSelectEnabled,
             #selector(UIResponderStandardEditActions.selectAll(_:)) where !isSelectAllEnabled,
             #selector(UIResponderStandardEditActions.copy(_:)) where !isCopyEnabled,
             #selector(UIResponderStandardEditActions.cut(_:)) where !isCutEnabled,
             #selector(UIResponderStandardEditActions.delete(_:)) where !isDeleteEnabled:
            return false
        default:
            //return true : this is not correct
            return super.canPerformAction(action, withSender: sender)
        }
    }
}

extension UITextField {

    func isEmpty() -> Bool {
        return self.text == nil || (self.text != nil && self.text?.count == 0)
    }

    func isContainsSymbolsCount(_ count: Int) -> Bool {
        guard let text = self.text else {
            return false
        }

        return text.count >= count
    }
    
    /// Text field length limitation
    @IBInspectable var maxLength: Int {
        get {
            guard let l = __maxLengths[self] else {
                return Int.max
            }
            return l
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(fixToMaxLength), for: .editingChanged)
        }
    }
    @objc func fixToMaxLength(textField: UITextField) {
        let t = textField.text
        textField.text = t?.safelyLimitedTo(length: maxLength)
    }
    
    @IBInspectable var leftPadding: CGFloat {
        get {
            return 0
        }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: self.frame.size.height))
            self.leftView = paddingView
            self.leftViewMode = .always
        }
    }
    @IBInspectable var rightPadding: CGFloat {
        get {
            return 0
        }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: self.frame.size.height))
            self.rightView = paddingView
            self.rightViewMode = .always
        }
    }
    
}
