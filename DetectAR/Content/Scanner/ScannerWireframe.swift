//
//  ScannerWireframe.swift
//  DetectAR
//
//  Created by Vladyslav Vdovychenko on 31.10.2020.
//

import Foundation
import UIKit

class ScannerWireframe: BaseWireframe {
    
    override func storyboardName() -> String {
        return "Content"
    }
    
    override func identifier() -> String {
        return "ScannerViewController"
    }
    
    func pushFrom(_ parent: UINavigationController?) {
        if let controller: ScannerViewController = (self.presentedViewController as? ScannerViewController) ?? initializeController(),
           let parent = parent {
            let interactor: ScannerInputProtocol = ScannerInteractor()
            controller.interactor = interactor
            interactor.view = controller
            self.presentedViewController = controller
            parent.pushViewController(controller, animated: true)
        }
    }
    
}
