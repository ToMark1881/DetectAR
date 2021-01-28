//
//  SettingsWireframe.swift
//  DetectAR
//
//  Created by Vladyslav Vdovychenko on 25.01.2021.
//

import Foundation
import UIKit

class SettingsWireframe: BaseWireframe {
    
    override func storyboardName() -> String {
        return "Content"
    }
    
    override func identifier() -> String {
        return "SettingsViewController"
    }
    
    func pushFrom(_ parent: UINavigationController?) {
        if let controller: SettingsViewController = initializeController(),
           let parent = parent {
            let interactor: SettingsInputProtocol = SettingsInteractor()
            controller.interactor = interactor
            interactor.view = controller
            self.presentedViewController = controller
            parent.pushViewController(controller, animated: true)
        }
    }
    
}
