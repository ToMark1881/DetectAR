//
//  MainMenuViewController.swift
//  DetectAR
//
//  Created by Vladyslav Vdovychenko on 25.01.2021.
//

import UIKit

class MainMenuViewController: BaseViewController {
    
    var interactor: MainMenuInputProtocol?
    
    fileprivate lazy var scannerWireframe = { return ScannerWireframe() }()
    fileprivate lazy var settingsWireframe = { return SettingsWireframe() }()

    @IBOutlet weak var titleStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.animateTitle()
        // Do any additional setup after loading the view.
    }
    
    fileprivate func openDetector() {
        self.scannerWireframe.pushFrom(self.navigationController)
    }
    
    fileprivate func openSettings() {
        self.settingsWireframe.pushFrom(self.navigationController)
    }
    
    @IBAction func didTapOnSettingsButton(_ sender: Any) {
        self.openSettings()
    }
    
    @IBAction func didTapOnScannerButton(_ sender: Any) {
        self.openDetector()
    }
    
    @IBAction func didTapOnAboutButton(_ sender: Any) {
        self.showInformation()
    }
    
    func showInformation() {
        AlertController.alert("DetectAR", message: "Version: \(Bundle.getVersion())" + "\nVladyslav Vdovychenko\nKNU FIT\n2021")
    }
    
    fileprivate func animateTitle(_ isShowed: Bool = true) {
        UIView.animate(withDuration: 2.5) { [weak self] in
            self?.titleStackView.alpha = isShowed ? 0.3 : 1.0
        } completion: { [weak self] (completed) in
            self?.animateTitle(!isShowed)
        }
    }
    
}

extension MainMenuViewController: MainMenuOutputProtocol {
    
}
