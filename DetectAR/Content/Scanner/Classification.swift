//
//  Classification.swift
//  DetectAR
//
//  Created by Vladyslav Vdovychenko on 27.05.2021.
//

import Foundation
import Vision

typealias ClassificatonCallback = (_ fulltext: String, _ topPrediction: String) -> Void //full, top

class Classification {
    
    fileprivate var suggestionNumber: Int?
    fileprivate var isNeedToTranslate: Bool = false
    
    init(suggestionNumber: Int, isNeedToTranslate: Bool) {
        self.isNeedToTranslate = isNeedToTranslate
        self.suggestionNumber = suggestionNumber
    }
    
    func classificationCompleteHandler(request: VNRequest, error: Error?, completed: @escaping ClassificatonCallback) {
        // Catch Errors
        if error != nil { print("Error: " + (error?.localizedDescription)!); return }
        guard let observations = request.results else { print("No results"); return }
        guard let numberOfSuggestions = suggestionNumber else { print("No suggestion number"); return }
        
        // Get Classifications
        let classifications = observations[0...(numberOfSuggestions - 1)] // top 3 results
            .compactMap({ $0 as? VNClassificationObservation })
            .map({ "\($0.identifier) - \(self.convertToPercent($0.confidence));" })
            .joined(separator: "\n")
        
        translateClassifications(classifications) { (translatedText) in
            let objectName = translatedText.components(separatedBy: "-")[0].components(separatedBy: ",")[0]
            completed(translatedText, objectName)
        }
    }
    
    fileprivate func convertToPercent(_ value: VNConfidence) -> String { return "\(Int(value * 100))%" }
    
    fileprivate func translateClassifications(_ classifications: String, completed: @escaping (String) -> Void) {
        if isNeedToTranslate {
            TranslationsLoader.shared.translateText(classifications) { (translatedText) in
                completed(translatedText)
            } failure: { (error) in
                print("Error: \(error?.localizedDescription ?? "")")
                completed(classifications)
            }
        }
        else { completed(classifications) }
    }
}
