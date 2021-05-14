//
//  APIInterface.swift
//  DetectAR
//
//  Created by Vladyslav Vdovychenko on 31.10.2020.
//

import Foundation
import MLKitTranslate

protocol MLAPIInterface: AnyObject {
    
    func saveSelectedMLModel(_ model: MLModelType)
    
    func getSavedModel() -> MLModelType
    
    func getAvailableModels(completion: @escaping ([NSDictionary]) -> Void)
    
}

protocol ARKitAPIInterface: AnyObject {
    
}

protocol StorageAPIInterface: AnyObject {
    
    func isTranslationEnabled() -> Bool
    
    func isDebugEnabled() -> Bool
    
    func isTutorialEnabled() -> Bool
    
    func getNumberOfSuggestions() -> Int
    
    func setTranslations(_ value: Bool)
    
    func setDebug(_ value: Bool)
    
    func setTutorial(_ value: Bool)
    
    func setNumberOfSuggestions(_ value: Int)
        
}

protocol TranslationsAPIInterface: AnyObject {
    
    
    
}
