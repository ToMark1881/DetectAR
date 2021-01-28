//
//  MainMenuWireframe.swift
//  DetectAR
//
//  Created by Vladyslav Vdovychenko on 25.01.2021.
//

import Foundation
import UIKit

class MainMenuWireframe: BaseWireframe {
 
    override func storyboardName() -> String {
        return "Content"
    }
    
    override func identifier() -> String {
        return "MainMenuViewController"
    }
    
    func embeddedIn(_ parent: UIViewController?) {
        if let controller: MainMenuViewController = initializeController(),
           let parent = parent {
            let navigationController = UINavigationController(rootViewController: controller)
            let interactor: MainMenuInputProtocol = MainMenuInteractor()
            interactor.view = controller
            controller.interactor = interactor
            
            navigationController.willMove(toParent: parent)
            parent.view.addSubview(navigationController.view)
            parent.addChild(navigationController)
            navigationController.didMove(toParent: parent)
        }
    }
    
}
