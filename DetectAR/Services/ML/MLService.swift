//
//  MLService.swift
//  DetectAR
//
//  Created by Vladyslav Vdovychenko on 31.10.2020.
//

import Foundation

enum MLModelType: String {
    case MobileNetV2 = "MobileNetV2"
    case Resnet50 = "Resnet50"
    case SqueezeNet = "SqueezeNet"
}

class MLService: BaseService {
    
    var api: MLAPIInterface?
    
    func saveSelectedModel(_ model: MLModelType) {
        self.api?.saveSelectedMLModel(model)
    }
    
    func getSavedModel() -> MLModelType {
        return self.api?.getSavedModel() ?? .MobileNetV2
    }
    
    func getAvailableModels(completion: @escaping ([Model]) -> Void) {
        self.api?.getAvailableModels(completion: { [weak self] (array) in
            self?.parsingQueue.async {
                self?.parseModels(array, completion: completion)
            }
        })
    }
    
    fileprivate func parseModels(_ array: [NSDictionary], completion: @escaping ([Model]) -> Void) {
        var models = [Model]()
        for item in array {
            let model = Model(item)
            models.append(model)
        }
        completion(models)
    }
    
    
    
}
