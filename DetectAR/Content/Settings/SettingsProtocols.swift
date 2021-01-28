//
//  SettingsProtocols.swift
//  DetectAR
//
//  Created by Vladyslav Vdovychenko on 25.01.2021.
//

import Foundation

protocol SettingsInputProtocol: class {
    
    var view: SettingsOutputProtocol? { get set }
    
    func getAvailableModels()
    
    func saveModel(_ model: Model)
    
    func isModelSelected(_ model: Model) -> Bool
    
    func isTranslationEnabled() -> Bool
    
    func isDebugEnabled() -> Bool
    
    func setTranslations(_ value: Bool)
    
    func setDebug(_ value: Bool)
    
}

protocol SettingsOutputProtocol: class {
    
    var interactor: SettingsInputProtocol? { get set }
    
    func didReceiveAvailableModels(_ models: [Model])
        
}