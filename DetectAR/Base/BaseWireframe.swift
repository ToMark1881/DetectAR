//
//  BaseWireframe.swift
//  SuperDealNew
//
//  Created by Pokupon & SuperDeal Mobile Team on 12/19/16.
//  Copyright © 2016 SuperDeal Limited Liability Company. All rights reserved.
//

import Foundation
import UIKit

class BaseWireframe: NSObject {

    weak var presentedViewController: UIViewController?

    override init() {
        super.init()
        
        Logger.shared.log("🆕 \(self)", type: .lifecycle)
    }
    
    deinit {
        Logger.shared.log("🗑 \(self)", type: .lifecycle)
    }

    func initializeController<T:UIViewController>() -> T? {
        return self.storyboard.instantiateViewController(withIdentifier: identifier()) as? T
    }

    var storyboard: UIStoryboard {
        get {
            return UIStoryboard(name: storyboardName(), bundle: nil)
        }
    }

    func storyboardName() -> String {
        assert(false, "Must ovveride")

        return ""
    }

    func identifier() -> String {
        assert(false, "Must ovveride")

        return ""
    }

    var isShowed: Bool {
        get {
            return self.presentedViewController != nil
        }
    }

    func dismissViewController(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.presentedViewController?.dismiss(animated: animated, completion: completion)
        //self.presentedViewController = nil
    }
    
    func popViewController(animated: Bool = true) {
        if let nav = self.presentedViewController?.navigationController {
            nav.popViewController(animated: animated)
        } else {
            dismissViewController(animated: animated)
        }
    }
}
