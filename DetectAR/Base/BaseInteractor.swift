//
//  BaseInteractor.swift
//  DetectAR
//
//  Created by Vladyslav Vdovycheko on 30.09.2020.
//

import Foundation
import UIKit

class BaseInteractor {
    
    var servicesContainer: ServicesContainer!
    
    init() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            self.servicesContainer = appDelegate.servicesContainer
        }
    }
    
    func complete(completed: @escaping ()-> Void) { //use this method to avoid gcd crash (ui on non-main thread)
        DispatchQueue.main.async {
            completed()
        }
    }
    
}
