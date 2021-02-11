//
//  SettingsInteractor.swift
//  DetectAR
//
//  Created by Vladyslav Vdovychenko on 25.01.2021.
//

import Foundation

class SettingsInteractor: BaseInteractor {
    
    weak var view: SettingsOutputProtocol?
    
}

extension SettingsInteractor: SettingsInputProtocol {
    
    func isTranslationEnabled() -> Bool {
        return self.servicesContainer.storageService.isTranslationEnabled()
    }
    
    func isDebugEnabled() -> Bool {
        return self.servicesContainer.storageService.isDebugEnabled()
    }
    
    func setTranslations(_ value: Bool) {
        DispatchQueue.global(qos: .background).async {
            self.servicesContainer.storageService.setTranslations(value)
        }
    }
    
    func setDebug(_ value: Bool) {
        DispatchQueue.global(qos: .background).async {
            self.servicesContainer.storageService.setDebug(value)
        }
    }
    
    func setTutorial(_ value: Bool) {
        DispatchQueue.global(qos: .background).async {
            self.servicesContainer.storageService.setTutorial(value)
        }
    }
    
    func getAvailableModels() {
        DispatchQueue.global(qos: .background).async {
            self.servicesContainer.mlService.getAvailableModels { [weak self] (models) in
                self?.complete {
                    self?.view?.didReceiveAvailableModels(models)
                }
            }
        }
    }
    
    func saveModel(_ model: Model) {
        DispatchQueue.global(qos: .background).async {
            if let type = model.type {
                self.servicesContainer.mlService.saveSelectedModel(type)
            }
        }
    }
    
    func isModelSelected(_ model: Model) -> Bool {
        let selectedModel = self.servicesContainer.mlService.getSavedModel()
        return selectedModel == model.type
    }
    
    
    
}
