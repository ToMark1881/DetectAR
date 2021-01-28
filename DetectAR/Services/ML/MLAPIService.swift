//
//  MLAPIService.swift
//  DetectAR
//
//  Created by Vladyslav Vdovychenko on 31.10.2020.
//

import Foundation

class MLAPIService: MLAPIInterface {
    
    fileprivate let userDefaultsModelKey = "savedMLModel"
    
    func saveSelectedMLModel(_ model: MLModelType) {
        UserDefaults.standard.setValue(model.rawValue, forKey: userDefaultsModelKey)
    }
    
    func getSavedModel() -> MLModelType {
        if let savedValue = UserDefaults.standard.string(forKey: userDefaultsModelKey),
           let model = MLModelType(rawValue: savedValue) {
            return model
        }
        else {
            return .MobileNetV2
        }
    }
    
    func getAvailableModels(completion: @escaping ([NSDictionary]) -> Void) {
        completion(MODELS_INFORMATION)
    }
    
    
    
}
