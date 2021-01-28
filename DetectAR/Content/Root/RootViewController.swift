//
//  RootViewController.swift
//  DetectAR
//
//  Created by Vladyslav Vdovycheko on 28.09.2020.
//

import UIKit


class RootViewController: BaseViewController {
        
    var interactor: RootInputProtocol?
    
    @IBOutlet weak var titleStackView: UIStackView!
    fileprivate lazy var mainMenuWireframe = { MainMenuWireframe() }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView.animate(withDuration: 1) {
            self.titleStackView.alpha = 1
        } completion: { [weak self] (true) in
            self?.initializeSession()
        }
    }
    
    fileprivate func initializeSession() {
        self.mainMenuWireframe.embeddedIn(self)
    }
    
}

extension RootViewController: RootOutputProtocol {
    
    
}


