//
//  TranslationsLoader.swift
//  DetectAR
//
//  Created by Vladyslav Vdovychenko on 28.01.2021.
//

import Foundation
import MLKitTranslate

class TranslationsLoader {
    
    
    static let shared = TranslationsLoader()
    
    fileprivate var translator: Translator?
    
    private init() {}
    
    func isModelAlredayAvailable() -> Bool {
        let currentLanguage = ApplicationLanguage.currentLanguage
        var targetLanguage: TranslateLanguage!
        
        switch currentLanguage {
        case .english:
            targetLanguage = .english
        case .ukrainian:
            targetLanguage = .ukrainian
        case .russian:
            targetLanguage = .russian
        }
        
        let targetModel = TranslateRemoteModel.translateRemoteModel(language: targetLanguage)
        return ModelManager.modelManager().isModelDownloaded(targetModel)
    }
    
    func loadLanguageModel(completed: @escaping () -> Void, failure: @escaping (Error?) -> Void) {
        let currentLanguage = ApplicationLanguage.currentLanguage
        if currentLanguage == .english { completed(); return }
        let targetLanguage: TranslateLanguage = (currentLanguage == .ukrainian) ? .ukrainian : .russian
        
        let options = TranslatorOptions(sourceLanguage: .english, targetLanguage: targetLanguage)
        let translator = Translator.translator(options: options)
        self.translator = translator
        let conditions = ModelDownloadConditions(
            allowsCellularAccess: true,
            allowsBackgroundDownloading: true
        )
        translator.downloadModelIfNeeded(with: conditions) { (error) in
            if let err = error { failure(err); return }
            completed()
        }
    }
    
    func translateText(_ inputText: String, outputText: @escaping (String) -> Void, failure: @escaping (Error?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let currentLanguage = ApplicationLanguage.currentLanguage
            var targetLanguage: TranslateLanguage!
            
            switch currentLanguage {
            case .english:
                targetLanguage = .english
            case .ukrainian:
                targetLanguage = .ukrainian
            case .russian:
                targetLanguage = .russian
            }
            let options = TranslatorOptions(sourceLanguage: .english, targetLanguage: targetLanguage)
            let translator = Translator.translator(options: options)
            self.translator = translator
            
            translator.translate(inputText) { (text, error) in
                if let err = error { failure(err); return }
                if let text = text { outputText(text) }
            }
        }
    }
    
    
}
