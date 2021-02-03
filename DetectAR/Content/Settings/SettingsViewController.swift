//
//  SettingsViewController.swift
//  DetectAR
//
//  Created by Vladyslav Vdovychenko on 25.01.2021.
//

import UIKit

class SettingsViewController: BaseViewController {
    
    var interactor: SettingsInputProtocol?

    @IBOutlet weak var modelsTableView: UITableView!
    @IBOutlet weak var modelsTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var debugSwitch: UISwitch!
    @IBOutlet weak var translationsSwitch: UISwitch!
    
    fileprivate let cellId = "MLModelTableViewCell"
    fileprivate var mlModels: [Model]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modelsTableView.register(UINib(nibName: "MLModelTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        self.interactor?.getAvailableModels()
        self.setSwitches()
        // Do any additional setup after loading the view.
    }
    
    fileprivate func setSwitches() {
        self.debugSwitch.isOn = self.interactor?.isDebugEnabled() ?? false
        self.translationsSwitch.isOn = self.interactor?.isTranslationEnabled() ?? false
    }
    
    @IBAction func didChangeDebugSwitch(_ sender: Any) {
        if let value = (sender as? UISwitch)?.isOn {
            self.interactor?.setDebug(value)
        }
    }
    
    @IBAction func didChangeTranslationsSwitch(_ sender: Any) {
        if let isOn = (sender as? UISwitch)?.isOn {
            if isOn {
                self.setupLanguageModels()
            }
            else {
                self.interactor?.setTranslations(isOn)
            }
        }
    }
    
    fileprivate func setupLanguageModels() {
        if TranslationsLoader.shared.isModelAlreadyAvailable() {
            self.translationsSwitch.isOn = true
            self.interactor?.setTranslations(true)
            return
        }
        
        AlertController.alert("Translation".localized, message: "Need to download language model".localized, buttons: ["Download".localized, "Cancel".localized]) { (action, index) in
            if index == 0 {
                self.loadModel()
            }
        }
    }
    
    fileprivate func loadModel() {
        let spinner = AlertController.instance.spinner()
        self.present(spinner, animated: true) {
            TranslationsLoader.shared.loadLanguageModel {
                spinner.dismiss(animated: true) {
                    self.translationsSwitch.isOn = true
                    self.interactor?.setTranslations(true)
                }
            } failure: { (error) in
                spinner.dismiss(animated: true) {
                    AlertController.alert("Error".localized, message: error?.localizedDescription ?? "")
                    self.translationsSwitch.isOn = false
                    self.interactor?.setTranslations(false)
                }
            }
        }
    }
}

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let model = mlModels?[indexPath.row] {
            self.interactor?.saveModel(model)
        }
    }
    
}

extension SettingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mlModels?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! MLModelTableViewCell
        if let model = mlModels?[indexPath.row] {
            cell.setupCell(with: model)
            if self.interactor?.isModelSelected(model) == true {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
        }
        return cell
    }
    
    
}

extension SettingsViewController: SettingsOutputProtocol {
    
    func didReceiveAvailableModels(_ models: [Model]) {
        self.mlModels = models
        self.modelsTableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.modelsTableViewHeight.constant = self.modelsTableView.contentSize.height
            if self.view.bounds.height > (self.modelsTableView.contentSize.height + 100) {
                self.modelsTableView.isScrollEnabled = false
            }
        }
    }
    
}
