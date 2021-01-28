//
//  UITableView+Extensions.swift
//  SuperDealNew
//
//  Created by Pokupon & SuperDeal Mobile Team on 1/10/17.
//  Copyright © 2017 SuperDeal Limited Liability Company. All rights reserved.
//

import Foundation
import UIKit


extension UITableView {

    func reloadData(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }) { _ in
            completion?()
        }
    }
}
